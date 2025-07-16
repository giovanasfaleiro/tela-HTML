<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Previsão de Produção (AD_PREVPROD)</title>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/wansleynery/SankhyaJX@main/jx.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://unpkg.com/tabulator-tables@5.6.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet">
    <script type="text/javascript" src="https://unpkg.com/tabulator-tables@5.6.1/dist/js/tabulator.min.js"></script>

    <style>
        .tabulator-row { border-bottom: 1px solid #dee2e6 !important; }
        .tabulator-cell { border-right: 1px solid #dee2e6 !important; }
        .tabulator-row:last-child { border-bottom: none !important; }
        .tabulator-cell:last-of-type { border-right: none !important; }
    </style>
</head>
<body class="bg-slate-100 p-4 sm:p-6 md:p-8">

    <snk:query var="produtosIniciais">
        SELECT ITE.CODPROD
             , PRO.DESCRPROD 
             , SUM(ITE.QTDNEG) AS TOTAL
             , SUM(EST.ESTOQUE) AS ESTOQUE
             , SUM(ITE.QTDNEG)/5 AS SEG_FEIRA
             , SUM(ITE.QTDNEG)/5 AS TER_FEIRA
             , SUM(ITE.QTDNEG)/5 AS QUA_FEIRA
             , SUM(ITE.QTDNEG)/5 AS QUI_FEIRA
             , SUM(ITE.QTDNEG)/5 AS SEX_FEIRA
          FROM TGFCAB CAB
               INNER JOIN TGFITE ITE ON(ITE.NUNOTA = CAB.NUNOTA)
               INNER JOIN TGFPRO PRO ON(PRO.CODPROD = ITE.CODPROD)
               INNER JOIN TGFTOP TOP ON(TOP.CODTIPOPER = CAB.CODTIPOPER AND TOP.DHALTER = CAB.DHTIPOPER)
               LEFT  JOIN TGFEST EST ON(EST.CODPROD = ITE.CODPROD)
         WHERE TOP.ATUALEST = 'B'
           AND TOP.ATUALFIN = 1
           AND TOP.TIPMOV = 'V'
           AND ITE.CODPROD <> 101
           AND CAB.DTENTSAI BETWEEN 
               TRUNC(SYSDATE, 'IW') - 7
               AND 
               TRUNC(SYSDATE, 'IW') - 3
      GROUP BY ITE.CODPROD
             , PRO.DESCRPROD
      ORDER BY ITE.CODPROD, PRO.DESCRPROD
    </snk:query>

    <h1 class="text-3xl font-bold text-slate-800 text-center mb-8">Previsão de Produção</h1>

    <div class="bg-white p-6 rounded-xl shadow-lg">
        <div id="tabela-interativa"></div>
        <div class="mt-6 flex justify-end space-x-4">
            <button type="button" id="btnSalvarDadosSankhya" class="bg-blue-600 text-white font-semibold py-2 px-5 rounded-lg shadow-sm hover:bg-blue-700 transition-colors">Salvar Todas as Previsões</button>
        </div>
    </div>

    <script id="initial-data-source" type="application/json">
        [
            <c:forEach items="${produtosIniciais.rows}" var="row" varStatus="loop">
                {
                    "CODPROD": "${row.CODPROD}",
                    "DESCRPROD": "<c:out value='${row.DESCRPROD}' />",
                    "TOTAL": "${row.TOTAL}",
                    "ESTOQUE": "${row.ESTOQUE}",
                    "SEG_FEIRA": "${row.SEG_FEIRA}",
                    "TER_FEIRA": "${row.TER_FEIRA}",
                    "QUA_FEIRA": "${row.QUA_FEIRA}",
                    "QUI_FEIRA": "${row.QUI_FEIRA}",
                    "SEX_FEIRA": "${row.SEX_FEIRA}"
                }
                <c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ]
    </script>

    <snk:load>
        <script type="text/javascript">
            $(document).ready(function() {
                
                const dataString = document.getElementById('initial-data-source').textContent;
                const initialData = JSON.parse(dataString);
                
                const moneyParams = {decimal:",", thousand:".", precision:2};

                const columns = [
                    {title:"#", formatter:"rownum", hozAlign:"center", width:60},
                    {title: "Cód. Prod.", field: "CODPROD", width: 100},
                    {title: "Descrição", field: "DESCRPROD", width: 250},
                    {title: "Estoque", editor:"number", field: "ESTOQUE", width: 120, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Venda Semana Ant.", editor:"number", field: "TOTAL", width: 150, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Sug. Seg", editor:"number", field: "SEG_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Sug. Ter", editor:"number", field: "TER_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Sug. Qua", editor:"number", field: "QUA_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Sug. Qui", editor:"number", field: "QUI_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Sug. Sex", editor:"number", field: "SEX_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                ];
                
                const table = new Tabulator("#tabela-interativa", {
                    data: initialData,
                    columns: columns,
                    layout: "fitData",
                    height: "450px",
                    placeholder: "Nenhum produto encontrado."
                });

                function saveAllData() {
                    const dadosDaTabela = table.getData();
                    if (dadosDaTabela.length === 0) {
                        alert("Nenhuma previsão para salvar.");
                        return;
                    }

                    const btn = document.getElementById('btnSalvarDadosSankhya');
                    btn.disabled = true;
                    btn.textContent = 'Salvando...';

                    let successCount = 0;
                    let errorCount = 0;
                    let errorMessages = [];

                    // Função auxiliar recursiva que processa uma linha de cada vez.
                    function processarLinha(index) {
                        if (index >= dadosDaTabela.length) {
                            btn.disabled = false;
                            btn.textContent = 'Salvar Todas as Previsões';

                            let finalMessage = `Processamento concluído!\n${successCount} previsão(ões) salva(s) com sucesso.`;
                            if (errorCount > 0) {
                                finalMessage += `\n\n${errorCount} previsão(ões) com erro:\n` + errorMessages.join('\n');
                            }
                            alert(finalMessage);

                            if (errorCount === 0 && successCount > 0) {
                                window.location.reload();
                            }
                            return; // Encerra a execução.
                        }

                        const record = dadosDaTabela[index];
                        const recordToSave = {
                           NPROD: 10,
                            CODPROD: Number(record.CODPROD),
                            QTDVDASEMANAANT: record.TOTAL,       
                            SUGSEG: record.SEG_FEIRA,
                            SUGTER: record.TER_FEIRA,
                            SUGQUA: record.QUA_FEIRA,
                            SUGQUI: record.QUI_FEIRA,
                            SUGSEX: record.SEX_FEIRA
                        
                        };

                        JX.salvar(recordToSave, 'AD_PREVPROD')
                            .then(function(resultado) {
                                successCount++;
                                processarLinha(index + 1);
                            })
                            .catch(function(error) {
                                errorCount++;
                                let msg = (error && error.message) ? error.message : "Erro desconhecido";
                                if (error && error.serviceResponse && error.serviceResponse.responseBody && error.serviceResponse.responseBody.errorMessage) {
                                    msg = error.serviceResponse.responseBody.errorMessage;
                                }
                                errorMessages.push(`Produto ${record.CODPROD}: ${msg}`);
                                processarLinha(index + 1);
                            });
                    }

                    processarLinha(0);
                }

                $('#btnSalvarDadosSankhya').on('click', saveAllData);
            });
        </script>
    </snk:load>
</body>
</html>