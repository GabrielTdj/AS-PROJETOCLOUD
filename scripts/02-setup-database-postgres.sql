-- ========================================
-- Script de Setup do Banco PostgreSQL
-- Galeria de Artes Online
-- ========================================

-- Criar tabela de obras
CREATE TABLE IF NOT EXISTS obras (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    artista VARCHAR(255) NOT NULL,
    descricao TEXT,
    ano_criacao INTEGER,
    url_imagem VARCHAR(500),
    estilo VARCHAR(100),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir 12 obras famosas
INSERT INTO obras (nome, artista, descricao, ano_criacao, url_imagem, estilo) VALUES
('Mona Lisa', 'Leonardo da Vinci', 'O retrato mais famoso do mundo, conhecido por seu sorriso enigmático e técnica revolucionária de sfumato.', 1503, 'https://stgaleria89234.blob.core.windows.net/obras/mona-lisa.jpg', 'Renascimento'),
('A Noite Estrelada', 'Vincent van Gogh', 'Uma das obras mais reconhecidas da arte moderna, retratando um céu noturno turbulento sobre uma vila francesa.', 1889, 'https://stgaleria89234.blob.core.windows.net/obras/noite-estrelada.jpg', 'Pós-Impressionismo'),
('O Grito', 'Edvard Munch', 'Ícone do expressionismo, representa a angústia e o desespero humano através de cores vibrantes e linhas onduladas.', 1893, 'https://stgaleria89234.blob.core.windows.net/obras/o-grito.jpg', 'Expressionismo'),
('Guernica', 'Pablo Picasso', 'Poderosa denúncia contra a guerra, criada em resposta ao bombardeio da cidade basca durante a Guerra Civil Espanhola.', 1937, 'https://stgaleria89234.blob.core.windows.net/obras/guernica.jpg', 'Cubismo'),
('A Persistência da Memória', 'Salvador Dalí', 'Obra icônica do surrealismo, famosa pelos relógios derretidos que desafiam nossa percepção do tempo.', 1931, 'https://stgaleria89234.blob.core.windows.net/obras/persistencia-memoria.jpg', 'Surrealismo'),
('A Criação de Adão', 'Michelangelo', 'Afresco monumental no teto da Capela Sistina, representando o momento em que Deus dá vida a Adão.', 1512, 'https://stgaleria89234.blob.core.windows.net/obras/criacao-adao.jpg', 'Renascimento'),
('Moça com Brinco de Pérola', 'Johannes Vermeer', 'Conhecida como a Mona Lisa do Norte, esta obra-prima holandesa captura um momento íntimo e misterioso.', 1665, 'https://stgaleria89234.blob.core.windows.net/obras/moca-brinco-perola.jpg', 'Barroco'),
('O Nascimento de Vênus', 'Sandro Botticelli', 'Representa a deusa Vênus emergindo do mar, simbolizando o amor e a beleza divina no Renascimento.', 1485, 'https://stgaleria89234.blob.core.windows.net/obras/nascimento-venus.jpg', 'Renascimento'),
('Os Girassóis', 'Vincent van Gogh', 'Série de pinturas de girassóis amarelos, demonstrando a maestria de Van Gogh no uso de cores vibrantes.', 1888, 'https://stgaleria89234.blob.core.windows.net/obras/girassois.jpg', 'Pós-Impressionismo'),
('A Última Ceia', 'Leonardo da Vinci', 'Afresco monumental retratando a última refeição de Jesus com seus apóstolos antes da crucificação.', 1498, 'https://stgaleria89234.blob.core.windows.net/obras/ultima-ceia.jpg', 'Renascimento'),
('O Beijo', 'Gustav Klimt', 'Obra-prima do simbolismo, representa um casal em um abraço íntimo, decorado com padrões dourados elaborados.', 1908, 'https://stgaleria89234.blob.core.windows.net/obras/o-beijo.jpg', 'Simbolismo'),
('Abaporu', 'Tarsila do Amaral', 'Ícone do modernismo brasileiro, representa uma figura solitária com proporções distorcidas.', 1928, 'https://stgaleria89234.blob.core.windows.net/obras/abaporu.jpg', 'Modernismo');

-- Criar índices para melhorar performance
CREATE INDEX idx_obras_artista ON obras(artista);
CREATE INDEX idx_obras_estilo ON obras(estilo);

-- Criar view para API
CREATE OR REPLACE VIEW vw_obras_api AS
SELECT 
    id,
    nome,
    artista,
    descricao,
    ano_criacao,
    url_imagem,
    estilo,
    data_cadastro
FROM obras
ORDER BY data_cadastro DESC;

-- Verificar dados inseridos
SELECT COUNT(*) as total_obras FROM obras;
SELECT * FROM obras LIMIT 3;
