# Customer Analytics Lakehouse

Projeto de dados end-to-end para análise de **cadastro, ativação, engajamento, recorrência, categorias de uso, valor transacionado e cashback**.

A solução foi construída no **Databricks**, organizada em camadas **Bronze, Silver e Gold**, orquestrada por um **Job** e consumida no **Power BI**.

## Objetivo

O projeto busca responder perguntas como:

- Quantos clientes estão cadastrados?
- Quantos clientes realizaram ao menos uma transação?
- Qual é a taxa de ativação da base?
- Como a ativação varia por estado?
- Qual é o volume de transações ao longo do período?
- Com que frequência os clientes utilizam o produto?
- Quantas categorias cada cliente utiliza?
- Qual categoria concentra mais transações?
- Qual é o valor transacionado, ticket médio e cashback concedido?

## Período analisado

Os dados disponíveis abrangem o período de:

```text
20/03/2026 a 17/06/2026
```

> Março e junho são meses incompletos. Para comparações mensais, a análise mais adequada é entre abril e maio de 2026.

## Arquitetura

```mermaid
Arquivos de origem
        ↓
Cloud storage (S3)
        ↓
Bronze - Delta Lake
        ↓
Silver - Delta Lake
        ↓
Gold - Delta Lake
        ↓
Power BI
```
As tabelas das camadas Bronze, Silver e Gold são armazenadas no formato Delta Lake e organizadas no Unity Catalog. Essa estrutura garante maior confiabilidade no processamento, controle de esquema, versionamento dos dados e suporte a futuras cargas incrementais.

### Componentes

| Componente | Responsabilidade |
|---|---|
| Databricks Workspace | Organização dos scripts SQL e documentação |
| Unity Catalog | Governança, organização e acesso aos dados |
| Volume `source_files` | Armazenamento dos arquivos de origem |
| Bronze | Ingestão dos dados brutos |
| Silver | Limpeza, tipagem e padronização |
| Gold | Modelagem analítica para consumo |
| Databricks Job | Orquestração das etapas |
| Power BI | Visualização e storytelling |


## Armazenamento no AWS S3

Os arquivos de origem são armazenados no bucket:

```text
customer-analytics-lakehouse-577638374158-us-east-1-an
```

Na raiz do bucket existem duas áreas principais:

```text
managed/
raw/
```

- `managed/`: utilizada para dados gerenciados pelo ambiente.
- `raw/`: utilizada para armazenar os arquivos brutos recebidos pelo projeto.

**Estrutura do bucket no S3**

Dentro de `raw`, os arquivos são separados por domínio:

```text
raw/
├── customers/
└── orders/
```

Essa separação facilita a ingestão independente dos dados de clientes e transações nas respectivas pipelines Bronze.

![s3.png](./image_1784028647368.png "s3.png")

### Fluxo de ingestão

```mermaid
S3 raw/customers                     S3 raw/orders         
        ↓                                  ↓
Bronze customers                     Bronze orders
        ↓                                  ↓
Silver customers                     Silver orders
        ↓                                  ↓
Gold customers                        Gold orders

```

## Estrutura do projeto no Databricks

```text
customer-analytics/
├── documentação/
│   ├── prova-tecnica
│   └── README.md
├── pipelines/
│   ├── customers/
│   │   ├── 01_bronze.sql
│   │   ├── 02_silver.sql
│   │   └── 03_gold.sql
│   └── orders/
│       ├── 01_bronze.sql
│       ├── 02_silver.sql
│       └── 03_gold.sql
└── setup/
    └── 00_environment_setup.sql
```

## Unity Catalog

O projeto utiliza o catálogo:

```text
customer_analytics
```

Schemas existentes:

```text
customer_analytics.raw
customer_analytics.bronze
customer_analytics.silver
customer_analytics.gold
```

O schema `raw` contém o volume:

```text
customer_analytics.raw.source_files
```

As tabelas finais disponíveis para análise são:

```text
customer_analytics.gold.customers
customer_analytics.gold.orders
```

![catalog.png](./image_1784028733409.png "catalog.png")

## Camadas de dados

### Raw

