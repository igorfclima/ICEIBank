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

O endpoint GET /contas/id/historico, protegido por JWT, lista os últimos eventos registrados para uma conta, do mais recente para o mais antigo, com tipo, vetor de relógio, hora e detalhes de cada um. O parâmetro limite define quantos eventos retornar, com padrão 10 e máximo 100. Os eventos vêm do próprio log da agência, filtrados pelo papel da conta em cada tipo de evento, por exemplo o débito aparece para a conta de origem e o crédito para a de destino. Com a persistência desligada só entram eventos registrados desde que a agência subiu, para que uma conta recriada após um reinício não herde o histórico de uma conta anterior de mesmo número, e com ela ligada o histórico atravessa reinícios porque a conta também atravessa. Escolhi essa funcionalidade porque aproveita o registro de eventos que já existe por causa do relógio lógico, dá ao correntista um extrato sem criar armazenamento novo e deixa visível a ordem das operações.

# Sprint 2

## Parte B: Relógio vetorial

**1. O que acontece com o vetor se o sistema crescer para 10 agências?**

Cada vetor passa a ter 10 posições e cada mensagem carrega 10 inteiros, ou seja, o tamanho cresce linearmente com o número de processos. Com 10 agências não é problema, mas com milhares o custo por mensagem e por evento registrado ficaria alto, e todo processo precisaria conhecer de antemão todos os participantes. Nesses casos se usam variações como vetores esparsos.

**2. V1 igual a 3,1,0 e V2 igual a 3,2,0. Qual veio primeiro?**

O evento de V1 aconteceu antes do de V2. Na posição 0 os valores são iguais, na posição 1 V1 tem 1 e V2 tem 2, e na posição 2 são iguais. Como V1 é menor ou igual a V2 em todas as posições e diferente em pelo menos uma, V1 precede V2.

**3. V1 igual a 3,1,0 e V2 igual a 1,3,0. Qual veio primeiro?**

São concorrentes. Na posição 0 V1 é maior, 3 contra 1, e na posição 1 V2 é maior, 3 contra 1. Nenhum vetor é menor ou igual ao outro em todas as posições, então nenhum evento pode ter influenciado o outro.

## Parte C: Publish/Subscribe entre agências

**1. O que aconteceu quando a Agência 1 voltou?**

Com a Agência 1 fora do ar a transferência foi publicada normalmente e a fila fila-agencia-1 reteve a mensagem, já que fila e mensagem são duráveis. Ao reiniciar, a agência reconectou ao broker e recebeu a mensagem, e o consumidor atualizou o relógio com ao_receber. O resultado depende de as contas estarem ou não persistidas. No cenário do roteiro, com PERSISTENCIA igual a 0, a conta 1 não existia mais, porque as contas ficavam apenas na memória do processo e o reinício apagou tudo, então o consumidor registrou CREDITO_REMOTO_FALHOU com o motivo conta nao encontrada e a mensagem foi desviada para a fila de mensagens mortas. A mensagem não sumiu por falha da mensageria, foi entregue corretamente, e o problema foi de estado e não de entrega. Com a persistência ligada, que é o padrão atual, a conta voltou do disco junto com o relógio vetorial e o crédito foi aplicado normalmente após o reinício.

**2. O que melhorou em relação ao Sprint 1 e o que continua em aberto?**

Melhorou que a origem não depende do destino estar no ar nem espera a resposta dele e que a mensagem fica retida até ser consumida. Também melhorou que o débito e a intenção de publicar são gravados juntos no mesmo instantâneo em disco, como numa caixa de saída: se o broker estiver indisponível ou o processo cair antes de publicar, a transferência fica pendente e é republicada sozinha quando o broker volta, e o consumidor descarta reenvios repetidos pelo id da transferência. Continua em aberto que não perder a mensagem não significa que o sistema está correto. Se o destino rejeita o crédito, por exemplo porque a conta não existe, o débito já aplicado na origem permanece e a mensagem fica parada na fila de mortas, sem estorno automático. Desfazer o débito de forma coordenada exige um protocolo de compensação ou de transação distribuída, que é o tema do Sprint 4.

**3. O consumidor processar créditos sem verificar JWT é um problema de segurança?**

Era um problema. O JWT protege apenas a porta HTTP, e o consumidor aceitava qualquer mensagem que chegasse na fila, de modo que quem tivesse a URL AMQP, que contém usuário e senha da instância, conseguia publicar um crédito para qualquer conta e criar dinheiro sem nunca ter feito login. Agora cada mensagem viaja em um envelope assinado com HMAC SHA-256 usando um segredo compartilhado entre as agências, e o consumidor verifica a assinatura antes de mexer no relógio ou no saldo. No teste, mensagens sem assinatura e com assinatura errada foram rejeitadas, registraram MENSAGEM_INVALIDA, não alteraram o saldo e foram para a fila de mortas. O risco que sobra é o segredo ser compartilhado, então quem o conhece ou uma agência comprometida ainda consegue forjar mensagens, e o ideal seria uma chave por agência com permissões separadas no broker.

