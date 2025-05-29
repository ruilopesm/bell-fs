defmodule BellFSWeb.BodyCacheReader do
  @moduledoc """
  Custom body reader for Plug that caches the raw request body.
  """
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = Plug.Conn.put_private(conn, :cached_raw_body, body)
    {:ok, body, conn}
  end
end
