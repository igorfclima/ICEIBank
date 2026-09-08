"use client";

import { useState } from "react";
import { AGENCIAS } from "@/lib/config";
import { Marca } from "@/components/Marca";
import { Banner, Botao, Campo } from "./ui";
import type { useBanco } from "@/hooks/useBanco";

const moeda = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" });

type Banco = ReturnType<typeof useBanco>;

export function Painel(b: Banco) {
  const [consultaId, setConsultaId] = useState("");
  const [movId, setMovId] = useState("");
  const [movValor, setMovValor] = useState("");
  const [origem, setOrigem] = useState("");
  const [destino, setDestino] = useState("");
  const [valor, setValor] = useState("");

  return (
    <div className="mx-auto max-w-5xl px-5 py-8">
      <header className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <Marca />
        <div className="flex flex-wrap items-center gap-3">
          <label className="flex items-center gap-2 text-xs text-texto-fraco">
            Agência de entrada
            <select
              value={b.agenciaId}
              onChange={(e) => b.trocarAgencia(Number(e.target.value))}
              className="rounded-xl border border-borda bg-white/[0.03] px-3 py-2 text-sm text-texto outline-none focus:border-roxo"
            >
              {AGENCIAS.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.rotulo}
                </option>
              ))}
            </select>
          </label>
          <button
            onClick={b.sair}
            className="rounded-full border border-borda px-4 py-2 text-xs text-texto-fraco transition-colors hover:border-roxo hover:text-texto"
          >
            Sair
          </button>
        </div>
      </header>

      {b.aviso && (
        <div className="mb-5">
          <Banner tipo={b.aviso.tipo}>{b.aviso.texto}</Banner>
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-2">
        <section className="rounded-xl2 border border-borda bg-superficie p-6">
          <h2 className="mb-4 text-base font-semibold">Consultar conta</h2>
          <Campo
            rotulo="Número da conta"
            type="number"
            min={0}
            value={consultaId}
            onChange={(e) => setConsultaId(e.target.value)}
            placeholder="0"
          />
          <Botao
            disabled={b.carregando === "consultar"}
            onClick={() => b.consultar(Number(consultaId))}
          >
            Consultar saldo
          </Botao>

          {b.conta && (
            <div className="mt-5 rounded-xl border border-roxo/20 bg-roxo/[0.08] p-4">
              <div className="flex justify-between py-1 text-sm">
                <span className="text-xs uppercase tracking-wide text-texto-fraco">Titular</span>
                <strong>{b.conta.nomeAluno ?? "—"}</strong>
              </div>
              <div className="flex justify-between py-1 text-sm">
                <span className="text-xs uppercase tracking-wide text-texto-fraco">Conta</span>
                <strong>{b.conta.id}</strong>
              </div>
              <div className="mt-2 flex items-baseline justify-between border-t border-borda pt-3">
                <span className="text-xs uppercase tracking-wide text-texto-fraco">Saldo</span>
                <span className="text-2xl font-bold tracking-tight">{moeda.format(b.conta.saldo)}</span>
              </div>
            </div>
          )}
        </section>

        <section className="rounded-xl2 border border-borda bg-superficie p-6">
          <h2 className="mb-4 text-base font-semibold">Depósito e saque</h2>
          <Campo
            rotulo="Conta"
            type="number"
            min={0}
            value={movId}
            onChange={(e) => setMovId(e.target.value)}
            placeholder="0"
          />
          <Campo
            rotulo="Valor"
            type="number"
            min={0}
            step="0.01"
            value={movValor}
            onChange={(e) => setMovValor(e.target.value)}
            placeholder="0,00"
          />
          <div className="grid grid-cols-2 gap-3">
            <Botao
              disabled={b.carregando === "deposito"}
              onClick={() => b.movimentar("deposito", Number(movId), Number(movValor))}
            >
              Depositar
            </Botao>
            <Botao
              variante="secundario"
              disabled={b.carregando === "saque"}
              onClick={() => b.movimentar("saque", Number(movId), Number(movValor))}
            >
              Sacar
            </Botao>
          </div>
        </section>

        <section className="rounded-xl2 border border-borda bg-superficie p-6 md:col-span-2">
          <h2 className="text-base font-semibold">Transferência</h2>
          <p className="mb-4 mt-1 text-sm text-texto-fraco">
            Local ou entre agências — o destino é resolvido pelo backend.
          </p>
          <div className="grid gap-3 md:grid-cols-3">
            <Campo
              rotulo="Conta de origem"
              type="number"
              min={0}
              value={origem}
              onChange={(e) => setOrigem(e.target.value)}
              placeholder="0"
            />
            <Campo
              rotulo="Conta de destino"
              type="number"
              min={0}
              value={destino}
              onChange={(e) => setDestino(e.target.value)}
              placeholder="1"
            />
            <Campo
              rotulo="Valor"
              type="number"
              min={0}
              step="0.01"
              value={valor}
              onChange={(e) => setValor(e.target.value)}
              placeholder="0,00"
            />
          </div>
          <Botao
            disabled={b.carregando === "transferir"}
            onClick={() => b.transferir(Number(origem), Number(destino), Number(valor))}
          >
            Transferir
          </Botao>

          {b.resultado && (
            <div className="mt-4">
              <Banner tipo={b.resultado.tipo}>
                <strong className="block text-texto">{b.resultado.titulo}</strong>
                {b.resultado.texto}
              </Banner>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
