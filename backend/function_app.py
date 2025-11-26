import azure.functions as func
import logging
import json
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import List, Dict

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

def get_db_connection():
    """
    Cria conexão com o banco PostgreSQL usando variáveis de ambiente.
    """
    try:
        connection = psycopg2.connect(
            host=os.environ.get('POSTGRES_HOST'),
            user=os.environ.get('POSTGRES_USER'),
            password=os.environ.get('POSTGRES_PASSWORD'),
            database=os.environ.get('POSTGRES_DATABASE'),
            port=int(os.environ.get('POSTGRES_PORT', 5432)),
            sslmode='require',
            cursor_factory=RealDictCursor
        )
        return connection
    except Exception as e:
        logging.error(f"Erro ao conectar ao banco de dados: {str(e)}")
        raise

def format_obra(obra: Dict) -> Dict:
    """
    Formata os dados da obra para o formato JSON da API.
    """
    return {
        'id': obra['id'],
        'nome': obra['nome'],
        'artista': obra['artista'],
        'descricao': obra['descricao'],
        'ano': obra['ano_criacao'],
        'imagem': obra['url_imagem'],
        'estilo': obra['estilo']
    }

@app.route(route="obras", methods=["GET"])
def listar_obras(req: func.HttpRequest) -> func.HttpResponse:
    """
    Endpoint principal: retorna lista de todas as obras da galeria.
    
    GET /api/obras
    """
    logging.info('Processando requisição para listar obras')
    
    try:
        # Conectar ao banco
        connection = get_db_connection()
        
        with connection.cursor() as cursor:
            # Buscar todas as obras
            sql = """
                SELECT 
                    id, nome, artista, descricao, 
                    ano_criacao, url_imagem, estilo
                FROM obras
                ORDER BY ano_criacao DESC
            """
            cursor.execute(sql)
            obras = cursor.fetchall()
        
        connection.close()
        
        # Formatar resposta
        obras_formatadas = [format_obra(obra) for obra in obras]
        
        logging.info(f'Retornando {len(obras_formatadas)} obras')
        
        return func.HttpResponse(
            body=json.dumps(obras_formatadas, ensure_ascii=False),
            mimetype="application/json",
            status_code=200,
            headers={
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            }
        )
        
    except Exception as e:
        logging.error(f'Erro ao buscar obras: {str(e)}')
        return func.HttpResponse(
            body=json.dumps({
                'error': 'Erro ao buscar obras',
                'message': str(e)
            }),
            mimetype="application/json",
            status_code=500
        )

@app.route(route="obras/{id:int}", methods=["GET"])
def obter_obra(req: func.HttpRequest) -> func.HttpResponse:
    """
    Endpoint para obter uma obra específica por ID.
    
    GET /api/obras/{id}
    """
    obra_id = req.route_params.get('id')
    logging.info(f'Buscando obra com ID: {obra_id}')
    
    try:
        connection = get_db_connection()
        
        with connection.cursor() as cursor:
            sql = """
                SELECT 
                    id, nome, artista, descricao, 
                    ano_criacao, url_imagem, estilo
                FROM obras
                WHERE id = %s
            """
            cursor.execute(sql, (obra_id,))
            obra = cursor.fetchone()
        
        connection.close()
        
        if obra:
            return func.HttpResponse(
                body=json.dumps(format_obra(obra), ensure_ascii=False),
                mimetype="application/json",
                status_code=200,
                headers={'Access-Control-Allow-Origin': '*'}
            )
        else:
            return func.HttpResponse(
                body=json.dumps({'error': 'Obra não encontrada'}),
                mimetype="application/json",
                status_code=404,
                headers={'Access-Control-Allow-Origin': '*'}
            )
            
    except Exception as e:
        logging.error(f'Erro ao buscar obra: {str(e)}')
        return func.HttpResponse(
            body=json.dumps({
                'error': 'Erro ao buscar obra',
                'message': str(e)
            }),
            mimetype="application/json",
            status_code=500
        )

@app.route(route="obras/artista/{artista}", methods=["GET"])
def obras_por_artista(req: func.HttpRequest) -> func.HttpResponse:
    """
    Endpoint para buscar obras por artista.
    
    GET /api/obras/artista/{artista}
    """
    artista = req.route_params.get('artista')
    logging.info(f'Buscando obras do artista: {artista}')
    
    try:
        connection = get_db_connection()
        
        with connection.cursor() as cursor:
            sql = """
                SELECT 
                    id, nome, artista, descricao, 
                    ano_criacao, url_imagem, estilo
                FROM obras
                WHERE artista LIKE %s
                ORDER BY ano_criacao DESC
            """
            cursor.execute(sql, (f'%{artista}%',))
            obras = cursor.fetchall()
        
        connection.close()
        
        obras_formatadas = [format_obra(obra) for obra in obras]
        
        return func.HttpResponse(
            body=json.dumps(obras_formatadas, ensure_ascii=False),
            mimetype="application/json",
            status_code=200,
            headers={'Access-Control-Allow-Origin': '*'}
        )
        
    except Exception as e:
        logging.error(f'Erro ao buscar obras por artista: {str(e)}')
        return func.HttpResponse(
            body=json.dumps({
                'error': 'Erro ao buscar obras',
                'message': str(e)
            }),
            mimetype="application/json",
            status_code=500
        )

@app.route(route="obras/estilo/{estilo}", methods=["GET"])
def obras_por_estilo(req: func.HttpRequest) -> func.HttpResponse:
    """
    Endpoint para buscar obras por estilo artístico.
    
    GET /api/obras/estilo/{estilo}
    """
    estilo = req.route_params.get('estilo')
    logging.info(f'Buscando obras do estilo: {estilo}')
    
    try:
        connection = get_db_connection()
        
        with connection.cursor() as cursor:
            sql = """
                SELECT 
                    id, nome, artista, descricao, 
                    ano_criacao, url_imagem, estilo
                FROM obras
                WHERE estilo LIKE %s
                ORDER BY ano_criacao DESC
            """
            cursor.execute(sql, (f'%{estilo}%',))
            obras = cursor.fetchall()
        
        connection.close()
        
        obras_formatadas = [format_obra(obra) for obra in obras]
        
        return func.HttpResponse(
            body=json.dumps(obras_formatadas, ensure_ascii=False),
            mimetype="application/json",
            status_code=200,
            headers={'Access-Control-Allow-Origin': '*'}
        )
        
    except Exception as e:
        logging.error(f'Erro ao buscar obras por estilo: {str(e)}')
        return func.HttpResponse(
            body=json.dumps({
                'error': 'Erro ao buscar obras',
                'message': str(e)
            }),
            mimetype="application/json",
            status_code=500
        )

@app.route(route="health", methods=["GET"])
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """
    Endpoint de health check para verificar status da API e conexão com banco.
    
    GET /api/health
    """
    logging.info('Health check requisitado')
    
    status = {
        'status': 'healthy',
        'service': 'Galeria de Artes API',
        'database': 'disconnected'
    }
    
    try:
        # Testar conexão com banco
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        connection.close()
        status['database'] = 'connected'
        
    except Exception as e:
        logging.error(f'Erro no health check: {str(e)}')
        status['status'] = 'unhealthy'
        status['error'] = str(e)
        
        return func.HttpResponse(
            body=json.dumps(status),
            mimetype="application/json",
            status_code=503
        )
    
    return func.HttpResponse(
        body=json.dumps(status),
        mimetype="application/json",
        status_code=200,
        headers={'Access-Control-Allow-Origin': '*'}
    )
