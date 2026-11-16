# ICEIBank — Design System (MASTER)

Fonte da verdade visual para o web (Next.js + Tailwind v4) e o app (Flutter, Android, Material 3). Regras de uma tela específica entram em `pages/<tela>.md` e sobrescrevem este arquivo só naquela tela. Produto e usuários estão em `PRODUCT.md`; este arquivo só decide aparência e comportamento visual.

## 1. Mundo visual: papel-moeda

A identidade vem da cédula do Real, o objeto que o correntista brasileiro conhece melhor: papel de algodão, tinta ferro, uma cor por denominação, número grande, número de série, assinatura. Em tela de trabalho o mundo empresta exatamente quatro coisas: tipografia, paleta, densidade e um movimento de assinatura. Ele nunca empresta layout, modelo de navegação nem controles. No web os controles são componentes web comuns; no app são componentes Material 3 nativos.

Tese: cada agência é uma denominação. A cor da agência de entrada tinge a barra do produto; o relógio vetorial é o número de série de cada lançamento; a líder é quem assina. O que está pendente fica em marca d'água até ganhar série.

Proibido em telas de trabalho: guilhoché, textura de papel, ornamento, brilho, gradiente, roxo, fonte display em rótulo ou botão, emoji como ícone, sombra flutuante, cantos muito arredondados. Guilhoché e a cédula como objeto só existem na landing, como asset autorado.

Disciplinas absorvidas na rodada de direção, cada uma com dono nomeado:

- Coluna de série alinhada (de um mundo de barcode em preto e branco): toda série e todo vetor ficam numa coluna de largura fixa, alinhada em qualquer lista.
- Código e posição são o mesmo lugar (de um catálogo de evento com mapa do salão): tocar numa série leva ao evento na linha do tempo.
- Régua de um pixel e estados como marcas impressas (de uma edição de referência com trilho central): toda regra tem 1 pixel físico; pressionado preenche, desabilitado risca, foco bracketa.
- Só a ativa a cores (de uma capa de gravadora em código de cores): apenas a agência de entrada tem cor cheia; as outras são contorno em tinta com um ponto de cor.
- O painel vira à vista quando muda (de tiles tipográficos ao vivo): a troca de líder é uma virada no lugar, com hora de início marcada, nunca uma troca silenciosa.

## 2. Cor

Estratégia: contida com faixas comprometidas. Fundo de papel, tinta ferro, e a cor da agência ocupando a barra inteira do produto, não um detalhe. Estados têm cor própria e nunca são indicados só por cor.

### Tema claro (padrão)

| Papel | Token | Hex | Uso |
|---|---|---|---|
| Fundo | `papel` | #F3F2EE | Ground de toda tela |
| Fundo 2 | `papel-2` | #EAE8E1 | Painéis laterais, barra inferior, linhas selecionadas |
| Tinta | `tinta` | #1C1B19 | Texto, ícones, regras fortes |
| Tinta 2 | `tinta-2` | #5C5A55 | Texto secundário, rótulos |
| Regra | `regra` | rgba(28,27,25,0.14) | Divisores, 1 px físico |
| Agência 0 | `ag0` | #157A89 | Turquesa da nota de 100; texto sobre ela: #FFFFFF |
| Agência 1 | `ag1` | #D9A520 | Amarelo da nota de 20; texto sobre ela: `tinta` |
| Agência 2 | `ag2` | #8A5A2B | Ocre da nota de 50; texto sobre ela: #FFFFFF |
| Tinta da agência | `ag-tinta` | cor da agência a 10% sobre `papel` | Linha selecionada, chip da líder, fundo do cartão da conta |
| Erro | `erro` | #B3261E | Conflito, saldo insuficiente, 401; texto sobre ele: #FFFFFF |
| Alerta | `alerta` | #9A4A06 | Sem conexão, agência fora do ar |
| Sucesso | `sucesso` | #2E7D32 | Sincronizado, transferência concluída |
| Foco | `foco` | `tinta` | Contorno de 2 px com afastamento de 2 px |

Contrastes verificados: `tinta` sobre `papel` 15:1; `tinta-2` sobre `papel` 6,4:1; branco sobre `ag0` 5,0:1; `tinta` sobre `ag1` 7,8:1; branco sobre `ag2` 5,9:1; `erro` sobre `papel` 5,8:1; `sucesso` sobre `papel` 4,6:1.

### Tema escuro (o verso)

Obrigatório no Android como esquema de primeira classe, nunca uma inversão automática.

| Token | Hex |
|---|---|
| `papel` | #141412 |
| `papel-2` | #1F1E1B |
| `tinta` | #F3F2EE |
| `tinta-2` | #B5B2AA |
| `regra` | rgba(243,242,238,0.14) |
| `ag0` | #3FB0C0, texto sobre ela `tinta` escura #141412 |
| `ag1` | #E6B935, texto sobre ela #141412 |
| `ag2` | #C68A4E, texto sobre ela #141412 |
| `erro` | #E5484D |
| `alerta` | #E08A3C |
| `sucesso` | #5BB960 |

