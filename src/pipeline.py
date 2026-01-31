#==============================================
# Libraries
#==============================================
import psycopg2
import csv
import os
from dotenv import load_dotenv
from pathlib import Path
import schedule
from datetime import time, timedelta, datetime
import parameters

#==============================================
# Carga das configurações
#==============================================

# Carregar as configurações do arquivo .env
load_dotenv()

#==============================================
# Definição das variáveis
#==============================================
PATH_ATIVIDADES = os.getenv("PATH_ATIVIDADES")
PATH_AVALIACOES = os.getenv("PATH_AVALIACOES")
PATH_CLIENTES = os.getenv("PATH_CLIENTES")
PATH_HOSPEDAGENS = os.getenv("PATH_HOSPEDAGENS")
PATH_OFERTA_PRATICA=os.getenv("PATH_OFERTA_PRATICA")
PATH_OFERTAS=os.getenv("PATH_OFERTAS")
PATH_OPERADORES=os.getenv("PATH_OPERADORES")
PATH_PRATICAS_SUSTENTAVEIS=os.getenv("PATH_PRATICAS_SUSTENTAVEIS")
PATH_RESERVAS=os.getenv("PATH_RESERVAS")

PATH_ATIVIDADES=Path(PATH_ATIVIDADES)
PATH_AVALIACOES=Path(PATH_AVALIACOES)
PATH_CLIENTES=Path(PATH_CLIENTES)
PATH_HOSPEDAGENS=Path(PATH_HOSPEDAGENS)
PATH_OFERTA_PRATICA=Path(PATH_OFERTA_PRATICA)
PATH_OFERTAS=Path(PATH_OFERTAS)
PATH_OPERADORES=Path(PATH_OPERADORES)
PATH_PRATICAS_SUSTENTAVEIS=Path(PATH_PRATICAS_SUSTENTAVEIS)
PATH_RESERVAS=Path(PATH_RESERVAS)

#==============================================
# Funções
#==============================================

# Função para criar tabela no banco de dados
def create_table(create_sql_table, nome_tabela:str):
    """
    Essa função se conecta ao banco de dados PostgreSQL e cria uma tabela, caso ela aainda não exista, na qual serão armazenados os dados da EcoViagens.

    Parâmetros:
    - create_sql_table: Script SQL para criar uma tabela.

    - nome_tabela: nome da tabela para identificação nas mensagens de sucesso/erro.

    Retorno:
    - A função não tem valor de retorno.
    """
    try:
        conn = psycopg2.connect(
                    dbname=os.getenv('DB_NAME'),
                    user=os.getenv('DB_USER'),
                    password=os.getenv('DB_PASSWORD'),
                    host=os.getenv('DB_HOST'),
                    port=os.getenv('DB_PORT')
                )
        with conn.cursor() as cur:
            cur.execute(create_sql_table)
            conn.commit()
            print(f"Tabela {nome_tabela} criada/verificada com sucesso!")
    except Exception as e:
        print(f'Erro ao criar/verificar tabela {nome_tabela} {e}')
    finally:
        if conn:
            conn.close()

