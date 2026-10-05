# Sprint 1

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

## Funcionalidade adicional: histórico de transações por conta

O endpoint GET /contas/id/historico, protegido por JWT, lista os últimos eventos da conta, do mais recente para o mais antigo, com limite padrão de 10 e máximo de 100. Os eventos vêm do log da agência, filtrados pelo papel da conta em cada um, então o débito aparece para a origem e o crédito para o destino. Escolhi essa funcionalidade porque aproveita o registro de eventos que já existe e dá um extrato sem criar armazenamento novo.

# Sprint 2

## Parte B: Relógio vetorial

**1. O que acontece com o vetor se o sistema crescer para 10 agências?**

Cada vetor passa a ter 10 posições e cada mensagem carrega 10 inteiros, então o custo cresce linearmente com o número de agências. Com 10 não é problema, mas com milhares seria.

**2. V1 igual a 3,1,0 e V2 igual a 3,2,0. Qual veio primeiro?**

V1 veio antes. Ele é menor ou igual a V2 em todas as posições e menor na posição 1, com 1 contra 2.

**3. V1 igual a 3,1,0 e V2 igual a 1,3,0. Qual veio primeiro?**

São concorrentes. V1 é maior na posição 0 e V2 é maior na posição 1, então nenhum domina o outro e nenhum pode ter influenciado o outro.

## Parte C: Publish/Subscribe entre agências

**1. O que aconteceu quando a Agência 1 voltou?**

A fila reteve a mensagem enquanto a agência estava fora, e ao voltar ela foi entregue. Com as contas só em memória, que é o cenário do roteiro e corresponde a PERSISTENCIA igual a 0, a conta 1 não existia mais, então o consumidor registrou CREDITO_REMOTO_FALHOU e a mensagem foi para a fila de mortas. A mensageria não falhou, o problema foi de estado. Com a persistência ligada, que é o padrão, a conta voltou do disco e o crédito foi aplicado.

**2. O que melhorou em relação ao Sprint 1 e o que continua em aberto?**

Melhorou que a origem não depende do destino estar no ar e que a mensagem fica retida até ser consumida. Continua em aberto que não perder a mensagem não garante que o sistema esteja correto: se o destino rejeita o crédito, o débito na origem permanece e a mensagem fica parada na fila de mortas, sem estorno. Corrigir isso exige transação distribuída, que é o tema do Sprint 4.

**3. O consumidor processar créditos sem verificar JWT é um problema de segurança?**

Era. O JWT protege só a porta HTTP, então quem tivesse a URL AMQP publicava um crédito para qualquer conta sem fazer login. Agora cada mensagem é assinada com HMAC e o consumidor rejeita as sem assinatura válida, o que foi confirmado no teste. O risco que resta é o segredo ser compartilhado entre as agências.

## Parte D: Linha do tempo causal

**1. O que torna a comparação confiável no relógio vetorial?**

O vetor guarda um contador por agência, então dá para comparar posição a posição. Se um é menor ou igual ao outro em todas as posições, houve causalidade, e se cada um é maior em alguma posição, são concorrentes. No Lamport um único inteiro não permite concluir isso.

**2. Par de eventos concorrentes encontrado no teste.**

O CRIAR_CONTA da Agência 0, vetor 1,0,0, e o CRIAR_CONTA da Agência 1, vetor 0,1,0. Faz sentido porque cada agência criou uma conta local sem trocar mensagem com a outra. Já o débito e o crédito remoto da transferência não apareceram como concorrentes, porque o crédito só existe por causa do débito.

**3. O algoritmo quadrático seria um problema com milhões de eventos?**

Seria, porque compara todos os pares. Dentro de uma agência os eventos já são ordenados pelo contador, então bastaria comparar cada evento com o último de cada outra agência, ou analisar apenas janelas de tempo.

## Funcionalidade adicional: fila de mensagens mortas

As filas das agências desviam para a fila fila-mortas as mensagens que o consumidor não consegue aplicar, como um crédito para conta inexistente, junto com o motivo da rejeição. Escolhi essa funcionalidade porque ela resolve o problema exposto pelo teste de resiliência: em vez de o valor se perder sem rastro, a mensagem fica retida para inspeção. No teste a fila de mortas foi de 0 para 1 mensagem, com o payload preservado.

## Decisões de projeto além do roteiro

Cada transferência tem um idTransferencia, e o consumidor descarta mensagens repetidas com esse id, o que foi testado inclusive depois de reiniciar a agência. O estado de cada agência, incluindo o vetor do relógio, é gravado em disco a cada operação, e a variável PERSISTENCIA igual a 0 desliga isso para reproduzir o cenário do roteiro. O débito e a mensagem pendente são gravados juntos, e uma thread republica o que sobrar, então a transferência não se perde se o broker estiver fora ou o processo cair.

Foi implementada autorização com dois papéis, operador e cliente, e cada conta tem um dono. O cliente só acessa as próprias contas e recebe 403 nas demais, e receber transferência não exige ser dono do destino. Os eventos também são publicados em uma fila de auditoria, e o script auditoria.py monta um log central, lido por mesclar_logs com a opção central. Por fim, o Flask atende em várias threads, então o estado é protegido por uma trava.
