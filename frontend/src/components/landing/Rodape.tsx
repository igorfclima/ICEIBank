import { Marca } from "@/components/Marca";

const colunas = [
  { titulo: "Produto", itens: ["Abrir o app", "Recursos", "Segurança", "Agências"] },
  { titulo: "Recursos", itens: ["Central de ajuda", "Status das agências", "Documentação da API", "Linha do tempo"] },
  { titulo: "Empresa", itens: ["Sobre", "Carreiras", "Imprensa", "Contato"] },
  { titulo: "Social", itens: ["Twitter", "Instagram", "YouTube", "Discord"] },
];

export function Rodape() {
  return (
    <footer className="border-t border-borda bg-fundo-2">
      <div className="mx-auto max-w-6xl px-5 py-16">
        <div className="grid gap-10 md:grid-cols-[1.5fr_repeat(4,1fr)]">
          <div>
            <Marca className="text-lg" />
            <p className="mt-3 max-w-xs text-sm text-texto-fraco">
              O único banco que você vai precisar. Em qualquer agência.
            </p>
          </div>
          {colunas.map((c) => (
            <div key={c.titulo}>
              <p className="text-sm font-semibold">{c.titulo}</p>
              <ul className="mt-4 space-y-2 text-sm text-texto-fraco">
                {c.itens.map((i) => (
                  <li key={i}>
                    <a href="#" className="transition-colors hover:text-texto">
                      {i}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="mt-14 flex flex-col justify-between gap-2 border-t border-borda pt-6 text-xs text-texto-fraco sm:flex-row">
          <span>© {new Date().getFullYear()} ICEIBank</span>
          <span>Projeto acadêmico — Sistemas Distribuídos · Sprint 1 (REST/MVC + Relógio de Lamport)</span>
        </div>
      </div>
    </footer>
  );
}
