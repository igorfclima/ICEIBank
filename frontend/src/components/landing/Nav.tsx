import Link from "next/link";
import { Marca } from "@/components/Marca";

const itens = [
  { href: "#recursos", texto: "Recursos" },
  { href: "#seguranca", texto: "Segurança" },
  { href: "#agencias", texto: "Agências" },
  { href: "#linha-do-tempo", texto: "Linha do tempo" },
];

export function Nav() {
  return (
    <header className="sticky top-0 z-50 border-b border-borda bg-fundo/70 backdrop-blur-xl">
      <nav className="mx-auto flex max-w-6xl items-center justify-between px-5 py-4">
        <Marca className="text-lg" />
        <div className="hidden items-center gap-8 text-sm text-texto-fraco md:flex">
          {itens.map((i) => (
            <a key={i.href} href={i.href} className="transition-colors hover:text-texto">
              {i.texto}
            </a>
          ))}
        </div>
        <Link
          href="/app"
          className="rounded-full bg-roxo px-5 py-2 text-sm font-semibold text-[#14121c] transition-colors hover:bg-roxo-suave"
        >
          Abrir o app
        </Link>
      </nav>
    </header>
  );
}
