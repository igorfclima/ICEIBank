import Link from "next/link";

export function ChamadaFinal() {
  return (
    <section className="relative overflow-hidden border-t border-borda">
      <div className="brilho-roxo pointer-events-none absolute inset-x-0 bottom-0 h-[420px]" />
      <div className="mx-auto max-w-3xl px-5 py-28 text-center">
        <h2 className="text-5xl font-extrabold tracking-tight md:text-6xl">
          Seu dinheiro, sob controle.
        </h2>
        <p className="mt-5 text-lg text-texto-fraco">
          Abra o app do ICEIBank e faça sua primeira operação em menos de um minuto.
        </p>
        <Link
          href="/app"
          className="mt-9 inline-flex rounded-full bg-roxo px-8 py-4 text-lg font-semibold text-[#14121c] transition-colors hover:bg-roxo-suave"
        >
          Abrir o app
        </Link>
      </div>
    </section>
  );
}
