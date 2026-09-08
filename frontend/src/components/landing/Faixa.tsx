const selos = [
  "Agência 0",
  "Agência 1",
  "Agência 2",
  "API REST · MVC",
  "Autenticação JWT",
  "Relógio de Lamport",
  "Linha do tempo unificada",
];

export function Faixa() {
  return (
    <section className="border-y border-borda bg-fundo-2 py-8">
      <p className="mb-6 text-center text-xs font-medium uppercase tracking-widest text-texto-fraco">
        Uma infraestrutura, três agências independentes
      </p>
      <div className="relative overflow-hidden">
        <div className="marquee flex w-max gap-12 whitespace-nowrap px-6 text-lg font-semibold text-texto-fraco">
          {[...selos, ...selos].map((s, i) => (
            <span key={i}>{s}</span>
          ))}
        </div>
      </div>
    </section>
  );
}
