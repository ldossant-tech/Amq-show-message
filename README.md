Para que o console do AMQ Broker consiga exibir a mensagem completa, foram adicionadas duas configurações porque existem dois pontos diferentes envolvidos na visualização da mensagem.

### 1. Configuração do console/management do broker

```properties id="vv3h4w"
addressSettings."activemq.management#".managementMessageAttributeSizeLimit=-1
```

Essa configuração remove o limite interno das respostas administrativas do broker.

Na prática:
quando o console tenta abrir uma mensagem, ele faz uma consulta interna no broker para buscar o conteúdo da mensagem. Por padrão, essa resposta possui limite de tamanho para evitar excesso de memória e tráfego no console.

Com `-1`, removemos esse limite e permitimos que o console receba o conteúdo completo da mensagem.

Sem essa configuração, o console pode cortar o payload e exibir apenas parte dele.

---

### 2. Configuração específica da fila/address

```properties id="1a6bq2"
addressSettings.showLines.managementMessageAttributeSizeLimit=-1
```

Essa configuração aplica o mesmo comportamento especificamente para o address/fila `showLines`.

Ela garante que, ao consultar mensagens dessa fila, o broker também não limite o tamanho das informações retornadas.

---

### Resumindo de forma simples

As duas configurações trabalham juntas:

* a primeira libera o limite do mecanismo interno de gerenciamento do console;
* a segunda garante que a fila específica também permita retornar mensagens completas.

Com isso, o console consegue exibir o payload inteiro da mensagem sem truncar conteúdo ou apresentar “more X lines...”.