Camada de entrada dos arquivos.

Responsabilidades:

- armazenar os arquivos de origem;
- disponibilizar os dados para ingestão;
- manter o ponto inicial da pipeline.

### Bronze

Camada de ingestão.

Responsabilidades:

- ler os arquivos brutos;
- preservar os dados recebidos;
- criar as tabelas iniciais;
- adicionar rastreabilidade de carga quando necessário.

Arquivos:

```text
pipelines/customers/01_bronze.sql
pipelines/orders/01_bronze.sql
```

### Silver

Camada de tratamento.

**Responsabilidades:**

Customers

- Conversão de identificadores para BIGINT;
- Remoção de espaços do nome;
- Remoção de caracteres não numéricos do documento;
- Conversão da data para TIMESTAMP;
- Limpeza e padronização do estado;
- Criação do indicador is_valid_customer;
- Identificação de customer_id não informado;
- Manutenção dos metadados de origem e ingestão.

Orders

- Conversão dos identificadores para BIGINT;
- Conversão de valores monetários para DECIMAL;
- Conversão do percentual de cashback para DECIMAL;
- Cálculo do cashback esperado;
- Conversão da data para TIMESTAMP;
- Remoção de espaços da descrição;
- Manutenção dos metadados de origem e ingestão.

Arquivos:

```text
pipelines/customers/02_silver.sql
pipelines/orders/02_silver.sql
```

### Gold

Camada analítica.

Responsabilidades:

- entregar tabelas prontas para consumo;
- organizar a granularidade dos dados;
- disponibilizar dimensões e fatos;
- servir o Power BI.

Arquivos:

```text
pipelines/customers/03_gold.sql
pipelines/orders/03_gold.sql
```

## Tabelas finais

`customer_analytics.gold.customers`

Granularidade:

```text
Um registro por cliente
```

Uso principal:

- total de clientes cadastrados;
- análise por estado;
- dimensão de clientes;
- cálculo da base sem transação.

`customer_analytics.gold.orders`

Granularidade:

```text
Um registro por transação
```

Uso principal:

- clientes ativos;
- volume de transações;
- categorias utilizadas;
- valor transacionado;
- cashback;
- ticket médio;
- análises temporais.

## Pipeline de execução

O Job criado no Databricks se chama:

```text
customer_analytics_pipeline
```

Fluxo de execução:

```text
├── 00_setup
├── 01_bronze_ingestao_customers
├── 01_bronze_ingestao_orders
├── 02_silver_tratamento_customers
├── 02_silver_tratamento_orders
├── 03_gold_modelagem_customers
└── 03_gold_modelagem_orders
```

A pipeline separa o processamento de `customers` e `orders`, mas mantém as dependências necessárias entre as camadas.

**OBS.:** Criei a task para atualizar PowerBI, entretanto não consegui salvar em razão da necessidade de conta premium.

![pipeline.png](./image_1784028516819.png "pipeline.png")

## Consultas analíticas

As consultas utilizadas para validação e análise ficam em:

```text
documentação/queries
```

## Dashboard

O dashboard foi dividido em três páginas, cada uma com um objetivo claro.

---

## Página 1 - Ativação da base

Objetivo:

> Entender o tamanho da base cadastrada, quantos clientes foram ativados e como a ativação se distribui por estado.

### Indicadores

| Indicador | Resultado |
|---|---:|
| Clientes cadastrados | 950 |
| Clientes ativos | 428 |
| Taxa de ativação | 45,1% |
| Clientes sem transação | 522 |

### Evolução de clientes ativos

| Mês | Clientes ativos |
|---|---:|
| Março | 287 |
| Abril | 403 |
| Maio | 412 |
| Junho | 346 |

### Insight

Menos da metade da base cadastrada realizou transações no período analisado. A principal oportunidade é ativar os 522 clientes que ainda não transacionaram.

![page1.png](./image_1784029018686.png "page1.png")

---

## Página 2 - Jornada de uso

Objetivo:

> Avaliar recorrência, frequência, diversidade e preferência de uso dos clientes ativos.

### Indicadores

