# RESPOSTAS

## Parte B: Relógio de Lamport

**1. Por que max entre local e recebido, mais 1, e não só o timestamp recebido?**

Para o contador nunca retroceder. O max mantém a monotonicidade e o mais 1 deixa o recebimento posterior ao envio.

**2. Agência 0 no contador 10 recebe timestamp 3. Novo valor?**

O novo valor é max de 10 e 3, mais 1, igual a 11. A agência rápida ignora valores baixos vindos de uma agência lenta. O número de Lamport ordena causalidade, não mede tempo real nem volume de trabalho.

## Parte D: Transferências

**1. Por que local não usa ao_enviar e ao_receber, e entre agências usa?**

Na transferência local o débito e o crédito acontecem no mesmo processo, sob o mesmo relógio, então dois evento_local já ordenam tudo. Na transferência entre agências os relógios são diferentes, então a origem marca o envio com ao_enviar e manda o timestamp junto, e o destino faz ao_receber para não ficar atrás da origem e manter a ordem débito antes de crédito.

**2. O saldo da origem foi revertido após o erro?**

Não foi. O débito foi aplicado, de 50 para 35, a agência de destino caiu, veio a resposta 502 e o crédito nunca ocorreu. O sistema fica inconsistente, com dinheiro sumido, e só resta o registro TRANSFERENCIA_FALHOU no log, sem nenhuma compensação automática.

**3. Duas formas de corrigir no Sprint 4:**

Uma é o 2PC, em que um coordenador pergunta a origem e destino se podem efetivar e só confirma se ambas votarem sim, senão manda todas abortarem. Outra é a Saga, em que cada passo tem uma ação compensatória, de modo que se o crédito falha o débito é estornado para desfazer o efeito parcial.

## Parte E: Linha do tempo unificada

**Observação do passo 3:**

Apareceram empates de timestampLamport entre agências diferentes, por exemplo três CRIAR_CONTA em Lamport 1, uma em cada agência. Esses eventos são concorrentes, porque nenhuma agência trocou mensagem com a outra antes deles, então nada obriga uma ordem. Comparando com a horaParede, a ordem física nem sempre bate com a ordem de Lamport.

**1. Timestamps diferentes sem saber se um influenciou o outro:**

Um timestamp menor que outro pode significar que o primeiro causou o segundo ou apenas que os dois são concorrentes e o número ficou menor por acaso. O relógio de Lamport não distingue os dois casos, então um número menor não autoriza concluir que houve influência.

**2. Lamport sozinho basta para distinguir concorrente de aconteceu antes?**

Não basta. Ele garante só a ida, ou seja, se um evento causou outro então a ordem numérica segue, mas a volta não vale. Para afirmar com certeza que dois eventos são concorrentes é preciso o relógio vetorial do Sprint 2.

## Parte F: Autenticação JWT

**Decisões de design:**

As credenciais são usuário e senha, enviados em POST /auth/login, porque quem usa o sistema neste sprint é o operador da agência e não o correntista, e as contas ainda não têm dono nem senha própria. O usuário único admin vem das variáveis de ambiente USUARIO e SENHA, e o segredo de assinatura fica em JWT_SECRET. A expiração do token é de uma hora. A biblioteca usada é a PyJWT, com o algoritmo HS256. A rota creditar-remoto também exige token, e a agência de origem repassa o cabeçalho Authorization que recebeu do frontend. Como as três agências compartilham o mesmo JWT_SECRET, deixar essa rota aberta criaria um caminho sem autenticação para creditar qualquer conta, bastando falar direto com a porta da agência de destino. Um token de serviço dedicado entre agências seria mais correto em produção, por separar credencial de usuário de credencial de sistema, mas é uma complexidade que não se paga neste sprint.

**1. Autenticação x autorização, qual a implementação verifica?**

A implementação verifica só autenticação. Qualquer requisição com um JWT válido passa, e não há vínculo entre o sub do token e o dono da conta, então um usuário autenticado consegue sacar de uma conta que não é dele. Faltaria a camada de autorização, que checaria se quem pede a operação é o dono da conta.

**2. Por que validar o JWT não precisa de banco a cada requisição?**

Validar o token é recalcular a assinatura HMAC sobre o cabeçalho e o payload com a mesma chave e comparar, uma operação local sem acesso a disco, e os dados da sessão como usuário e expiração vão dentro do próprio token. Guardar sessões em memória obrigaria o servidor a consultar uma tabela a cada requisição e amarraria o cliente à instância que criou a sessão. Com JWT qualquer instância valida qualquer token sabendo apenas a chave, o que permite escalar na horizontal sem estado compartilhado.

**3. E se a chave secreta vazar?**

Qualquer pessoa passa a forjar tokens válidos com qualquer identidade e qualquer expiração, e o servidor não distingue um token forjado de um legítimo, então a autenticação fica totalmente comprometida. A correção é rotacionar a chave na hora, o que invalida todos os tokens em circulação, e usar expiração curta com refresh token para reduzir a janela de exposição.

## Parte G: Frontend

**Tecnologia:**

O frontend é feito em Next.js 16 com App Router, React, TypeScript e Tailwind. Há uma landing page de marketing na raiz, no estilo do site da Phantom mas em português, e o app fica na rota app. O backend passou a enviar cabeçalhos CORS através da flask-cors para o front em outra porta conseguir consumir a API.

**1. Como o frontend reenvia o token a cada requisição?**

No login o token recebido é gravado no localStorage, em lib/session.ts. Toda chamada à API passa por um único wrapper de fetch, em lib/api.ts, que lê o token da sessão e injeta o cabeçalho Authorization Bearer antes de enviar. Nenhum componente monta esse cabeçalho manualmente.

**2. O que acontece se o token expirar no meio do uso?**

O wrapper transforma qualquer resposta que não seja de sucesso em um ErroApi com o status. O hook controlador, em hooks/useBanco.ts, detecta o status 401 com sessão ativa, limpa o localStorage, volta para a tela de login e mostra a mensagem de sessão expirada pedindo novo login. É um aviso explícito na interface, não um erro genérico no console.

**3. Onde estão o Model, a View e o Controller?**

O Model é o lib/session.ts, que guarda token e agência de entrada no localStorage, junto com o estado do React mantido pelo hook, como a conta em foco e os avisos. A View são os componentes em components/app, que apenas recebem props e disparam callbacks e não falam com a API. O Controller é o hook hooks/useBanco.ts, que reage aos eventos da view, chama a camada de serviço em lib/api.ts, atualiza o estado e devolve tudo para a view redesenhar. A separação ficou clara e as dependências fluem numa direção só, da view para o controller e daí para api e model. Com React a fronteira entre view e controller é menos rígida que no MVC clássico, porque a view é função do estado e não é redesenhada à mão, mas cada arquivo mantém uma responsabilidade única.
