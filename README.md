# projetos-sql

## #1 View - A partir de informações bancárias fornecidas previamente
View consolidando as informações bancárias (requisitadas) relacionadas às contas.

Criar uma view consolidando as informações bancárias relacionadas às contas. A view deve retornar:

- Código e nome da agência
- Número da conta
- Nome do correntista
- Saldo na conta corrente
- SALDO ATUALIZADO (TOTAL) em fundos de investimento (considerar o valor de cota da data mais recente)
- VALOR_IR – Para calcular o valor do IR, deve-se considerar a coluna TIPO_IR da tabela Aplicação e o número de dias da Data Atual (SYSDATE) em relação à Data da Aplicação. Com estas duas informações, deve-se verificar a Aliquota de IR na tabela ALIQUOTAS_IR.
- VALOR LÍQUIDO (resultado da subtração das duas colunas anteriores: SALDO_ATUALIZADO – VALOR_IR).
