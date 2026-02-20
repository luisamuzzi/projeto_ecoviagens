## Resumo

Esse projeto analisou dados de reservas, clientes, ofertas e práticas sustentáveis da empresa EcoViagens, cujo foco é oferecer experiências de turismo sustentável aos seus clientes. O projeto teve abordagem ponta a ponta, passando pela criação do banco de dados com foco em permitir o acompanhamento das demandas gerenciais da empresa, proposição de métricas estratégicas a partir dos dados modelados e, por fim, a análise dos dados e disponibilização por meio de dashboards gerenciais. Os principais produtos obtidos em cada etapa foram:

- Modelagem de dados da plataforma da EcoViagens:
    
    Essa etapa resultou num Diagrama Entidade-Relacionamento descrevendo a estrutura das tabelas que compõe a base de dados e um script Python para carga automática dos dados em banco de dados PostgreSQL.
    
- Proposição de KPIs estratégicos que permitissem avaliar o desempenho do negócio, entender o comportamento dos clientes e guiar melhorias dos serviços:
    
    Essa etapa resultou num descritivo contendo os KPIs, sua importância para o negócio e o método de cálculo.
    
- Análise de dados via SQL para mapear o desempenho da empresa em termos de receita, fidelização de clientes, avaliações e popularidade de práticas sustentáveis.
    
    Essa etapa resultou em insights para os times de negócio, marketing e experiência do cliente, além da documentação das consultas por meio de um script SQL contendo o objetivo e metodologia de cada consulta.
    
