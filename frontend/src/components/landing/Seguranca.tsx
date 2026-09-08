const pontos = [
  "Login devolve um token JWT assinado, com data de validade.",
  "Sem token válido no cabeçalho, nenhuma rota de conta responde.",
  "Token expirado cai na hora — a interface te avisa e pede login de novo.",
  "As agências não confiam em quem não se identifica, nem entre si.",
];

export function Seguranca() {
  return (
    <section id="seguranca" className="border-y border-borda bg-fundo-2">
      <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 py-24 md:grid-cols-2">
        <div>
          <p className="mb-3 text-sm font-semibold uppercase tracking-widest text-roxo">
            Segurança
          </p>
          <h2 className="text-4xl font-extrabold tracking-tight md:text-5xl">
            Protegido de ponta a ponta.
          </h2>
          <p className="mt-4 max-w-md text-lg text-texto-fraco">
            Seu dinheiro fica atrás de uma porta que só abre com a chave certa —
            e a chave tem hora para vencer.
          </p>
          <ul className="mt-8 space-y-4">
            {pontos.map((p) => (
              <li key={p} className="flex gap-3 text-texto-fraco">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-roxo" />
                {p}
              </li>
            ))}
          </ul>
        </div>
        <div className="rounded-xl2 border border-borda bg-superficie p-8 font-mono text-sm">
          <p className="text-texto-fraco">// requisição autenticada</p>
          <p className="mt-3">
            <span className="text-roxo">POST</span> /transferencias
          </p>
          <p className="text-texto-fraco">Authorization: Bearer</p>
          <p className="break-all text-roxo-suave">
            eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9…
          </p>
          <div className="mt-5 rounded-lg border border-ok/30 bg-ok/10 p-3 text-ok">
            200 OK · transferência concluída
          </div>
          <div className="mt-3 rounded-lg border border-erro/30 bg-erro/10 p-3 text-erro">
            401 · token inválido ou expirado
          </div>
        </div>
      </div>
    </section>
  );
}
