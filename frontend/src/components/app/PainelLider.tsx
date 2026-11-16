"use client";

import { AGENCIAS } from "@/lib/config";
import { Chip } from "@/components/compartilhado/ui";
import type { EstadoLideranca } from "@/hooks/useBanco";

const COR_PONTO = ["bg-ag0", "bg-ag1", "bg-ag2"];

function hora(epoch: number | null) {
  if (!epoch) return null;
  return new Date(epoch * 1000).toLocaleTimeString("pt-BR");
}

export function PainelLider({ lideranca, agenciaId }: { lideranca: EstadoLideranca; agenciaId: number }) {
  const lider = lideranca.estado === "lider" ? lideranca.lider : null;
  const desde = lideranca.estado === "lider" ? hora(lideranca.desde) : null;

  return (
    <section className="border border-regua" aria-labelledby="titulo-lider">
      <div className="p-6">
        <h2 id="titulo-lider" className="rotulo">
          Liderança entre as agências
        </h2>
        <div role="status" aria-live="polite" className="mt-3 min-h-[72px]">
          {lideranca.estado === "carregando" && <div className="h-10 w-48 bg-papel-2" aria-label="Consultando as agências" />}
          {lideranca.estado === "lider" && (
            <p key={lideranca.lider} className="virar display">
              Agência {lideranca.lider}
            </p>
          )}
          {lideranca.estado === "eleicao" && (
            <div className="virar">
              <p className="display">Eleição em andamento</p>
              <p className="mt-1 text-sm text-tinta-2">As agências ainda divergem sobre quem lidera.</p>
            </div>
          )}
          {lideranca.estado === "sem-resposta" && (
            <div className="virar">
              <p className="display">Sem resposta</p>
              <p className="mt-1 text-sm text-tinta-2">
                Nenhuma agência respondeu.
                {lideranca.ultimoLider !== null && ` Último valor conhecido: Agência ${lideranca.ultimoLider}.`}
              </p>
            </div>
          )}
        </div>
      </div>

      <ul className="border-t border-regua">
        {AGENCIAS.map((a) => {
          const ativa = lideranca.ativas[a.id];
          const eLider = lider === a.id;
          const entrada = agenciaId === a.id;
          const resposta = lideranca.estado === "carregando" ? null : ativa;
          return (
            <li
              key={a.id}
              className={`flex min-h-12 items-center justify-between gap-3 border-b border-regua px-6 py-2 last:border-b-0 ${
                entrada ? "bg-ativa text-sobre-ativa" : ""
              }`}
            >
              <span className="flex items-center gap-3">
                <span
                  className={`h-2 w-2 rounded-full ${resposta === false ? "border border-tinta-2" : COR_PONTO[a.id]}`}
                  aria-hidden="true"
                />
                <span className="font-semibold">{a.rotulo}</span>
                {entrada && <span className="text-xs">entrada</span>}
              </span>
              <span className="flex items-center gap-2">
                {eLider && <Chip tom={entrada ? "sobre" : "lider"}>Líder</Chip>}
                {resposta === true && !eLider && <Chip tom={entrada ? "sobre" : "ok"}>Ativa</Chip>}
                {resposta === false && <Chip tom={entrada ? "sobre" : "alerta"}>Fora do ar</Chip>}
              </span>
            </li>
          );
        })}
      </ul>

      <p className="border-t border-regua px-6 py-3 serie text-tinta-2">
        {lider !== null ? `Assina: Agência ${lider}${desde ? ` · desde ${desde}` : ""}` : "Assina: —"}
      </p>
    </section>
  );
}