- Elaboração de dashboards de acompanhamento dos KPIs propostos na etapa 2.
    
    Essa etapa resultou em um [relatório em Power BI](https://app.powerbi.com/view?r=eyJrIjoiYjAwMzUxOGQtYzgxMS00NDU3LTk1M2QtYjY4YTUxYmUyMTY0IiwidCI6ImUyZjc3ZDAwLTAxNjMtNGNmNi05MmIwLTQ4NGJhZmY5ZGY3ZCJ9) e uma [apresentação executiva](https://www.canva.com/design/DAHBt1sDoSc/tuKTbycc5F7xqb_LT2LkGQ/edit?utm_content=DAHBt1sDoSc&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton) com os principais achados. Os resultados da análise dos dados indicaram: comportamento instável da receita, baixa taxa de fidelização de clientes, ausência de retorno financeiro ao fidelizar clientes e não-percepção de valor nas práticas sustentáveis por parte dos clientes. Assim, foram feitas recomendações visando o aumento da previsibilidade da receita, do ticket médio e da percepção de valor em relação às ofertas e sustentabilidade.
    

Leia mais sobre o projeto abaixo.

## Índice

1. Contexto
2. Premissas assumidas para a análise
3. Ferramentas utilizadas
4. Estratégia de solução
5. O produto final do projeto
6. Principais insights de dados
7. Conclusão
8. Próximos passos
9. Referências

## 1. Contexto

A empresa EcoViagens surgiu com a missão de oferecer serviços de marketplace para conectar operadores turísticos e viajantes interessados na prática de turismo sustentável e de baixo impacto ambiental. Em um primeiro momento, a EcoViagens realizou o lançamento de sua plataforma online de reservas de pacotes e atividades turísticas. Para isso, foi necessário criar um modelo de dados capaz de atender às demandas operacionais da empresa, bem como servir de suporte para decisões baseadas em dados. Com isso, o modelo foi pensado para permitir a realização de análises e a criação de métricas e indicadores para o acompanhamento da saúde do negócio, do desempenho dos operadores e da popularidade de ofertas.

Em seguida, as informações coletadas e armazenadas no banco de dados (reservas, clientes, avaliações, ofertas, atividades, hospedagem e práticas sustentáveis) foram analisadas por meio de SQL e disponibilizadas de forma visual em dashboards no Power BI. Além disso, as principais conclusões e recomendações obtidas da análise foram descritas em uma apresentação executiva.

Esse projeto, portanto, percorreu quatro etapas: modelagem e armazenamento dos dados em banco de dados → proposta de KPIs que devem ser monitorados a partir dos dados → análise dos dados para obtenção de informações estratégicas ao negócio → disponibilização das métricas e insights obtidos por meio de dashboards e uma apresentação executiva.

## 2. Premissas assumidas para a análise

1. Os dados abrangem reservas realizadas no período de junho de 2024 a junho de 2025, estando o mês de junho/2025 incompleto (dados até 08/06/25).
2. Análises temporais utilizam a data de realização da reserva como referência.
3. Análises financeiras consideram apenas reservas concluídas.

## 3. Ferramentas utilizadas

- Python e SQL para a criação do script que automatiza a carga de dados no banco de dados:
    - psycopg2
    - csv
    - os
    - dotenv
    - pathlib
    - schedule
    - datetime
- SQL para consultas.
- PostgreSQL como SGDB.
- Power BI como ferramenta de DataViz
- Canva para apresentação executiva.

## 4. Estratégias de solução

1. **Modelagem de dados:**
    
    Nessa etapa, foi estruturado o modelo de dados contendo as entidades necessárias (tabelas), seus atributos (colunas) e as relações/conexões entre elas. Os principais produtos da primeira etapa foram um Diagrama Entidade-Relacionamento (DER) e um descritivo detalhado das entidades e seus respectivos atributos e tipos de dados.
    
    A definição de um modelo de dados robusto é fundamental para garantir a consistência e eficiência do banco de dados, além de permitir a sua escalabilidade e ser a base para a definição de métricas e KPIs estratégicos.
    
    O modelo de dados proposto:
    
    ![DER - EcoViagens.png](images/DER%20-%20EcoViagens.png)
    
    Detalhamento das entidades:
    
    - Clientes:
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_cliente | INT (PK) | Identificador único do cliente |
    | nome | VARCHAR | Nome completo do clinte |
    | email | VARCHAR | E-mail do cliente |
    | data_nascimento | DATE | Data de nascimento do cliente |
    | genero | VARCHAR | Gênero do cliente (Masculino, Feminino) |
    | localidade | VARCHAR | Local de residência do cliente |
    - Reservas:
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_reserva | INT (PK) | Identificador único da reserva |
    | id_cliente | INT (FK) | Chave estrangeira → Clientes |
    | id_oferta | INT (FK) | Chave estrangeira → Ofertas |
    | data_reserva | DATE | Data em que a reserva foi feita |
    | data_experiencia | DATE | Data prevista para a experiência |
    | qtd_pessoas | INT | Quantidade de pessoas na reserva |
    | status | VARCHAR | Status da reserva (confirmada, cancelada, concluída) |
    - Avaliações:
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_avaliacao | INT (PK) | Identificador único da avaliação |
    | id_cliente | INT (FK) | Chave estrangeira → Clientes |
    | id_oferta | INT (FK) | Chave estrangeira → Ofertas |
    | nota | INT | Nota dada pelo cliente para a oferta (1 a 5) |
    | comentario | TEXT | Comentário da avaliação (Opcional) |
    | data_avaliacao | DATE | Data da realização da avaliação |
    - Ofertas:
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_oferta | INT (PK) | Identificador único da oferta |
    | tipo_oferta | VARCHAR | Tipo da oferta (Atividade ou Hospedagem) |
    | titulo | VARCHAR | Nome da oferta |
    | descricao | TEXT | Descrição da oferta |
    | preco | DECIMAL (10, 2) | Preço unitário da oferta |
    | id_operador | INT (FK) | Chave estrangeira → Operadores |
    - Operadores:
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_operador | INT (PK) | Identificador único do operador |
    | nome_fantasia | VARCHAR | Nome do operador |
    | cnpj | VARCHAR | CNPJ do operador |
    | telefone | VARCHAR | Telefone do operador |
    | email | VARCHAR | E-mail do operador |
    | localidade | VARHCAR | Localização do operador |
    - Hospedagem (subtipo de Oferta; relação de herança):
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_oferta | INT (PK, FK) | Chave estrangeira → Oferta |
    | tipo_acomodacao | VARCHAR | Tipo de acomodação |
    | capacidade | INT | Quantidade máxima de pessoas permitidas na acomodação |
    | possui_cafe_manha | BOOL | Se possui café da manhã (Sim ou Não) |
    - Atividades (subtipo de Oferta; relação de herança):
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_oferta | INT (PK, FK) | Chave estrangeira → Oferta |
    | nivel_dificuldade | VARCHAR | Nível de dificuldade da atividade (fácil, médio ou difícil) |
    | duracao | INT | Tempo de duração da atividade |
    | grupo_maximo | INT | Quantidade máxima de pessoas permitidas na atividade |
    - Oferta/Prática (tabela associativa para “resolver” a relação N:N entre as ofertas e atividades):
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_oferta | INT (FK) | Chave estrangeira → Oferta |
    | id_pratica | INT (FK) | Chave estrangeira → Prática sustentável |
    - Práticas sustentáveis:
    
    | **Campo** | **Tipo** | **Descrição** |
    | --- | --- | --- |
    | id_pratica | INT (PK) | Identificador único da prática sustentável |
    | nome | VARCHAR | Nome/descrição da prática sustentável |
    
    Com base no modelo, os dados coletados pela plataforma foram armazenados em banco de dados PostgreSQL por meio de um script Python. O script automatizou a inserção dos dados no banco, realizando a carga todos os dias a uma da manhã. Para tanto, foram utilizadas as bibliotecas: 
    
    - `psycopg2`: usada para interagir com o banco de dados PostgreSQL.
    - `csv`: usada para ler os arquivos com os dados.
    - `os`: usada para obter os valores das variáveis de ambiente.
    - `dotenv`: usada para gerenciar as variáveis de ambiente.
    - `pathlib`: usada para obter o caminho dos arquivos de dados.
    - `schedule`: usada para agendar a carga de dados.
    - `datetime`: usada para definir o tempo entre cada carga de dados.
2. **Proposta de KPIs:**
    
    Com base nos dados previstos pela modelagem realizada na etapa anterior, foram recomendados KPIs estratégicos para a compreensão e monitoramento contínuo do negócio. O principal produto da segunda etapa foi um descritivo contendo os KPIs, sua importância para o negócio e o método de cálculo. O acompanhamento dos KPIs permite verificar o crescimento da empresa e seu alinhamento ao propósito sustentável, bem como orientar decisões. 
    
    | **KPI** | **Porque é importante** | **Como é calculado** |
    | --- | --- | --- |
    |  |  |  |
    |  |  |  |