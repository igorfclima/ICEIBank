const recursos = [
  {
    titulo: "Depósito e saque na hora",
    texto: "Movimente sua conta em segundos. O saldo é conferido a cada operação — ou bate, ou não passa.",
  },
  {
    titulo: "Transferência local e entre agências",
    texto: "Manda para qualquer conta. O ICEIBank descobre a agência certa e roteia por você.",
  },
  {
    titulo: "Extrato em tempo real",
    texto: "Cada evento da sua conta aparece na hora, carimbado e ordenado. Nada some do histórico.",
  },
  {
    titulo: "Acesso protegido por token",
    texto: "Todo acesso passa por um token assinado com validade. Expirou, pediu de novo.",
  },
];

export function Recursos() {
  return (
    <section id="recursos" className="mx-auto max-w-6xl px-5 py-24">
      <h2 className="max-w-2xl text-4xl font-extrabold tracking-tight md:text-5xl">
        Tudo o que o seu dinheiro precisa, num lugar só.
      </h2>
      <p className="mt-4 max-w-xl text-lg text-texto-fraco">
        Diga adeus à fila do banco. O ICEIBank junta as operações do dia a dia
        numa interface direta.
      </p>
      <div className="mt-14 grid gap-5 md:grid-cols-2">
        {recursos.map((r) => (
          <div
            key={r.titulo}
            className="rounded-xl2 border border-borda bg-superficie p-8 transition-colors hover:border-roxo/40"
          >
            <div className="mb-5 h-11 w-11 rounded-xl bg-gradient-to-br from-roxo-suave to-roxo-forte" />
            <h3 className="text-xl font-semibold">{r.titulo}</h3>
            <p className="mt-2 text-texto-fraco">{r.texto}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
