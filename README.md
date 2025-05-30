## BellFS - Modelo Formal de Controlo de Acesso

### Relatório
O relatório pode ser encontrado na pasta [report](report). Mais especificamente, o ficheiro pdf está em [report/report.pdf](report/report.pdf).

### Cliente
Para executar o cliente basta correr o seguinte comando:

```bash
make client
```

O código fonte desta componente pode ser encontrado em [client](client).

> [!NOTE]
> Assume-se que já existe um ambiente virtual local configurado ou então é possível instalar dependências Python globalmente.

### Servidor
Para executar o servidor (e respetiva base de dados) basta correr o seguinte comando:

```bash
make server
```

O código fonte desta componente pode ser encontrado em [api](api).

> [!CAUTION]
> É necessário possuir Docker instalado para correr estas componentes.
