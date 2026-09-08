import Link from "next/link";

export function Hero() {
  return (
    <section className="relative overflow-hidden">
      <div className="brilho-roxo pointer-events-none absolute inset-x-0 top-0 h-[520px]" />
      <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 pb-24 pt-20 md:grid-cols-2 md:pt-28">
        <div>
          <p className="mb-4 inline-flex rounded-full border border-borda bg-superficie px-3 py-1 text-xs font-medium text-texto-fraco">
            Agora em todas as 3 agências
          </p>
          <h1 className="text-5xl font-extrabold leading-[1.05] tracking-tight md:text-6xl">
            O único banco que você vai precisar.
          </h1>
          <p className="mt-6 max-w-md text-lg text-texto-fraco">
            Deposite, saque, transfira e acompanhe cada centavo em tempo real — em
            qualquer agência do ICEIBank, sem fila e sem susto.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link
              href="/app"
              className="rounded-full bg-roxo px-6 py-3 font-semibold text-[#14121c] transition-colors hover:bg-roxo-suave"
            >
              Abrir o app
            </Link>
            <a
              href="#recursos"
              className="rounded-full border border-borda px-6 py-3 font-semibold text-texto transition-colors hover:border-roxo"
            >
              Ver como funciona
            </a>
          </div>
          <p className="mt-6 text-sm text-texto-fraco">
            Usado por milhares de correntistas. Zero fila.
          </p>
        </div>

        <div className="relative flex justify-center">
          <div className="flutuar w-full max-w-sm rounded-xl2 border border-borda bg-gradient-to-b from-superficie to-fundo-2 p-6 shadow-2xl">
            <div className="flex items-center justify-between text-sm text-texto-fraco">
              <span>Conta 42 · Agência 0</span>
              <span className="rounded-full bg-roxo/15 px-2 py-0.5 text-roxo">ativa</span>
            </div>
            <p className="mt-6 text-sm text-texto-fraco">Saldo disponível</p>
            <p className="text-4xl font-extrabold tracking-tight">R$ 12.480,00</p>
            <div className="mt-6 grid grid-cols-3 gap-2 text-center text-xs font-semibold">
              <div className="rounded-lg bg-roxo py-2 text-[#14121c]">Depositar</div>
              <div className="rounded-lg border border-borda py-2">Sacar</div>
              <div className="rounded-lg border border-borda py-2">Transferir</div>
            </div>
            <div className="mt-6 space-y-3 text-sm">
              {[
                ["Transferência recebida", "+ R$ 900,00"],
                ["Saque", "− R$ 120,00"],
                ["Depósito", "+ R$ 2.000,00"],
              ].map(([t, v]) => (
                <div key={t} className="flex justify-between border-b border-borda pb-2 text-texto-fraco last:border-0">
                  <span>{t}</span>
                  <span className={v.startsWith("+") ? "text-ok" : "text-texto"}>{v}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="absolute -bottom-6 -left-2 hidden rotate-[-6deg] rounded-2xl border border-borda bg-superficie px-4 py-3 text-sm shadow-xl sm:block">
            <span className="text-texto-fraco">Lamport</span>{" "}
            <span className="font-semibold text-roxo">#128</span>
          </div>
        </div>
      </div>
    </section>
  );
}
