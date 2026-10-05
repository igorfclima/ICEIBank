## Atividade de recapitulação do sistema desenvolvido

### 1. Arquitetura atual e divisão em agências

Atualmente em um app.py feito com Flask executado 3 vezes sendo 1 para cada agência. Cada instancia começa com 1 dicionário de contas único na memória, sem utilizar banco. Tudo é executado localmente e só depende de agências externas quando é uma conta de agência x transfêrindo para conta de agência y.

### 2. Comunicação atual entre as agências

REST sincrono simples, request.post como endpoint para a agência de destino com as informações de timestamp,valor e token repassado. A origem debita e o manda a chamada e só responde o cliente quando a chamada retorna.  Quando falha debita da origem inevitavelmente, realmente é um ponto de melhora.

### 3. Operações distribuídas e seus efeitos

A origem é verificada se existe, origem inicia a transação, iniciao o timestamp do debito, verifica o saldo, conta origem debita o saldo, verifica se a conta destino existe se não existir retorna o saldo, inicia o timestamp credito, conta destino recebe o valor, faz registro e retorna positivo.

### 5. Mensageria e comunicação indireta

Produtor -> Agencia após o debito
Canal -> Topico por agencia
Consumidor -> Agencia de destino

Mensagem = id,origem,timestamp,destino e valor.

### 6. Entrega, duplicidade e processamento de mensagens

Se envia uma mensagem de transação sem id 2 vezes o valor pode ser debitado 2 vezes ou quebrar o extrato com 1 transação falsa. Seria necessário um id unico de transação que após o recebimento da 1 fosse destruido.

### 7. Eventos concorrentes e ordenação causal

2 agencias fizeram transferencias entre si, a mensagem chegou na outra após o envio da propria.

### 8. Relógio vetorial na aplicação

Cada agencia possui um vetor de n agencias. 

### 9. Consistência e observabilidade dos eventos

Hoje é enviado variaveis separadas e inteiros, poderia trocar para um vetor completo com as informações assim podendo ser comparado e evitando duplicidade.

### 10. Proposta de evolução para a próxima implementação

Provavelmente teria que mudar na tranferencias entre agencias, inserir mensageria entre as n agencias.