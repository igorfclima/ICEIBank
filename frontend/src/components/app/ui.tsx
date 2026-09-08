import type { ButtonHTMLAttributes, InputHTMLAttributes, SelectHTMLAttributes } from "react";

export function Campo({
  rotulo,
  ...props
}: { rotulo: string } & InputHTMLAttributes<HTMLInputElement>) {
  return (
    <label className="mb-4 flex flex-col gap-1.5 text-xs text-texto-fraco">
      {rotulo}
      <input
        {...props}
        className="w-full rounded-xl border border-borda bg-white/[0.03] px-3.5 py-3 text-[15px] text-texto outline-none transition-colors focus:border-roxo focus:bg-roxo/[0.06]"
      />
    </label>
  );
}

export function Selecao({
  rotulo,
  children,
  ...props
}: { rotulo: string } & SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <label className="flex items-center gap-2 text-xs text-texto-fraco">
      {rotulo}
      <select
        {...props}
        className="rounded-xl border border-borda bg-white/[0.03] px-3 py-2 text-sm text-texto outline-none focus:border-roxo"
      >
        {children}
      </select>
    </label>
  );
}

export function Botao({
  variante = "primario",
  className = "",
  ...props
}: { variante?: "primario" | "secundario" } & ButtonHTMLAttributes<HTMLButtonElement>) {
  const estilo =
    variante === "primario"
      ? "bg-roxo text-[#16131f] hover:bg-roxo-suave"
      : "border border-borda bg-white/[0.05] text-texto hover:bg-white/10";
  return (
    <button
      {...props}
      className={`w-full rounded-xl px-4 py-3 text-[15px] font-semibold transition-colors disabled:opacity-50 ${estilo} ${className}`}
    />
  );
}

export function Banner({
  tipo,
  children,
}: {
  tipo: "erro" | "ok";
  children: React.ReactNode;
}) {
  const estilo =
    tipo === "erro"
      ? "border-erro/30 bg-erro/12 text-[#ffb3b3]"
      : "border-ok/30 bg-ok/12 text-[#a7f3c4]";
  return (
    <div className={`rounded-xl border px-4 py-3 text-sm ${estilo}`}>{children}</div>
  );
}
