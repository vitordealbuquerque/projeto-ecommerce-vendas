SET search_path TO ecommerce_vendas;

-- checar nulos
SELECT
    SUM(CASE WHEN regiao IS NULL THEN 1 ELSE 0 END) AS clientes_regiao_nula,
    SUM(CASE WHEN canal_aquisicao IS NULL THEN 1 ELSE 0 END) AS clientes_canal_nulo
FROM clientes;

SELECT COUNT(*) AS pedidos_valor_zero FROM pedidos WHERE valor_total = 0;

-- outliers de valor_total (acima do p99)
SELECT percentile_cont(0.99) WITHIN GROUP (ORDER BY valor_total) AS p99_valor_total FROM pedidos;

-- colunas derivadas
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS ano_mes VARCHAR(7);
UPDATE pedidos SET ano_mes = TO_CHAR(data_pedido, 'YYYY-MM');

ALTER TABLE clientes ADD COLUMN IF NOT EXISTS ano_mes_cadastro VARCHAR(7);
UPDATE clientes SET ano_mes_cadastro = TO_CHAR(data_cadastro, 'YYYY-MM');

-- remover pedidos cancelados sem nenhum item (integridade)
DELETE FROM pedidos p
WHERE NOT EXISTS (SELECT 1 FROM itens_pedido i WHERE i.pedido_id = p.pedido_id);

SELECT 'pedidos_apos_limpeza' AS check, COUNT(*) FROM pedidos;