## Parte D: Linha do tempo causal

**1. O que torna a comparação confiável no relógio vetorial?**

O vetor guarda um contador por agência, então registra quanto cada processo já viu. Isso permite comparar posição a posição: se um vetor é menor ou igual ao outro em todas as posições, o primeiro evento está na história causal do segundo, e se cada um é maior em alguma posição, nenhum conhecia o outro. No Lamport todo o histórico é resumido em um único inteiro, por isso um número menor não prova causalidade. No vetor a relação vale nos dois sentidos.

**2. Par de eventos concorrentes encontrado no teste.**

O script apontou como concorrentes o CRIAR_CONTA da Agência 0, vetor 1,0,0, e o CRIAR_CONTA da Agência 1, vetor 0,1,0. Faz sentido, porque cada agência criou uma conta local sem trocar nenhuma mensagem com a outra, então nenhum evento chegou a conhecer o outro. Já o débito da Agência 0, vetor 2,0,0, e o crédito remoto da Agência 1, vetor 3,2,0, não apareceram na lista, pois o primeiro é menor ou igual ao segundo em todas as posições, o que reflete a causalidade real, já que o crédito só existe porque o débito publicou a mensagem.

**3. O algoritmo quadrático seria um problema com milhões de eventos?**

Seria, já que compara todos os pares e chegaria a trilhões de comparações. Dentro de uma mesma agência os eventos já são totalmente ordenados pelo próprio contador, então bastaria comparar cada evento com o último evento conhecido de cada outra agência, o que reduz o custo para o número de eventos vezes o número de agências. Também seria possível analisar apenas janelas de tempo, processar o fluxo de eventos de forma contínua em vez de em lote, ou comparar sob demanda só os pares que interessam.

## Funcionalidade adicional: fila de mensagens mortas

Cada fila de agência foi declarada com uma dead-letter exchange, a iceibank.mortas, que entrega na fila fila-mortas. Quando o consumidor não consegue aplicar um crédito, como no caso de conta inexistente, ele registra o evento CREDITO_REMOTO_FALHOU e rejeita a mensagem sem devolvê-la à fila, e o RabbitMQ a desvia para fila-mortas junto com o motivo da rejeição. Escolhi essa funcionalidade porque ela resolve o problema que o próprio teste de resiliência expõe: antes a mensagem seria descartada e o valor se perderia sem rastro, e agora ela fica retida para inspeção ou reprocessamento manual. No teste a fila de mortas passou de 0 para 1 mensagem, preservando o id da transferência, a conta, o valor e o vetor de envio.

## Decisões de projeto além do roteiro

Cada transferência recebe um idTransferencia, um UUID gerado na origem que acompanha os eventos de débito, publicação e crédito. O consumidor guarda os ids já aplicados e descarta reentregas, registrando CREDITO_REMOTO_DUPLICADO, e no teste a mesma mensagem publicada duas vezes, inclusive depois de reiniciar a agência, creditou uma só vez.

O estado de cada agência, formado por contas, ids processados, transferências pendentes e vetor do relógio, é gravado em data/estado-agencia-N.json a cada operação, de forma atômica. Persistir o vetor foi necessário porque, sem isso, um reinício zeraria o contador da própria agência e quebraria a ordem causal dos eventos. A persistência vem ligada por padrão e a variável PERSISTENCIA igual a 0 a desliga para reproduzir o cenário do roteiro. A transferência remota usa o padrão de caixa de saída: o débito e a mensagem pendente são gravados juntos, a publicação é tentada em seguida e uma thread republica o que sobrou, com resposta 202 e status pendente quando o broker está fora. Como a entrega é pelo menos uma vez e o consumidor é idempotente, o efeito final é um só crédito.

A autorização, que no Sprint 1 era o ponto em aberto da pergunta 1 da Parte F, foi implementada. Existem dois papéis, operador e cliente, e cada conta tem um dono. Operador acessa qualquer conta e cria contas para outros usuários, enquanto cliente só consulta, deposita, saca, transfere a partir da própria conta e vê o próprio histórico, com resposta 403 nos demais casos. Receber uma transferência não exige ser dono do destino. Os usuários ficam em config.py, com admin como operador e ana, beto e caio como clientes de demonstração.

Os eventos passaram a ter idEvento e são publicados em uma fila de auditoria, consumida pelo script auditoria.py, que grava um log central em data/auditoria.jsonl sem duplicar eventos. Se a agência cair antes de publicar, os eventos do log local posteriores ao último publicado são reenviados na subida, e no teste todos os 24 eventos locais apareceram no log central. O comando mesclar_logs com a opção central lê esse log único, e sem a opção continua mesclando os arquivos de cada agência.

Como o Flask atende requisições em várias threads e o consumidor roda em outra, o estado das agências é protegido por uma trava, e a mesma trava dispara a gravação em disco ao fim de cada operação.