Os pares do tema escuro precisam de verificação de contraste na construção, antes da entrega.

### Mapeamento Material 3 (Flutter)

`primary` = cor da agência de entrada; `onPrimary` = texto sobre ela; `surface` = `papel`; `surfaceContainer` = `papel-2`; `onSurface` = `tinta`; `onSurfaceVariant` = `tinta-2`; `outlineVariant` = `regra`; `error` = `erro`; `secondaryContainer` = `ag-tinta`. Dynamic Color desligado de propósito: a paleta da cédula é compromisso de marca. O `ThemeData` é reconstruído quando a agência de entrada muda.

### Mapeamento Tailwind v4 (web)

Os mesmos tokens em `@theme` no `globals.css`: `--color-papel`, `--color-papel-2`, `--color-tinta`, `--color-tinta-2`, `--color-regra`, `--color-ag0`, `--color-ag1`, `--color-ag2`, `--color-erro`, `--color-alerta`, `--color-sucesso`. A cor da agência ativa vai para uma variável `--ag-ativa` definida no `<html>` pelo estado da sessão. Tema escuro por `prefers-color-scheme` e por atributo `data-tema`.

## 3. Tipografia

Uma família de trabalho com eixo de largura, mais uma mono para o registro de série.

- **Archivo** (variável: `wdth` 62–125, `wght` 100–900). A largura é a voz: condensada para rótulos em caixa alta como numa cédula, normal para texto, expandida para o número grande.
- **Courier Prime** para série, vetor, idTransferencia, idEvento: lê-se como numeração de cédula.
- Números sempre tabulares: `font-feature-settings: "tnum"` no web, `FontFeature.tabularFigures()` no Flutter.

Escala fixa, razão 1,2, mapeada aos papéis Material:

| Papel | Fonte | Largura | Peso | Tamanho/linha | Uso |
|---|---|---|---|---|---|
| display (saldo) | Archivo | 112 | 700 | 36/40 | Saldo da conta, único número grande por tela |
| headline | Archivo | 100 | 600 | 28/32 | Título de tela |
| title | Archivo | 100 | 600 | 20/28 | Título de seção, card |
| title-sm | Archivo | 100 | 600 | 16/24 | Linha principal de lista |
| body | Archivo | 100 | 400 | 16/24 | Texto |
| body-sm | Archivo | 100 | 400 | 14/20 | Texto secundário |
| label (rótulo de cédula) | Archivo | 75 | 600 | 12/16, caixa alta, espaçamento +0,06em | Rótulos de campo e de cartão, kickers |
| série | Courier Prime | — | 400 | 13/18 | Série, vetor, ids |

Web: `next/font/google` com `Archivo` e `axes: ["wdth"]`, mais `Courier_Prime`. Flutter: arquivos `Archivo[wdth,wght].ttf` e `CourierPrime-Regular.ttf` / `CourierPrime-Bold.ttf` em `assets/fonts/`, largura por `FontVariation('wdth', n)`, tamanhos em `sp`. Nenhuma fonte servida por CDN no app.

## 4. Espaço, forma e régua

- Ritmo 4/8: 4, 8, 12, 16, 24, 32, 48, 64. Margem de página 16 no celular, 24 em tablet, 32 no web; conteúdo do web até 1120 px.
- Cantos: `xs` 2 px no cartão da conta e nos campos; `sm` 6 px em botões e chips; círculo só no ponto de cor da agência. Nada acima de 6 px em tela de trabalho.
- Regra: 1 pixel físico (`1 / devicePixelRatio` no Flutter, `0.5px`/`1px` com `@media (min-resolution)` no web). Cards nunca flutuam: separação por `papel-2` ou por regra, sem sombra.
- Alvos de toque 48 dp com 8 dp entre eles. Ícones 24 px, Material Symbols Outlined peso 400 em ambas as plataformas, uma família só por hierarquia. Escolha minha, sem resultado na base do UI/UX Pro Max.
- Densidade padrão; listas de lançamentos podem apertar para linhas de 48 dp.

## 5. Movimento

Movimento só comunica estado. Nada decorativo em tela de trabalho.

| Token | Duração | Uso |
|---|---|---|
| `rapido` | 120 ms | Pressionado, foco, chip |
| `padrao` | 200 ms | Troca de estado, banner entrando |
| `virada` | 240 ms | Virada do painel de líder, saldo provisório virando confirmado |

Easing padrão Material (`cubic-bezier(0.2, 0, 0, 1)`). Com redução de movimento ativa, a virada vira crossfade e o resto corta direto. Nenhuma sequência de entrada de página.

## 6. Movimento de assinatura e estados especiais

