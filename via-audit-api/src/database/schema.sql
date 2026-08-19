-- Schema do Banco de Dados MySQL para o Via Audit

CREATE TABLE IF NOT EXISTS orientadores (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nome        VARCHAR(150) NOT NULL,
  email       VARCHAR(150),
  pin         CHAR(6) NOT NULL UNIQUE,
  ativo       TINYINT(1) DEFAULT 1,
  criado_em   DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS escolas (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  nome            VARCHAR(200) NOT NULL,
  cidade          VARCHAR(100),
  estado          CHAR(2),
  codigo          VARCHAR(20) UNIQUE,
  lat             DECIMAL(10,7),
  lng             DECIMAL(10,7),
  criado_em       DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orientador_escola (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  orientador_id   INT NOT NULL,
  escola_id       INT NOT NULL,
  data_visita_agendada DATE,
  status          ENUM('pendente','em_andamento','concluida') DEFAULT 'pendente',
  FOREIGN KEY (orientador_id) REFERENCES orientadores(id),
  FOREIGN KEY (escola_id) REFERENCES escolas(id),
  UNIQUE KEY uq_oe (orientador_id, escola_id)
);

CREATE TABLE IF NOT EXISTS ativos (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  escola_id       INT NOT NULL,
  descricao       VARCHAR(250) NOT NULL,
  quantidade      INT NOT NULL DEFAULT 1,
  nf              VARCHAR(50),
  origem          ENUM('historico','extra') DEFAULT 'historico',
  criado_em       DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (escola_id) REFERENCES escolas(id)
);

CREATE TABLE IF NOT EXISTS visitas (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  orientador_id   INT NOT NULL,
  escola_id       INT NOT NULL,
  status          ENUM('em_andamento','concluida') DEFAULT 'em_andamento',
  iniciada_em     DATETIME DEFAULT CURRENT_TIMESTAMP,
  concluida_em    DATETIME,
  assinatura_url  VARCHAR(500),
  observacao_geral TEXT,
  FOREIGN KEY (orientador_id) REFERENCES orientadores(id),
  FOREIGN KEY (escola_id) REFERENCES escolas(id)
);

CREATE TABLE IF NOT EXISTS registros (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  visita_id           INT NOT NULL,
  ativo_id            INT NOT NULL,
  unidade_numero      INT NOT NULL DEFAULT 1,
  status              ENUM('ok','avariado','nao_encontrado','extra') NOT NULL,
  patrimonio_fisico   VARCHAR(50),
  foto_url            VARCHAR(500),
  lat                 DECIMAL(10,7),
  lng                 DECIMAL(10,7),
  observacao          TEXT,
  sincronizado        TINYINT(1) DEFAULT 0,
  criado_em           DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (visita_id) REFERENCES visitas(id),
  FOREIGN KEY (ativo_id) REFERENCES ativos(id)
);

-- Inserção de dados de seed
INSERT INTO orientadores (id, nome, email, pin, ativo) VALUES 
(7, 'Daniela Moreira', 'daniela@viaeducation.com.br', '724123', 1)
ON DUPLICATE KEY UPDATE nome=VALUES(nome);

INSERT INTO escolas (id, nome, cidade, estado, codigo, lat, lng) VALUES 
(1, 'Colégio Álamo Vinhedo', 'Vinhedo', 'SP', '023448', -23.03, -46.97),
(2, 'E.E. Maria José da Silva', 'São Paulo', 'SP', '018922', -23.5505, -46.6333),
(3, 'E.M. Prof. Antônio Carlos', 'Guarulhos', 'SP', '099120', -23.4542, -46.5337)
ON DUPLICATE KEY UPDATE nome=VALUES(nome);

INSERT INTO orientador_escola (orientador_id, escola_id, data_visita_agendada, status) VALUES 
(7, 1, '2026-06-12', 'pendente'),
(7, 2, '2026-06-11', 'em_andamento'),
(7, 3, '2026-06-10', 'concluida')
ON DUPLICATE KEY UPDATE status=VALUES(status);

INSERT INTO ativos (id, escola_id, descricao, quantidade, nf, origem) VALUES 
(10, 1, 'Conjunto Spike Prime', 1, '17373', 'historico'),
(11, 1, 'Notebook Asus X515KA', 10, '17233', 'historico'),
(12, 1, 'Projetor Epson PowerLite', 2, '18992', 'historico'),
(13, 2, 'Chromebook Lenovo N23', 10, '48291', 'historico'),
(14, 2, 'Roteador Cisco Meraki', 1, '60119', 'historico')
ON DUPLICATE KEY UPDATE descricao=VALUES(descricao);
