export function Agencias() {
  return (
    <section id="agencias" className="mx-auto max-w-6xl px-5 py-24">
      <div className="grid items-center gap-12 md:grid-cols-2">
        <div className="order-2 md:order-1">
          <div className="rounded-xl2 border border-borda bg-superficie p-8">
            <p className="text-sm text-texto-fraco">Transferindo para a conta 7</p>
            <div className="mt-5 flex items-center justify-between gap-3">
              {["Agência 0", "Agência 1", "Agência 2"].map((a, i) => (
                <div
                  key={a}
                  className={`flex-1 rounded-xl border p-4 text-center text-sm font-semibold ${
                    i === 1
                      ? "border-roxo bg-roxo/15 text-roxo"
                      : "border-borda text-texto-fraco"
                  }`}
                >
                  {a}
                  {i === 1 && <span className="mt-1 block text-xs font-normal">conta 7 mora aqui</span>}
                </div>
              ))}
            </div>
            <p className="mt-5 text-sm text-texto-fraco">
              7 % 3 = 1 → o pedido entra por qualquer agência e chega na Agência 1.
            </p>
          </div>
        </div>
        <div className="order-1 md:order-2">
          <p className="mb-3 text-sm font-semibold uppercase tracking-widest text-roxo">
            Multiagência
          </p>
          <h2 className="text-4xl font-extrabold tracking-tight md:text-5xl">
            Uma conta, a agência certa, sempre.
          </h2>
          <p className="mt-4 max-w-md text-lg text-texto-fraco">
            Cada conta pertence a exatamente uma agência. Você abre o app por
            onde quiser — o ICEIBank encaminha a operação para o lugar certo e
            devolve o resultado. Local ou entre agências, para você é só
            &quot;transferir&quot;.
          </p>
        </div>
      </div>
    </section>
  );
}