- **Série.** Todo lançamento mostra seu vetor na coluna de série, em Courier Prime, no formato `[7 · 2 · 0]`, com a posição da própria agência em negrito. A série é tocável e leva ao evento na linha do tempo.
- **Marca d'água (pendente).** Operação feita offline ganha fundo hachurado em regras de 1 px a 45° com passo de 8 px, texto em `tinta-2`, chip `Pendente · sem série` e a coluna de série mostrando `[— · — · —]`. O saldo provisório aparece com o mesmo tratamento e um rótulo `provisório`. Nunca se confunde com confirmado.
- **Conflito.** Sincronização recusada com 409 mostra a série conhecida riscada e a série atual ao lado, chip `Conflito` em `erro`, e abre a decisão do usuário. Nunca se resolve sozinho sem aviso.
- **Assinatura (líder).** O painel de liderança termina num rodapé `Assina: Agência 2`, com regra abaixo e `desde 14:32:05`. Quando a líder muda, a faixa vira no lugar (`virada`), e a hora de início é atualizada.
- **Só a ativa a cores.** A barra do produto tem a cor da agência de entrada. No indicador de agências, a ativa tem preenchimento; as outras são contorno em `tinta` com um ponto de 8 px na cor delas; agência fora do ar tem o ponto vazio e o rótulo `fora do ar` em `alerta`.
- **Sem conexão.** Faixa persistente no topo, abaixo da barra, em `alerta` sobre `papel-2`: `Sem conexão · 2 pendentes`. Some com `padrao` quando a conexão volta e a fila zera.

## 7. Componentes (vocabulário comum)

Cada componente existe nas duas plataformas com os mesmos estados: padrão, hover (web), foco, pressionado, desabilitado, carregando, erro.

| Componente | Web | Flutter | Notas |
|---|---|---|---|
| Barra da agência | `<header>` tingido com `--ag-ativa` | `AppBar` com `backgroundColor: primary` | Nome ICEIBank em `title`, seletor de agência à direita |
| Cartão da conta | `<section>` com `ag-tinta`, canto 2 px | `Card` com `surfaceTint` desligado | Titular, nº da conta, saldo em display, série do último evento |
| Botão | filled, tonal, outlined, text | `FilledButton`, `FilledButton.tonal`, `OutlinedButton`, `TextButton` | Canto 6 px; pressionado preenche, desabilitado risca o rótulo |
| Campo | `<label>` acima + `<input>` | `TextField` com `labelText` | Erro abaixo do campo, nunca só no topo; teclado numérico para valor |
| Chip de estado | `<span role="status">` | `Chip` | `Pendente`, `Sincronizado`, `Conflito`, `Líder`, `Ativa`, `Fora do ar` |
| Banner | `<div role="status">` | `MaterialBanner` | Aviso persistente; nunca para sucesso |
| Toast / Snackbar | toast no canto | `SnackBar` com ação | Sucesso e desfazer |
| Painel de líder | seção com faixa + indicador + rodapé | `Card` dedicado na aba Agências | Virada ao mudar; hora de início |
| Lista de lançamentos | tabela com coluna de série fixa | `ListView.builder` com `itemExtent` | Linhas de 48 dp, série alinhada à direita |
| Fila de pendentes | seção | `BottomSheet` ou seção na conta | Ordem de criação, ação `tentar agora` |
| Diálogo de conflito | `<dialog>` | `AlertDialog` | Saldo real, operação pendente, três ações |
| Estado vazio | texto + ação | texto + ação | Ensina a interface: `Nenhuma conta em cache. Consulte uma conta enquanto estiver conectado.` |
| Esqueleto | blocos em `papel-2` | `Shimmer` desligado, blocos estáticos | Sem spinner no meio do conteúdo |

Navegação: web mantém a página única com seções e ganha uma seção `Agências`; Android usa `NavigationBar` com três destinos, `Conta`, `Transferir`, `Agências`, mais tela de login antes. Botão Voltar do sistema sempre funciona.

## 8. Anti-padrões

- Roxo, gradiente, brilho, vidro: o visual anterior cai no clichê de fintech gerada por IA.
- Creme com terracota e serifa: o mundo do papel não é esse; as faixas saturadas e a ausência de serifa seguram.
- Cor como único indicador de estado.
- Spinner no lugar de esqueleto; modal como primeira ideia.
- Texto abaixo de 12 sp; cinza sobre cinza; hex solto em componente.
- Placeholder como rótulo de campo.
- Dois números grandes na mesma tela.

## 9. Checklist antes de entregar

- Contraste 4,5:1 nos dois temas, verificado, não inferido.
- Toque 48 dp, áreas seguras, barra inferior não cobre conteúdo.
- Tamanho de fonte do sistema a 1,3 sem corte; redução de movimento respeitada.
- Todo ícone com nome acessível ou escondido quando decorativo.
- Série alinhada em toda lista; estados pendente, conflito e líder visíveis sem cor.
- Teste em 375 px e em paisagem; captura pelo emulador com `adb exec-out screencap`.
