import type { ButtonHTMLAttributes, InputHTMLAttributes, ReactNode } from "react";

export function Campo({
  rotulo,
  erro,
  ...props
}: { rotulo: string; erro?: string } & InputHTMLAttributes<HTMLInputElement>) {
  return (
    <label className="mb-4 flex flex-col gap-1">
      <span className="rotulo">{rotulo}</span>
      <input
        {...props}
        aria-invalid={erro ? true : undefined}
        className="min-h-12 w-full rounded-xs border border-tinta-2 bg-papel px-3 text-base text-tinta placeholder:text-tinta-2/70 focus:border-tinta"
      />
      {erro && <span className="text-sm text-erro">{erro}</span>}
    </label>
  );
}

export function Botao({
  variante = "primario",
  className = "",
  ...props
}: { variante?: "primario" | "tonal" | "contorno" } & ButtonHTMLAttributes<HTMLButtonElement>) {
  const estilo =
    variante === "primario"
      ? "bg-ativa text-sobre-ativa"
      : variante === "tonal"
        ? "bg-papel-2 text-tinta"
        : "border border-tinta text-tinta";
  return (
    <button
      {...props}
      className={`min-h-12 w-full cursor-pointer rounded-sm px-4 text-base font-semibold transition-opacity duration-[var(--rapido)] hover:opacity-90 active:opacity-75 disabled:cursor-not-allowed disabled:line-through disabled:opacity-50 ${estilo} ${className}`}
    />
  );
}

type TomChip = "neutro" | "lider" | "ok" | "alerta" | "erro" | "sobre";

export function Chip({ tom = "neutro", children }: { tom?: TomChip; children: ReactNode }) {
  const estilo = {
    neutro: "border-tinta-2 text-tinta-2",
    lider: "border-tinta bg-tinta text-papel",
    ok: "border-sucesso text-sucesso",
    alerta: "border-alerta text-alerta",
    erro: "border-erro text-erro",
    sobre: "border-current",
  }[tom];
  return (
    <span
      className={`inline-flex items-center whitespace-nowrap rounded-sm border px-2 py-0.5 text-xs font-semibold ${estilo}`}
    >
      {children}
    </span>
  );
}

export function Banner({ tipo, children }: { tipo: "erro" | "ok" | "alerta"; children: ReactNode }) {
  const estilo = {
    erro: "border-erro text-erro",
    ok: "border-sucesso text-sucesso",
    alerta: "border-alerta text-alerta",
  }[tipo];
  const icone = { erro: "Erro", ok: "Feito", alerta: "Atenção" }[tipo];
  return (
    <div role="status" className={`flex gap-3 border bg-papel-2 px-4 py-3 text-sm ${estilo}`}>
      <span className="rotulo shrink-0" style={{ color: "inherit" }}>
        {icone}
      </span>
      <span className="text-tinta">{children}</span>
    </div>
  );
}

export function Serie({ vetor, posicao }: { vetor?: number[]; posicao: number }) {
  if (!vetor) return <span className="serie text-tinta-2">[— · — · —]</span>;
  return (
    <span className="serie" aria-label={`série ${vetor.join(" ")}`}>
      [
      {vetor.map((n, i) => (
        <span key={i} className={i === posicao ? "font-bold" : "text-tinta-2"}>
          {i > 0 ? " · " : ""}
          {n}
        </span>
      ))}
      ]
    </span>
  );
}
