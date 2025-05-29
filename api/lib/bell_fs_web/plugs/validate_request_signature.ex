defmodule BellFSWeb.Plugs.ValidateRequestSignature do
  @moduledoc """
  This plug is meant to validate the request signature for incoming requests.

  These signatures must come in a `X-Signature` header on each HTTP request that
  is issued. These are useful for providing a better audiability model of the
  requests and who are the ones making them.

  A header is defined as a signature of a SHA-256 hash of the request path,
  method and body encoded in Base64. It should have been signed by the user who
  is making the request - that is, the user that corresponds to the access token
  being used.

  ```
  {
    "path": "...", # URL path
    "method": "...", # HTTP method
    "body": "..." # Raw body of the request
  }
  ```
  """

  @behaviour Plug

  import Plug.Conn

  require Logger

  alias BellFS.Audit
  alias BellFS.Audit.Log

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    case get_req_header(conn, "x-signature") do
      [signature] ->
        public_key = get_current_user_public_key(conn)
        signature = Base.decode64!(signature, padding: true)
        {raw_body, conn} = read_cached_body(conn)

        payload =
          build_digest(
            conn.request_path,
            String.downcase(conn.method),
            raw_body
          )

        ok? = verify_rsa_signature(signature, payload, public_key)

        if ok? do
          {:ok, %Log{} = _} =
            Audit.create_log(%{
              "content" => Base.encode64(payload, padding: true),
              "signature" => Base.encode64(signature, padding: true),
            })

          conn
        else
          Logger.info("Invalid X-Signature header")
          unauthorized(conn)
        end

      _ ->
        Logger.info("Missing X-Signature header")
        bad_request(conn)
    end
  end

  defp build_digest(path, method, body) do
    {result, _} =
      Pythonx.eval(
        """
        import base64
        from collections import OrderedDict
        from json import dumps, loads

        signature_content = OrderedDict([
          ('path', path.decode('utf-8')),
          ('method', method.decode('utf-8'))
        ])

        if body:
          signature_content['body'] = loads(body.decode('utf-8'))

        base64.b64encode(dumps(signature_content).encode('utf-8'))
        """,
        %{
          "path" => path,
          "method" => method,
          "body" => body
        }
      )

    Pythonx.decode(result)
  end

  defp get_current_user_public_key(conn) do
    certificate = conn.assigns.current_user.certificate |> Base.decode64!(padding: true)

    {result, _} =
      Pythonx.eval(
        """
        from cryptography import x509

        certificate = x509.load_pem_x509_certificate(raw_certificate)
        certificate.public_key()
        """,
        %{"raw_certificate" => certificate}
      )

    Pythonx.decode(result)
  end

  defp verify_rsa_signature(signature, ciphertext, public_key) do
    {result, _} =
      Pythonx.eval(
        """
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.primitives.asymmetric import padding as asym_padding

        try:
          public_key.verify(
            signature,
            ciphertext,
            asym_padding.PSS(
              mgf=asym_padding.MGF1(hashes.SHA256()),
              salt_length=asym_padding.PSS.MAX_LENGTH,
            ),
            hashes.SHA256()
          )

          result = True
        except:
          result = False

        result
        """,
        %{
          "signature" => signature,
          "ciphertext" => ciphertext,
          "public_key" => public_key
        }
      )

    Pythonx.decode(result)
  end

  defp read_cached_body(conn) do
    case conn.private[:cached_raw_body] do
      nil ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        {body, put_private(conn, :cached_raw_body, body)}

      body ->
        {body, conn}
    end
  end

  defp unauthorized(conn) do
    body =
      Jason.encode!(%{
        errors: %{
          detail: "Unauthorized",
          message: "invalid X-Signature header"
        }
      })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
    |> halt()
  end

  defp bad_request(conn) do
    body =
      Jason.encode!(%{
        errors: %{
          detail: "Bad Request",
          message: "missing X-Signature header"
        }
      })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, body)
    |> halt()
  end
end
