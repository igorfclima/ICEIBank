const eventos = [
  ["#124", "Agência 0", "DEPÓSITO", "conta 0 · +R$ 200"],
  ["#125", "Agência 1", "TRANSFERÊNCIA_DÉBITO", "conta 1 → conta 5"],
  ["#126", "Agência 2", "CRIAR_CONTA", "conta 8"],
  ["#127", "Agência 1", "TRANSFERÊNCIA_CRÉDITO_REMOTO", "conta 5 · +R$ 80"],
];

export function LinhaDoTempo() {
  return (
    <section id="linha-do-tempo" className="border-t border-borda bg-fundo-2">
      <div className="mx-auto max-w-6xl px-5 py-24">
        <h2 className="max-w-2xl text-4xl font-extrabold tracking-tight md:text-5xl">
          Por dentro de cada centavo.
        </h2>
        <p className="mt-4 max-w-xl text-lg text-texto-fraco">
          Toda operação é carimbada por um relógio lógico de Lamport e registrada
          numa linha do tempo única, mesclada entre as três agências. Nada se
          perde no caminho.
        </p>
        <div className="mt-12 overflow-hidden rounded-xl2 border border-borda bg-superficie">
          {eventos.map(([ts, ag, tipo, det], i) => (
            <div
              key={i}
              className="flex flex-wrap items-center gap-x-4 gap-y-1 border-b border-borda px-6 py-4 text-sm last:border-0"
            >
              <span className="font-mono font-semibold text-roxo">Lamport {ts}</span>
              <span className="text-texto-fraco">{ag}</span>
              <span className="font-semibold">{tipo}</span>
              <span className="text-texto-fraco">{det}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
