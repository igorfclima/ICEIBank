"use client";

import { useState } from "react";
import { AGENCIAS } from "@/lib/config";
import { Marca } from "@/components/Marca";
import { Banner, Botao, Campo, Serie } from "@/components/compartilhado/ui";
import { Lancamentos } from "./Lancamentos";
import { PainelLider } from "./PainelLider";
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

  const posicaoConta = b.conta ? b.conta.id % AGENCIAS.length : 0;

  return (
    <div className="min-h-screen">
      <header className="bg-ativa text-sobre-ativa">
        <div className="mx-auto flex max-w-[1120px] flex-wrap items-center justify-between gap-4 px-4 py-3 md:px-8">
          <Marca className="text-xl" pontos={false} />
          <div className="flex flex-wrap items-center gap-3">
            <label className="flex items-center gap-2 text-sm">
              <span className="rotulo" style={{ color: "inherit" }}>Agência de entrada</span>
              <select
                value={b.agenciaId}
                onChange={(e) => b.trocarAgencia(Number(e.target.value))}
                className="min-h-12 rounded-xs border border-current bg-papel px-3 text-base text-tinta"
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
              className="min-h-12 cursor-pointer rounded-sm border border-current px-4 text-base font-semibold hover:opacity-80"
            >
              Sair
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-[1120px] px-4 py-8 md:px-8">
        {b.aviso && (
          <div className="mb-6">
            <Banner tipo={b.aviso.tipo}>{b.aviso.texto}</Banner>
          </div>
        )}

        <div className="grid gap-6 lg:grid-cols-[1.4fr_1fr]">
          <section className="border border-regua" aria-labelledby="titulo-conta">
            <div className="p-6">
              <h2 id="titulo-conta" className="rotulo">Conta</h2>
              <div className="mt-4 flex items-end gap-3">
                <div className="flex-1">
                  <Campo
                    rotulo="Número da conta"
                    type="number"
                    inputMode="numeric"
                    min={0}
                    value={consultaId}
                    onChange={(e) => setConsultaId(e.target.value)}
                    placeholder="0"
                  />
                </div>
                <div className="mb-4 w-44">
                  <Botao disabled={b.carregando === "consultar" || consultaId === ""} onClick={() => b.consultar(Number(consultaId))}>
                    Consultar
                  </Botao>
                </div>
              </div>

              {b.conta ? (
                <div className="bg-ativa/10 p-4">
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <p className="rotulo">Titular</p>
                      <p className="titulo">{b.conta.nomeAluno ?? "—"}</p>
                    </div>
                    <div className="text-right">
                      <p className="rotulo">Conta · Agência {posicaoConta}</p>
                      <p className="titulo">{b.conta.id}</p>
                    </div>
                  </div>
                  <p className="rotulo mt-4">Saldo</p>
                  <p className="display">{moeda.format(b.conta.saldo)}</p>
                  <p className="mt-2 flex items-center gap-2 text-sm text-tinta-2">
                    Série atual da agência <Serie vetor={b.conta.vetorAtual} posicao={posicaoConta} />
                  </p>
                </div>
              ) : (
                <p className="text-sm text-tinta-2">
                  Informe o número de uma conta para ver saldo e lançamentos. A conta N mora na agência N mod 3.
                </p>
              )}
            </div>
            {b.conta && <Lancamentos eventos={b.historico} posicao={posicaoConta} />}
          </section>

          <PainelLider lideranca={b.lideranca} agenciaId={b.agenciaId} />
        </div>

        <div className="mt-6 grid gap-6 lg:grid-cols-2">
          <section className="border border-regua p-6" aria-labelledby="titulo-mov">
            <h2 id="titulo-mov" className="rotulo">Depósito e saque</h2>
            <div className="mt-4 grid gap-x-4 sm:grid-cols-2">
              <Campo rotulo="Conta" type="number" inputMode="numeric" min={0} value={movId} onChange={(e) => setMovId(e.target.value)} placeholder="0" />
              <Campo rotulo="Valor" type="number" inputMode="decimal" min={0} step="0.01" value={movValor} onChange={(e) => setMovValor(e.target.value)} placeholder="0,00" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Botao disabled={b.carregando === "deposito"} onClick={() => b.movimentar("deposito", Number(movId), Number(movValor))}>
                Depositar
              </Botao>
              <Botao variante="contorno" disabled={b.carregando === "saque"} onClick={() => b.movimentar("saque", Number(movId), Number(movValor))}>
                Sacar
              </Botao>
            </div>
          </section>

          <section className="border border-regua p-6" aria-labelledby="titulo-transf">
            <h2 id="titulo-transf" className="rotulo">Transferência</h2>
            <p className="mt-1 text-sm text-tinta-2">Local ou entre agências; o destino é resolvido pelo backend.</p>
            <div className="mt-4 grid gap-x-4 sm:grid-cols-3">
              <Campo rotulo="Origem" type="number" inputMode="numeric" min={0} value={origem} onChange={(e) => setOrigem(e.target.value)} placeholder="0" />
              <Campo rotulo="Destino" type="number" inputMode="numeric" min={0} value={destino} onChange={(e) => setDestino(e.target.value)} placeholder="1" />
              <Campo rotulo="Valor" type="number" inputMode="decimal" min={0} step="0.01" value={valor} onChange={(e) => setValor(e.target.value)} placeholder="0,00" />
            </div>
            <Botao disabled={b.carregando === "transferir"} onClick={() => b.transferir(Number(origem), Number(destino), Number(valor))}>
              Transferir
            </Botao>
            {b.resultado && (
              <div className="mt-4">
                <Banner tipo={b.resultado.tipo}>
                  <strong className="block">{b.resultado.titulo}</strong>
                  {b.resultado.texto}
                </Banner>
              </div>
            )}
          </section>
        </div>
      </main>
    </div>
  );
}
