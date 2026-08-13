import random
import csv
from datetime import datetime, timedelta

random.seed(42)

N_CLIENTES = 1800
N_PRODUTOS = 120
N_PEDIDOS = 9500

CATEGORIAS = ["Eletronicos", "Moda", "Casa e Decoracao", "Beleza", "Esporte e Lazer", "Livros", "Brinquedos", "Pet Shop"]
REGIOES = ["Sudeste", "Sul", "Nordeste", "Centro-Oeste", "Norte"]
CANAIS = ["Organico", "Marketing Pago", "Redes Sociais", "Indicacao", "Email Marketing"]
PAGAMENTOS = ["Cartao de Credito", "Pix", "Boleto", "Cartao de Debito"]
STATUS_ENTREGA = ["Entregue", "Entregue com Atraso", "Em Transito", "Cancelado"]

data_inicio = datetime(2024, 8, 1)
data_fim = datetime(2026, 7, 31)

def data_aleatoria():
    delta = data_fim - data_inicio
    dias = random.randint(0, delta.days)
    return data_inicio + timedelta(days=dias)

# ---------- clientes ----------
clientes = []
for cid in range(1, N_CLIENTES + 1):
    regiao = random.choices(REGIOES, weights=[45, 20, 20, 10, 5])[0]
    canal = random.choices(CANAIS, weights=[30, 25, 20, 15, 10])[0]
    data_cadastro = data_aleatoria()
    clientes.append({
        "cliente_id": cid,
        "regiao": regiao,
        "canal_aquisicao": canal,
        "data_cadastro": data_cadastro.strftime("%Y-%m-%d"),
    })

with open("03_dados/clientes.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=clientes[0].keys(), delimiter=";")
    w.writeheader()
    w.writerows(clientes)

# ---------- produtos ----------
produtos = []
for pid in range(1, N_PRODUTOS + 1):
    categoria = random.choice(CATEGORIAS)
    preco_base = round(random.lognormvariate(3.8, 0.9), 2)
    preco_base = max(15.0, min(preco_base, 2500.0))
    produtos.append({
        "produto_id": pid,
        "categoria": categoria,
        "preco_unitario": preco_base,
    })

with open("03_dados/produtos.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=produtos[0].keys(), delimiter=";")
    w.writeheader()
    w.writerows(produtos)

# ---------- pedidos + itens_pedido ----------
pedidos = []
itens = []
item_id = 1

# pesos de cliente: alguns compram mais que outros (Pareto-like)
pesos_clientes = [random.paretovariate(1.5) for _ in range(N_CLIENTES)]

for pedido_id in range(1, N_PEDIDOS + 1):
    cliente = random.choices(clientes, weights=pesos_clientes)[0]
    data_pedido = data_aleatoria()
    pagamento = random.choices(PAGAMENTOS, weights=[40, 35, 15, 10])[0]
    status = random.choices(STATUS_ENTREGA, weights=[70, 16, 8, 6])[0]

    n_itens = random.choices([1, 2, 3, 4, 5], weights=[45, 28, 15, 8, 4])[0]
    produtos_pedido = random.sample(produtos, min(n_itens, len(produtos)))

    valor_total = 0.0
    for prod in produtos_pedido:
        qtd = random.choices([1, 2, 3], weights=[75, 18, 7])[0]
        desconto_pct = random.choices([0, 5, 10, 15, 20], weights=[55, 20, 12, 8, 5])[0]
        preco_unit = prod["preco_unitario"]
        subtotal = round(preco_unit * qtd * (1 - desconto_pct / 100), 2)
        valor_total += subtotal
        itens.append({
            "item_id": item_id,
            "pedido_id": pedido_id,
            "produto_id": prod["produto_id"],
            "quantidade": qtd,
            "desconto_pct": desconto_pct,
            "subtotal": subtotal,
        })
        item_id += 1

    pedidos.append({
        "pedido_id": pedido_id,
        "cliente_id": cliente["cliente_id"],
        "data_pedido": data_pedido.strftime("%Y-%m-%d"),
        "forma_pagamento": pagamento,
        "status_entrega": status,
        "valor_total": round(valor_total, 2),
    })

with open("03_dados/pedidos.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=pedidos[0].keys(), delimiter=";")
    w.writeheader()
    w.writerows(pedidos)

with open("03_dados/itens_pedido.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=itens[0].keys(), delimiter=";")
    w.writeheader()
    w.writerows(itens)

print(f"clientes: {len(clientes)}")
print(f"produtos: {len(produtos)}")
print(f"pedidos: {len(pedidos)}")
print(f"itens_pedido: {len(itens)}")
