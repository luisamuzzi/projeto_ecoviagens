create_sql_table_atividades = """
CREATE TABLE IF NOT EXISTS "atividades" (
  "id_oferta" integer PRIMARY KEY,
  "nivel_dificuldade" varchar,
  "duracao" integer,
  "grupo_maximo" integer
);
"""

create_sql_table_avaliacoes = """
CREATE TABLE IF NOT EXISTS "avaliacoes" (
  "id_avaliacao" integer PRIMARY KEY,
  "id_cliente" integer,
  "id_oferta" integer,
  "nota" integer,
  "comentario" text,
  "data_avaliacao" date
);
"""

create_sql_table_clientes = """
CREATE TABLE IF NOT EXISTS "clientes" (
  "id_cliente" integer PRIMARY KEY,
  "nome" varchar,
  "email" varchar,
  "data_nascimento" date,
  "genero" varchar,
  "localidade" varchar
);
"""

create_sql_table_hospedagens = """
CREATE TABLE IF NOT EXISTS "hospedagens" (
  "id_oferta" integer PRIMARY KEY,
  "tipo_acomodacao" varchar,
  "capacidade" integer,
  "possui_cafe_manha" bool
);
"""

create_sql_table_oferta_pratica = """
CREATE TABLE IF NOT EXISTS "oferta_pratica" (
  "id_oferta" integer,
  "id_pratica" integer
);
"""

create_sql_table_ofertas = """
CREATE TABLE IF NOT EXISTS "ofertas" (
  "id_oferta" integer PRIMARY KEY,
  "tipo_oferta" varchar,
  "titulo" varchar,
  "descricao" text,
  "preco" decimal(10,2),
  "id_operador" integer
);
"""

create_sql_table_operadores = """
CREATE TABLE IF NOT EXISTS "operadores" (
  "id_operador" integer PRIMARY KEY,
  "nome_fantasia" varchar,
  "cnpj" varchar,
  "telefone" varchar,
  "email" varchar,
  "localidade" varchar
);
"""

create_sql_table_praticas_sustentaveis = """
CREATE TABLE IF NOT EXISTS "praticas_sustentaveis" (
  "id_pratica" integer PRIMARY KEY,
  "nome" varchar
);
"""

create_sql_table_reservas = """
CREATE TABLE IF NOT EXISTS "reservas" (
  "id_reserva" integer PRIMARY KEY,
  "id_cliente" integer,
  "id_oferta" integer,
  "data_reserva" date,
  "data_experiencia" date,
  "qtd_pessoas" integer,
  "status" varchar
);
"""

insert_data_atividades = """ 
INSERT INTO "atividades" (id_oferta, nivel_dificuldade, duracao, grupo_maximo)
                                    VALUES(%s, %s, %s, %s)
"""

insert_data_avaliacoes = """ 
INSERT INTO "avaliacoes" (id_avaliacao, id_cliente, id_oferta, nota, comentario, data_avaliacao)
                                    VALUES(%s, %s, %s, %s, %s, %s)
"""

insert_data_clientes = """ 
INSERT INTO "clientes" (id_cliente, nome, email, data_nascimento, genero, localidade)
                                    VALUES(%s, %s, %s, %s, %s, %s)
"""

insert_data_hospedagens = """ 
INSERT INTO "hospedagens" (id_oferta, tipo_acomodacao, capacidade, possui_cafe_manha)
                                    VALUES(%s, %s, %s, %s)
"""

insert_data_oferta_pratica = """ 
INSERT INTO "oferta_pratica" (id_oferta, id_pratica)
                                    VALUES(%s, %s)
"""

insert_data_ofertas = """ 
INSERT INTO "ofertas" (id_oferta, tipo_oferta, titulo, descricao, preco, id_operador)
                                    VALUES(%s, %s, %s, %s, %s, %s)
"""

insert_data_operadores = """ 
INSERT INTO "operadores" (id_operador, nome_fantasia, cnpj, telefone, email, localidade)
                                    VALUES(%s, %s, %s, %s, %s, %s)
"""

insert_data_praticas_sustentaveis = """ 
INSERT INTO "praticas_sustentaveis" (id_pratica, nome)
                                    VALUES(%s, %s)
"""

insert_data_reservas = """ 
INSERT INTO "reservas" (id_reserva, id_cliente, id_oferta, data_reserva, data_experiencia, qtd_pessoas, status)
                                    VALUES(%s, %s, %s, %s, %s, %s, %s)
"""