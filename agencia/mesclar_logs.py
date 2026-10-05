import glob
import json
import os
import sys

PASTA_DADOS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")


def comparar_vetores(v1, v2):
    v1_menor_ou_igual = all(a <= b for a, b in zip(v1, v2))
    v2_menor_ou_igual = all(b <= a for a, b in zip(v1, v2))
    if v1_menor_ou_igual and v2_menor_ou_igual:
        return "IGUAIS"
    if v1_menor_ou_igual:
        return "ANTES"
    if v2_menor_ou_igual:
        return "DEPOIS"
    return "CONCORRENTES"


padrao = "auditoria.jsonl" if "--central" in sys.argv else "eventos-*.jsonl"
todos_eventos = []
for arquivo in glob.glob(os.path.join(PASTA_DADOS, padrao)):
    with open(arquivo, encoding="utf-8") as f:
        for linha in f:
            linha = linha.strip()
            if linha:
                evento = json.loads(linha)
                if "timestampVetorial" in evento:
                    todos_eventos.append(evento)

todos_eventos.sort(key=lambda e: e["horaParede"])

print("=== Linha do tempo (ordenada por hora de parede) ===")
for evento in todos_eventos:
    print(
        f"[{evento['agencia']}] vetor={evento['timestampVetorial']} {evento['tipo']} "
        f"{json.dumps(evento['detalhes'], ensure_ascii=False)}"
    )

print("\n=== Pares de eventos CONCORRENTES entre agências diferentes ===")
encontrou = False
for i, e1 in enumerate(todos_eventos):
    for e2 in todos_eventos[i + 1:]:
        if e1["agencia"] == e2["agencia"]:
            continue
        if comparar_vetores(e1["timestampVetorial"], e2["timestampVetorial"]) == "CONCORRENTES":
            encontrou = True
            print(
                f"[{e1['agencia']}] {e1['tipo']} ({e1['timestampVetorial']}) x "
                f"[{e2['agencia']}] {e2['tipo']} ({e2['timestampVetorial']})"
            )

if not encontrou:
    print("(nenhum par concorrente encontrado nesta execução - gere mais eventos em paralelo e rode de novo)")
