const depoimentos = [
  {
    texto: "Transferi para uma conta de outra agência e nem percebi a diferença. Caiu na hora.",
    autor: "Marina R.",
    papel: "correntista, Agência 2",
  },
  {
    texto: "O extrato aparece em tempo real. Consigo ver exatamente a ordem em que tudo aconteceu.",
    autor: "Diego F.",
    papel: "correntista, Agência 0",
  },
  {
    texto: "Meu acesso expirou no meio do dia e o app avisou na cara. Sem tela branca, sem susto.",
    autor: "Luísa M.",
    papel: "correntista, Agência 1",
  },
];

export function Depoimentos() {
  return (
    <section className="mx-auto max-w-6xl px-5 py-24">
      <h2 className="text-center text-4xl font-extrabold tracking-tight md:text-5xl">
        Milhares de correntistas. Zero fila.
      </h2>
      <div className="mt-14 grid gap-5 md:grid-cols-3">
        {depoimentos.map((d) => (
          <figure key={d.autor} className="rounded-xl2 border border-borda bg-superficie p-7">
            <blockquote className="text-lg leading-relaxed">&ldquo;{d.texto}&rdquo;</blockquote>
            <figcaption className="mt-5 text-sm text-texto-fraco">
              <span className="font-semibold text-texto">{d.autor}</span> · {d.papel}
            </figcaption>
          </figure>
        ))}
      </div>
      <p className="mt-8 text-center text-xs text-texto-fraco">
        Depoimentos ilustrativos — ICEIBank é um projeto acadêmico.
      </p>
    </section>
  );
}
