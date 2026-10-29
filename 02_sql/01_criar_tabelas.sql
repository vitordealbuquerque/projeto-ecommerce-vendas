-- Schema ecommerce_vendas: clientes, produtos, pedidos e itens de pedido.
-- Cada pedido pertence a um cliente e tem um ou mais itens; cada item aponta para um produto.
-- Colunas categoricas (regiao, canal, categoria, pagamento, status) tem CHECK com os valores usados nos CSVs.
-- Os valores nao levam acento, como nos arquivos de 03_dados.
-- Rodar a partir da raiz do repositorio. O script recria o schema do zero.

DROP SCHEMA IF EXISTS ecommerce_vendas CASCADE;
CREATE SCHEMA ecommerce_vendas;
SET search_path TO ecommerce_vendas;

CREATE TABLE clientes (
  cliente_id INT PRIMARY KEY,
  regiao VARCHAR(20) NOT NULL CHECK (regiao IN ('Norte','Nordeste','Centro-Oeste','Sudeste','Sul')),
  canal_aquisicao VARCHAR(30) NOT NULL CHECK (canal_aquisicao IN ('Organico','Indicacao','Marketing Pago','Redes Sociais','Email Marketing')),
  data_cadastro DATE NOT NULL
);

CREATE TABLE produtos (
  produto_id INT PRIMARY KEY,
  categoria VARCHAR(30) NOT NULL CHECK (categoria IN ('Beleza','Brinquedos','Casa e Decoracao','Eletronicos','Esporte e Lazer','Livros','Moda','Pet Shop')),
  preco_unitario NUMERIC(10,2) NOT NULL
);

CREATE TABLE pedidos (
  pedido_id INT PRIMARY KEY,
  cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
  data_pedido DATE NOT NULL,
  forma_pagamento VARCHAR(30) NOT NULL CHECK (forma_pagamento IN ('Boleto','Cartao de Credito','Cartao de Debito','Pix')),
  status_entrega VARCHAR(30) NOT NULL CHECK (status_entrega IN ('Cancelado','Em Transito','Entregue','Entregue com Atraso')),
  valor_total NUMERIC(12,2) NOT NULL
);

CREATE TABLE itens_pedido (
  item_id INT PRIMARY KEY,
  pedido_id INT NOT NULL REFERENCES pedidos(pedido_id),
  produto_id INT NOT NULL REFERENCES produtos(produto_id),
  quantidade INT NOT NULL,
  desconto_pct NUMERIC(5,2) NOT NULL,
  subtotal NUMERIC(12,2) NOT NULL
);
