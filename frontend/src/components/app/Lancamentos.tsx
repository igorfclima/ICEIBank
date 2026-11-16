"use client";

import { Serie } from "@/components/compartilhado/ui";
import type { Evento } from "@/lib/session";

const moeda = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" });

type Descricao = { rotulo: string; sinal: 1 | -1 | 0; valor?: number };

function descrever(e: Evento): Descricao {
  const valor = typeof e.detalhes.valor === "number" ? e.detalhes.valor : undefined;
  switch (e.tipo) {
    case "CRIAR_CONTA":
      return { rotulo: "Conta aberta", sinal: 0 };
    case "DEPOSITO":
      return { rotulo: "Depósito", sinal: 1, valor };
    case "SAQUE":
      return { rotulo: "Saque", sinal: -1, valor };
    case "TRANSFERENCIA_DEBITO":
      return { rotulo: "Transferência enviada", sinal: -1, valor };
    case "TRANSFERENCIA_CREDITO":
      return { rotulo: "Transferência recebida", sinal: 1, valor };
    case "TRANSFERENCIA_CREDITO_REMOTO":
      return { rotulo: "Crédito de outra agência", sinal: 1, valor };
    case "SINCRONIZACAO_OFFLINE":
      return {
        rotulo: "Sincronização offline",
        sinal: e.detalhes.tipo === "DEPOSITO" ? 1 : -1,
        valor,
      };
    case "TRANSFERENCIA_PUBLICADA":
      return { rotulo: "Transferência publicada", sinal: 0, valor };
    case "TRANSFERENCIA_PENDENTE":
      return { rotulo: "Transferência pendente", sinal: 0, valor };
    default:
      return { rotulo: e.tipo, sinal: 0 };
  }
}

export function Lancamentos({ eventos, posicao }: { eventos: Evento[]; posicao: number }) {
  if (eventos.length === 0) {
    return (
      <p className="border-t border-regua px-6 py-6 text-sm text-tinta-2">
        Nenhum lançamento ainda. Faça um depósito para ver o primeiro número de série.
      </p>
    );
  }
  return (
    <div className="overflow-x-auto border-t border-regua">
      <table className="w-full min-w-[480px] text-left text-sm">
        <caption className="sr-only">Últimos lançamentos da conta, do mais recente ao mais antigo</caption>
        <thead>
          <tr className="border-b border-regua">
            <th scope="col" className="rotulo px-6 py-2">Lançamento</th>
            <th scope="col" className="rotulo px-2 py-2 text-right">Valor</th>
            <th scope="col" className="rotulo px-2 py-2">Hora</th>
            <th scope="col" className="rotulo px-6 py-2 text-right">Série</th>
          </tr>
        </thead>
        <tbody>
          {eventos.map((e, i) => {
            const d = descrever(e);
            return (
              <tr key={e.idEvento ?? i} className="min-h-12 border-b border-regua last:border-b-0">
                <td className="px-6 py-3 font-semibold">{d.rotulo}</td>
                <td className="px-2 py-3 text-right">
                  {d.valor !== undefined ? `${d.sinal < 0 ? "− " : d.sinal > 0 ? "+ " : ""}${moeda.format(d.valor)}` : "—"}
                </td>
                <td className="px-2 py-3 text-tinta-2">{new Date(e.horaParede).toLocaleTimeString("pt-BR")}</td>
                <td className="px-6 py-3 text-right">
                  <Serie vetor={e.timestampVetorial} posicao={posicao} />
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
