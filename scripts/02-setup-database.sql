-- ========================================
-- Script de Setup do Banco de Dados
-- Galeria de Artes Online
-- ========================================

-- Conectar ao banco usando:
-- mysql -h SEU_MYSQL_SERVER.mysql.database.azure.com -u adminarte -p galeria_db

USE galeria_db;

-- ========================================
-- 1. CRIAR TABELA DE OBRAS
-- ========================================

DROP TABLE IF EXISTS obras;

CREATE TABLE obras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    artista VARCHAR(255) NOT NULL,
    descricao TEXT,
    ano_criacao INT,
    url_imagem VARCHAR(500) NOT NULL,
    estilo VARCHAR(100),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_artista (artista),
    INDEX idx_estilo (estilo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 2. INSERIR OBRAS DE EXEMPLO
-- ========================================

-- Nota: Substitua as URLs das imagens após fazer upload no Blob Storage
-- Formato: https://SEU_STORAGE_ACCOUNT.blob.core.windows.net/obras/NOME_ARQUIVO.jpg

INSERT INTO obras (nome, artista, descricao, ano_criacao, url_imagem, estilo) VALUES
('Mona Lisa', 'Leonardo da Vinci', 
 'Pintura a óleo sobre madeira de álamo, considerada a obra mais famosa da história da arte. Retrato de Lisa Gherardini com seu enigmático sorriso.', 
 1503, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/monalisa.jpg', 
 'Renascimento'),

('A Noite Estrelada', 'Vincent van Gogh', 
 'Pintura a óleo que representa a vista da janela do quarto de Van Gogh no sanatório de Saint-Rémy-de-Provence, com um céu turbulento e vilarejo noturno.', 
 1889, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/noite-estrelada.jpg', 
 'Pós-Impressionismo'),

('O Grito', 'Edvard Munch', 
 'Expressionista obra que retrata uma figura andrógina em um momento de profunda angústia e desespero existencial.', 
 1893, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/o-grito.jpg', 
 'Expressionismo'),

('Guernica', 'Pablo Picasso', 
 'Mural anti-guerra pintado como reação ao bombardeio da cidade basca de Guernica durante a Guerra Civil Espanhola.', 
 1937, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/guernica.jpg', 
 'Cubismo'),

('A Persistência da Memória', 'Salvador Dalí', 
 'Pintura surrealista famosa por seus relógios derretidos em uma paisagem onírica, explorando conceitos de tempo e memória.', 
 1931, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/persistencia-memoria.jpg', 
 'Surrealismo'),

('A Criação de Adão', 'Michelangelo', 
 'Afresco pintado no teto da Capela Sistina, retratando o momento bíblico em que Deus dá vida a Adão.', 
 1512, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/criacao-adao.jpg', 
 'Renascimento'),

('Moça com Brinco de Pérola', 'Johannes Vermeer', 
 'Pintura a óleo sobre tela conhecida como a "Mona Lisa do Norte", retratando uma jovem com um brinco de pérola exótico.', 
 1665, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/moca-perola.jpg', 
 'Barroco'),

('O Beijo', 'Gustav Klimt', 
 'Pintura a óleo com folhas de ouro, representando um casal abraçado, envolto em elaborados padrões decorativos.', 
 1908, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/o-beijo.jpg', 
 'Art Nouveau'),

('Abaporu', 'Tarsila do Amaral', 
 'Pintura modernista brasileira que representa uma figura humana com pés enormes, símbolo do movimento antropofágico.', 
 1928, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/abaporu.jpg', 
 'Modernismo Brasileiro'),

('Almoço na Relva', 'Édouard Manet', 
 'Pintura controversa que mostra uma mulher nua almoçando com homens vestidos, desafiando convenções sociais da época.', 
 1863, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/almoco-relva.jpg', 
 'Realismo'),

('As Meninas', 'Diego Velázquez', 
 'Complexa composição que mostra a Infanta Margarida Teresa cercada por suas damas de companhia, com o próprio pintor no quadro.', 
 1656, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/as-meninas.jpg', 
 'Barroco'),

('Nenúfares', 'Claude Monet', 
 'Série de aproximadamente 250 pinturas a óleo retratando o jardim de flores em Giverny, explorando luz e reflexos.', 
 1920, 
 'https://STORAGE_ACCOUNT.blob.core.windows.net/obras/nenufares.jpg', 
 'Impressionismo');

-- ========================================
-- 3. CONSULTAS DE VALIDAÇÃO
-- ========================================

-- Verificar todas as obras
SELECT * FROM obras ORDER BY ano_criacao;

-- Contar obras por estilo
SELECT estilo, COUNT(*) as total 
FROM obras 
GROUP BY estilo 
ORDER BY total DESC;

-- Listar obras por artista
SELECT artista, COUNT(*) as total_obras 
FROM obras 
GROUP BY artista 
ORDER BY artista;

-- ========================================
-- 4. PROCEDURE PARA ATUALIZAR URLs
-- ========================================

DELIMITER //

CREATE PROCEDURE atualizar_urls_obras(
    IN p_storage_account VARCHAR(100)
)
BEGIN
    UPDATE obras 
    SET url_imagem = CONCAT(
        'https://', 
        p_storage_account, 
        '.blob.core.windows.net/obras/',
        LOWER(REPLACE(REPLACE(nome, ' ', '-'), 'ã', 'a')),
        '.jpg'
    );
END //

DELIMITER ;

-- Para usar a procedure após criar o Storage Account:
-- CALL atualizar_urls_obras('SEU_STORAGE_ACCOUNT_NAME');

-- ========================================
-- 5. VIEWS ÚTEIS
-- ========================================

-- View para API - retorna dados formatados
CREATE OR REPLACE VIEW vw_obras_api AS
SELECT 
    id,
    nome,
    artista,
    descricao,
    ano_criacao AS ano,
    url_imagem AS imagem,
    estilo,
    DATE_FORMAT(data_cadastro, '%Y-%m-%d') AS data_cadastro
FROM obras
ORDER BY ano_criacao DESC;

-- Testar view
SELECT * FROM vw_obras_api;

-- ========================================
-- SCRIPT CONCLUÍDO
-- ========================================
