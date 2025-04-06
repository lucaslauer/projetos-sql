  CREATE OR REPLACE VIEW VW_CONSOLIDADO_CONTAS AS
  WITH SALDO_INVESTIMENTO AS (
    SELECT 
        FA.NRO_CONTA,
        SUM(FC.VALOR_COTA * FA.NRO_COTAS) AS SALDO_INVEST
    FROM FUNDOS_APLIC FA
    JOIN FUNDOS_COTA FC 
        ON FA.COD_FUNDO = FC.COD_FUNDO
        AND FC.DATA_COTA = (
            SELECT MAX(DATA_COTA) 
            FROM FUNDOS_COTA 
            WHERE COD_FUNDO = FA.COD_FUNDO
        )
    GROUP BY FA.NRO_CONTA
),
CALCULO AS (
    SELECT 
        A.COD_AGENCIA,
        A.NOME AS NOME_AGENCIA,
        C.NRO_CONTA,
        C.NOME,
        C.SALDO,
        
        COALESCE(C.SALDO, 0) + COALESCE(SI.SALDO_INVEST, 0) AS VLR_BRUTO,
        
        NVL((
            SELECT AI.ALIQUOTA 
            FROM ALIQUOTAS_IR AI
            JOIN FUNDOS_INV FI ON AI.TIPO_IR = FI.TIPO_IR
            JOIN FUNDOS_APLIC FA ON FI.COD_FUNDO = FA.COD_FUNDO
            WHERE FA.NRO_CONTA = C.NRO_CONTA
              AND (SYSDATE - FA.DATA_APLIC) BETWEEN AI.DIAS_DE AND AI.DIAS_ATE
            ORDER BY FA.DATA_APLIC DESC
            FETCH FIRST 1 ROW ONLY
        ), 0) AS ALIQUOTA_IR,

        ROUND(
            COALESCE(SI.SALDO_INVEST, 0) * (
                NVL((
                    SELECT AI.ALIQUOTA 
                    FROM ALIQUOTAS_IR AI
                    JOIN FUNDOS_INV FI ON AI.TIPO_IR = FI.TIPO_IR
                    JOIN FUNDOS_APLIC FA ON FI.COD_FUNDO = FA.COD_FUNDO
                    WHERE FA.NRO_CONTA = C.NRO_CONTA
                      AND (SYSDATE - FA.DATA_APLIC) BETWEEN AI.DIAS_DE AND AI.DIAS_ATE
                    ORDER BY FA.DATA_APLIC DESC
                    FETCH FIRST 1 ROW ONLY
                ), 0) / 100
            ), 2
        ) AS VALOR_IR,

        ROUND(
            (COALESCE(C.SALDO, 0) + COALESCE(SI.SALDO_INVEST, 0)) 
            - (
                COALESCE(SI.SALDO_INVEST, 0) * (
                    NVL((
                        SELECT AI.ALIQUOTA 
                        FROM ALIQUOTAS_IR AI
                        JOIN FUNDOS_INV FI ON AI.TIPO_IR = FI.TIPO_IR
                        JOIN FUNDOS_APLIC FA ON FI.COD_FUNDO = FA.COD_FUNDO
                        WHERE FA.NRO_CONTA = C.NRO_CONTA
                          AND (SYSDATE - FA.DATA_APLIC) BETWEEN AI.DIAS_DE AND AI.DIAS_ATE
                        ORDER BY FA.DATA_APLIC DESC
                        FETCH FIRST 1 ROW ONLY
                    ), 0) / 100
                )
            ), 2
        ) AS VALOR_LIQUIDO

    FROM AGENCIA A
    JOIN CONTA C
       ON A.COD_AGENCIA = C.COD_AGENCIA
    LEFT JOIN SALDO_INVESTIMENTO SI
       ON SI.NRO_CONTA = C.NRO_CONTA
)
SELECT 
    COD_AGENCIA, 
    NOME_AGENCIA, 
    NRO_CONTA, 
    NOME, 
    SALDO, 
    VLR_BRUTO, 
    VALOR_IR, 
    VALOR_LIQUIDO
FROM CALCULO
ORDER BY COD_AGENCIA, NRO_CONTA;