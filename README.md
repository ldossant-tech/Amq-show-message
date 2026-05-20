# Exibição de mensagens completas no console do AMQ Broker

Para permitir que o console do AMQ Broker exiba o payload completo das mensagens, foram adicionadas as seguintes configurações:

```properties id="z1kq7p"
addressSettings."activemq.management#".managementMessageAttributeSizeLimit=-1
addressSettings.showLines.managementMessageAttributeSizeLimit=-1
```

---

# O que cada configuração faz?

## 1. Configuração do canal interno de gerenciamento

```properties id="m4tw8s"
addressSettings."activemq.management#".managementMessageAttributeSizeLimit=-1
```

O console do AMQ Broker utiliza um canal interno de gerenciamento chamado:

```text
activemq.management#
```

Toda vez que um usuário:

* abre uma mensagem;
* consulta headers;
* visualiza propriedades;
* realiza browse da fila;

o console faz chamadas administrativas internas para esse canal.

Por padrão, essas respostas possuem limite de tamanho para evitar:

* alto consumo de memória;
* excesso de tráfego;
* lentidão no console.

A configuração acima remove esse limite para as operações administrativas.

Sem ela, o console pode:

* truncar mensagens;
* cortar payloads;
* exibir:

  ```text
  more X lines...
  ```

---

## 2. Configuração específica da fila/address

```properties id="g8p3xa"
addressSettings.showLines.managementMessageAttributeSizeLimit=-1
```

Essa configuração aplica o mesmo comportamento especificamente para a fila/address `showLines`.

Ela garante que, ao consultar mensagens dessa fila, o broker também permita retornar o conteúdo completo.

---

# Por que são necessárias as duas configurações?

As duas atuam em pontos diferentes:

| Configuração           | Função                                                                         |
| ---------------------- | ------------------------------------------------------------------------------ |
| `activemq.management#` | Libera o limite das respostas administrativas internas utilizadas pelo console |
| `showLines`            | Libera o limite para a fila/address específica                                 |

Ou seja:

* uma libera o mecanismo interno do console;
* a outra libera a fila consultada.

As duas juntas garantem que o payload completo seja exibido.

---

# O que o número do limite representa?

O parâmetro:

```properties id="k2r9nb"
managementMessageAttributeSizeLimit
```

define o tamanho máximo dos atributos e conteúdos retornados pelas operações administrativas do broker.

O valor representa quantidade de caracteres/dados retornados no payload administrativo.

Exemplos:

```properties id="q6vf2c"
managementMessageAttributeSizeLimit=1024
```

→ Limita o retorno para aproximadamente 1024 caracteres/dados.

```properties id="v9xd5m"
managementMessageAttributeSizeLimit=8192
```

→ Permite payloads maiores.

```properties id="n5wb7r"
managementMessageAttributeSizeLimit=-1
```

→ Remove completamente o limite.

---

# Quando utilizar limite ao invés de ilimitado?

Em produção, normalmente é recomendado utilizar um valor controlado ao invés de `-1`, principalmente em ambientes com:

* alto volume;
* mensagens muito grandes;
* múltiplos acessos simultâneos ao console.

Exemplo mais controlado:

```properties id="t3hy8e"
addressSettings."activemq.management#".managementMessageAttributeSizeLimit=8192
```

Isso permite visualizar mensagens grandes sem deixar o retorno completamente ilimitado.

---

# Pontos de atenção

Configurar `-1` pode gerar:

* maior consumo de memória;
* aumento de tráfego entre console e broker;
* lentidão ao abrir mensagens muito grandes;
* maior uso de CPU no console;
* impacto operacional durante troubleshooting pesado.

---

# Documentação oficial Red Hat

A Red Hat documenta:

* configurações de `addressSettings`;
* uso do console administrativo;
* browse de mensagens;
* limites e paginação;
* configurações de gerenciamento do broker.

Referências oficiais:

* [Red Hat AMQ Broker 7.13 - Configuring AMQ Broker](https://docs.redhat.com/en/documentation/red_hat_amq_broker/7.13/html-single/configuring_amq_broker/index?utm_source=chatgpt.com)
* [Red Hat AMQ Broker - Working with Large Messages](https://docs.redhat.com/en/documentation/red_hat_amq/7.6/html/configuring_amq_broker/large_messages?utm_source=chatgpt.com)

Trechos relevantes:

* o console utiliza operações de management para browse de mensagens; ([Documentação Red Hat][1])
* o broker possui limites configuráveis para gerenciamento e memória; ([Documentação Red Hat][2])
* a Red Hat documenta limites baseados em bytes/tamanho de conteúdo em diversas propriedades administrativas do broker. ([Documentação Red Hat][2])

[1]: https://docs.redhat.com/en/documentation/red_hat_amq_broker/7.13/pdf/managing_amq_broker/Red_Hat_AMQ_Broker-7.13-Managing_AMQ_Broker-en-US.pdf?utm_source=chatgpt.com "Red Hat AMQ Broker 7.13 Managing ..."
[2]: https://docs.redhat.com/en/documentation/red_hat_amq_broker/7.10/pdf/configuring_amq_broker/Red_Hat_AMQ_Broker-7.10-Configuring_AMQ_Broker-en-US.pdf?utm_source=chatgpt.com "Configuring AMQ Broker"
