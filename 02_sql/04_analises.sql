SET search_path TO ecommerce_vendas;

-- 1) Visão geral: pedidos, faturamento, ticket médio
SELECT
    COUNT(*) AS total_pedidos,
    ROUND(SUM(valor_total)::numeric, 2) AS faturamento_total,
    ROUND(AVG(valor_total)::numeric, 2) AS ticket_medio,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY valor_total)::numeric, 2) AS ticket_mediano
FROM pedidos
WHERE status_entrega != 'Cancelado';

-- 2) Taxa de cancelamento e de atraso na entrega
SELECT
    COUNT(*) FILTER (WHERE status_entrega = 'Cancelado') AS pedidos_cancelados,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status_entrega = 'Cancelado') / COUNT(*), 2) AS pct_cancelado,
    COUNT(*) FILTER (WHERE status_entrega = 'Entregue com Atraso') AS pedidos_atrasados,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status_entrega = 'Entregue com Atraso') / COUNT(*), 2) AS pct_atrasado
FROM pedidos;

-- 3) Faturamento por categoria de produto (CTE + JOIN)
WITH vendas_categoria AS (
    SELECT pr.categoria, SUM(ip.subtotal) AS faturamento, COUNT(DISTINCT ip.pedido_id) AS pedidos
    FROM itens_pedido ip
    JOIN produtos pr ON pr.produto_id = ip.produto_id
    JOIN pedidos pe ON pe.pedido_id = ip.pedido_id
    WHERE pe.status_entrega != 'Cancelado'
    GROUP BY pr.categoria
)
SELECT categoria, faturamento, pedidos,
       ROUND(100.0 * faturamento / SUM(faturamento) OVER (), 2) AS pct_faturamento,
       RANK() OVER (ORDER BY faturamento DESC) AS ranking
FROM vendas_categoria
ORDER BY faturamento DESC;

-- 4) Faturamento por forma de pagamento
SELECT forma_pagamento,
       COUNT(*) AS pedidos,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_pedidos,
       ROUND(SUM(valor_total), 2) AS faturamento
FROM pedidos
WHERE status_entrega != 'Cancelado'
GROUP BY forma_pagamento
ORDER BY faturamento DESC;

-- 5) Faturamento e ticket médio por região do cliente
SELECT c.regiao,
       COUNT(DISTINCT p.pedido_id) AS pedidos,
       ROUND(SUM(p.valor_total), 2) AS faturamento,
       ROUND(AVG(p.valor_total), 2) AS ticket_medio
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id
WHERE p.status_entrega != 'Cancelado'
GROUP BY c.regiao
ORDER BY faturamento DESC;

-- 6) Recompra: clientes com mais de 1 pedido (window function)
WITH pedidos_por_cliente AS (
    SELECT cliente_id, COUNT(*) AS n_pedidos
    FROM pedidos
    WHERE status_entrega != 'Cancelado'
    GROUP BY cliente_id
)
SELECT
    COUNT(*) FILTER (WHERE n_pedidos > 1) AS clientes_recompra,
    COUNT(*) AS total_clientes_com_pedido,
    ROUND(100.0 * COUNT(*) FILTER (WHERE n_pedidos > 1) / COUNT(*), 2) AS pct_recompra
FROM pedidos_por_cliente;

-- 7) Top 10 clientes por valor gasto (window function RANK)
SELECT cliente_id, total_gasto, ranking FROM (
    SELECT cliente_id,
           SUM(valor_total) AS total_gasto,
           RANK() OVER (ORDER BY SUM(valor_total) DESC) AS ranking
    FROM pedidos
    WHERE status_entrega != 'Cancelado'
    GROUP BY cliente_id
) t
WHERE ranking <= 10;

-- 8) Evolução mensal de faturamento
SELECT ano_mes,
       COUNT(*) AS pedidos,
       ROUND(SUM(valor_total), 2) AS faturamento
FROM pedidos
WHERE status_entrega != 'Cancelado'
GROUP BY ano_mes
ORDER BY ano_mes;

-- 9) Desconto médio aplicado por categoria
SELECT pr.categoria,
       ROUND(AVG(ip.desconto_pct), 2) AS desconto_medio_pct
FROM itens_pedido ip
JOIN produtos pr ON pr.produto_id = ip.produto_id
GROUP BY pr.categoria
ORDER BY desconto_medio_pct DESC;

-- 10) Canal de aquisição x ticket médio do cliente
SELECT c.canal_aquisicao,
       COUNT(DISTINCT c.cliente_id) AS clientes,
       ROUND(AVG(p.valor_total), 2) AS ticket_medio
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.status_entrega != 'Cancelado'
GROUP BY c.canal_aquisicao
ORDER BY ticket_medio DESC;