# Função para carregar dados na tabela atividades
def load_data_atividades(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela atividades.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1], row[2], row[3]))
                    conn.commit()
            print('Carregamento na tabela atividades realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela avaliacoes
def load_data_avaliacoes(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela avaliacoes.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1], row[2], row[3], row[4], row[5]))
                    conn.commit()
            print('Carregamento na tabela avaliacoes realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela clientes
def load_data_clientes(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela clientes.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1], row[2], row[3], row[4], row[5]))
                    conn.commit()
            print('Carregamento na tabela clientes realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela hospedagens
def load_data_hospedagens(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela hospedagens.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1], row[2], row[3]))
                    conn.commit()
            print('Carregamento na tabela hospedagens realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela oferta_pratica
def load_data_oferta_pratica(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela oferta_pratica.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1]))
                    conn.commit()
            print('Carregamento na tabela oferta_pratica realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela ofertas
def load_data_ofertas(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela ofertas.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1], row[2], row[3], row[4], row[5]))
                    conn.commit()
            print('Carregamento na tabela ofertas realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela operadores
def load_data_operadores(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela operadores.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1], row[2], row[3], row[4], row[5]))
                    conn.commit()
            print('Carregamento na tabela operadores realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela praticas_sustentaveis
def load_data_praticas_sustentaveis(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela praticas_sustentaveis.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1]))
                    conn.commit()
            print('Carregamento na tabela praticas_sustentaveis realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

# Função para carregar dados na tabela reservas
def load_data_reservas(path, insert_data):
    """
    Essa função se conecta ao banco de dados PostgreSQL e carrega dados para a tabela reservas.
    Parâmetros:
    - path: caminho para o arquivo csv.
    - insert_data: script SQL para gravar os dados na tabela.

    Retorno:
    - A função não tem valor de retorno.
    """
    with open (path, 'r', encoding='utf-8') as file:

    # Criar um leitor de CSV
        reader = csv.reader(file)

        # Pular a primeira linha do CSV
        next(reader)

        try:
            conn=psycopg2.connect(
                        dbname=os.getenv('DB_NAME'),
                        user=os.getenv('DB_USER'),
                        password=os.getenv('DB_PASSWORD'),
                        host=os.getenv('DB_HOST'),
                        port=os.getenv('DB_PORT')
                    )
            # Inserir os dados do csv no banco de dados
            for row in reader:

                with conn.cursor() as cur:
                    cur.execute(insert_data, (row[0], row[1], row[2], row[3], row[4], row[5], row[6]))
                    conn.commit()
            print('Carregamento na tabela reservas realizado com sucesso!')
        except Exception as e:
            print(f'Erro ao carregar dados: {e}')
        finally:
            if conn:
                conn.close()

#----------------------------------------Execução----------------------------------------

if __name__=='__main__':
    # Criação das tabelas
    create_table(parameters.create_sql_table_atividades, "atividades")
    create_table(parameters.create_sql_table_avaliacoes, "avaliacoes")
    create_table(parameters.create_sql_table_clientes, "clientes")
    create_table(parameters.create_sql_table_hospedagens, "hospedagens")
    create_table(parameters.create_sql_table_oferta_pratica, "oferta_pratica")
    create_table(parameters.create_sql_table_ofertas, "ofertas")
    create_table(parameters.create_sql_table_operadores, "operadores")
    create_table(parameters.create_sql_table_praticas_sustentaveis, "praticas_sustentaveis")
    create_table(parameters.create_sql_table_reservas, "reservas")

    # Carga dos dados
    schedule.every().day.at('01:00').do(load_data_atividades, PATH_ATIVIDADES, parameters.insert_data_atividades)
    schedule.every().day.at('01:00').do(load_data_avaliacoes, PATH_AVALIACOES, parameters.insert_data_avaliacoes)
    schedule.every().day.at('01:00').do(load_data_clientes, PATH_CLIENTES, parameters.insert_data_clientes)
    schedule.every().day.at('01:00').do(load_data_hospedagens, PATH_HOSPEDAGENS, parameters.insert_data_hospedagens)
    schedule.every().day.at('01:00').do(load_data_oferta_pratica, PATH_OFERTA_PRATICA, parameters.insert_data_oferta_pratica)
    schedule.every().day.at('01:00').do(load_data_ofertas, PATH_OFERTAS, parameters.insert_data_ofertas)
    schedule.every().day.at('01:00').do(load_data_operadores, PATH_OPERADORES, parameters.insert_data_operadores)
    schedule.every().day.at('01:00').do(load_data_praticas_sustentaveis, PATH_PRATICAS_SUSTENTAVEIS, parameters.insert_data_praticas_sustentaveis)
    schedule.every().day.at('01:00').do(load_data_reservas, PATH_RESERVAS, parameters.insert_data_reservas)
    
    try:
        while True:
            schedule.run_pending()
    except KeyboardInterrupt:
        print('Execução foi interrompida pelo usuário.')