| Indicador | Resultado |
|---|---:|
| Transações totais | 3.838 |
| Clientes ativos | 428 |
| Transações por cliente ativo | 9 |
| Clientes nas três categorias | 82,7% |
| Clientes com mais de uma transação | 99,5% |

### Volume mensal

| Mês | Transações |
|---|---:|
| Março | 509 |
| Abril | 1.266 |
| Maio | 1.358 |
| Junho | 705 |

### Clientes por frequência

| Faixa | Clientes |
|---|---:|
| 1 transação | 2 |
| 2 a 5 transações | 44 |
| 6 a 10 transações | 268 |
| Mais de 10 transações | 114 |

### Clientes por quantidade de categorias

| Categorias utilizadas | Clientes | Participação |
|---|---:|---:|
| 1 categoria | 6 | 1,4% |
| 2 categorias | 68 | 15,9% |
| 3 categorias | 354 | 82,7% |

### Transações por categoria

| Categoria | Transações | Participação |
|---|---:|---:|
| KM Régua | 1.871 | 48,7% |
| KM Action | 1.000 | 26,1% |
| KM Aplicativo Transporte | 967 | 25,2% |

### Insight

Os clientes ativos apresentam alta recorrência, com média de nove transações por cliente no período. A maior parte realizou entre seis e dez transações e utilizou as três categorias.

![page2.png](./image_1784028986417.png "page2.png")

---

## Página 3 - Eficiência financeira

Objetivo:

> Analisar o valor movimentado, o cashback concedido e o desempenho financeiro das categorias.

### Indicadores

| Indicador | Resultado |
|---|---:|
| Valor transacionado | R$ 644.951 |
| Cashback concedido | R$ 25.452 |
| Ticket médio | R$ 168 |
| Cashback sobre valor transacionado | 3,9% |

### Valor e volume por categoria

| Categoria | Transações | Valor transacionado |
|---|---:|---:|
| KM Action | 1.000 | R$ 194.106 |
| KM Aplicativo Transporte | 967 | R$ 94.872 |
| KM Régua | 1.871 | R$ 355.974 |

### Ticket médio por categoria

| Categoria | Ticket médio |
|---|---:|
| KM Action | R$ 194 |
| KM Régua | R$ 190 |
| KM Aplicativo Transporte | R$ 98 |

### Cashback por categoria

| Categoria | Cashback |
|---|---:|
| KM Action | R$ 13.587 |
| KM Régua | R$ 7.121 |
| KM Aplicativo Transporte | R$ 4.744 |

### Insight

Foram movimentados aproximadamente R$ 644,9 mil, com R$ 25,5 mil concedidos em cashback. O benefício representou 3,9% do valor transacionado, enquanto o ticket médio permaneceu próximo de R$ 168.

![page3.png](./image_1784028902471.png "page3.png")

## Principais conclusões

- A ativação da base é o principal ponto de melhoria.
- Os clientes já ativados apresentam alto engajamento.
- A maioria utiliza as três categorias disponíveis.
- A categoria KM Régua lidera em volume e valor transacionado.
- KM Action possui o maior ticket médio.
- KM Aplicativo Transporte representa 25,2% das transações, mas possui o menor ticket médio.
- O cashback equivale a 3,9% do valor movimentado.

## Como executar

1. Disponibilize os arquivos no volume de origem.
2. Execute `setup/00_environment_setup.sql`.
3. Execute as etapas Bronze.
4. Execute as etapas Silver.
5. Execute as etapas Gold.
6. Valide os dados em `documentação/queries`.
7. Atualize o dataset no Power BI.

Também é possível executar todo o fluxo pelo Job:

```text
customer_analytics_pipeline
```

## Próximos passos

- implementar cargas incrementais;
- adicionar testes automáticos;
- parametrizar ambiente e caminhos;
- adicionar alertas de falha;
- versionar o arquivo `.pbix`.

## Entregáveis

- scripts SQL de Setup, Bronze, Silver e Gold;
- tabelas Delta no Unity Catalog;
- job de orquestração;
- consultas analíticas;
- dashboard Power BI;
- documentação técnica e funcional;
- README do projeto.
