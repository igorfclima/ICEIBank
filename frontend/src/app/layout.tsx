import type { Metadata } from "next";
import { Archivo, Courier_Prime } from "next/font/google";
import "./globals.css";

const archivo = Archivo({
  subsets: ["latin"],
  variable: "--fonte-archivo",
  axes: ["wdth"],
});

const serie = Courier_Prime({
  subsets: ["latin"],
  variable: "--fonte-serie",
  weight: ["400", "700"],
});

export const metadata: Metadata = {
  title: "ICEIBank",
  description:
    "Banco didático em três agências: liderança eleita entre elas, relógio vetorial em cada lançamento e operação offline que sincroniza sozinha.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="pt-BR">
      <body className={`${archivo.variable} ${serie.variable}`}>{children}</body>
    </html>
  );
}
