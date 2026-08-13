SET search_path TO ecommerce_vendas;

\copy clientes FROM '03_dados/clientes.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');
\copy produtos FROM '03_dados/produtos.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');
\copy pedidos FROM '03_dados/pedidos.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');
\copy itens_pedido FROM '03_dados/itens_pedido.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

SELECT 'clientes' AS tabela, COUNT(*) FROM clientes
UNION ALL SELECT 'produtos', COUNT(*) FROM produtos
UNION ALL SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL SELECT 'itens_pedido', COUNT(*) FROM itens_pedido;
