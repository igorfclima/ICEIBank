import Link from "next/link";
import { Marca } from "@/components/Marca";
import { Cedula } from "@/components/landing/Cedula";

const pilares = [
  {
    rotulo: "Partição",
    titulo: "Cada conta mora em uma agência.",
    texto:
      "A conta N pertence à agência N mod 3. Ninguém compartilha banco: as agências trocam mensagens assinadas por um broker.",
  },
  {
    rotulo: "Consenso",
    titulo: "A líder é eleita entre elas.",
    texto:
      "Pelo algoritmo de Bully, vence a agência de maior número entre as ativas. Se ela cai, as outras elegem outra sozinhas.",
  },
  {
    rotulo: "Offline",
    titulo: "Sem conexão, o app continua.",
    texto:
      "A operação fica pendente com marca d'água e sincroniza ao reconectar. O relógio vetorial avisa se algo mudou enquanto você estava fora.",
  },
];

export default function Home() {
  return (
    <>
      <header className="bg-ativa text-sobre-ativa">
        <div className="mx-auto flex max-w-[1120px] items-center justify-between px-4 py-3 md:px-8">
          <Marca className="text-xl" pontos={false} />
          <Link
            href="/app"
            className="inline-flex min-h-12 items-center rounded-sm border border-current px-4 font-semibold hover:opacity-80"
          >
            Abrir o app
          </Link>
        </div>
      </header>

      <main>
        <section className="mx-auto grid max-w-[1120px] items-center gap-10 px-4 py-16 md:px-8 lg:grid-cols-[1fr_1.1fr]">
          <div>
            <p className="rotulo">Banco didático em três agências</p>
            <h1 className="mt-3 text-[40px] font-bold leading-[44px] tracking-tight md:text-[56px] md:leading-[60px]" style={{ fontStretch: "112%" }}>
              Três agências. Uma líder por vez.
            </h1>
            <p className="mt-5 max-w-[56ch] text-lg text-tinta-2">
              O ICEIBank mostra na tela o que costuma ficar escondido num log: quem lidera, em que ordem cada lançamento
              aconteceu e o que ainda espera para ser sincronizado.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link
                href="/app"
                className="inline-flex min-h-12 items-center rounded-sm bg-ativa px-6 font-semibold text-sobre-ativa hover:opacity-90"
              >
                Abrir o app
              </Link>
              <a
                href="#como-funciona"
                className="inline-flex min-h-12 items-center rounded-sm border border-tinta px-6 font-semibold hover:bg-papel-2"
              >
                Como funciona
              </a>
            </div>
          </div>
          <Cedula />
        </section>

        <section id="como-funciona" className="border-t border-regua bg-papel-2">
          <div className="mx-auto grid max-w-[1120px] gap-px px-4 py-16 md:px-8 lg:grid-cols-3">
            {pilares.map((p) => (
              <article key={p.rotulo} className="border border-regua bg-papel p-6">
                <p className="rotulo">{p.rotulo}</p>
                <h2 className="titulo mt-2">{p.titulo}</h2>
                <p className="mt-3 text-tinta-2">{p.texto}</p>
              </article>
            ))}
          </div>
        </section>
      </main>

      <footer className="border-t border-regua">
        <div className="mx-auto flex max-w-[1120px] flex-col gap-2 px-4 py-8 text-sm text-tinta-2 md:flex-row md:justify-between md:px-8">
          <span>ICEIBank, projeto acadêmico de Sistemas Distribuídos.</span>
          <span>Sprint 3: eleição de líder e app offline-first.</span>
        </div>
      </footer>
    </>
  );
}
