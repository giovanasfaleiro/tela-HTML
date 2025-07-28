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

        #loading-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(16, 185, 129, 0.1);
            display: none; justify-content: center; align-items: center;
            z-index: 9999; backdrop-filter: blur(4px); 
        }
        .overlay-content { text-align: center; color: #065f46;  }
        .spinner {
            border: 6px solid #d1fae5; border-top: 6px solid #065f46; 
            border-radius: 50%; width: 60px; height: 60px;
            animation: spin 1s linear infinite; margin: 0 auto;
        }
        #loading-message { font-size: 1.2em; font-weight: 500; margin-top: 20px; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
</head>
<body class="bg-slate-100 p-4 sm:p-6 md:p-8">

    <div id="loading-overlay">
        <div class="overlay-content">
            <div class="spinner"></div>
            <p id="loading-message">Salvando dados na tabela</p>
        </div>
    </div>
    
    <snk:query var="produtosIniciais">
        SELECT ITE.CODPROD, PRO.DESCRPROD, SUM(ITE.QTDNEG) AS TOTAL, SUM(EST.ESTOQUE) AS ESTOQUE, SUM(ITE.QTDNEG)/5 AS SEG_FEIRA, SUM(ITE.QTDNEG)/5 AS TER_FEIRA, SUM(ITE.QTDNEG)/5 AS QUA_FEIRA, SUM(ITE.QTDNEG)/5 AS QUI_FEIRA, SUM(ITE.QTDNEG)/5 AS SEX_FEIRA
        FROM TGFCAB CAB
        INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
        INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
        INNER JOIN TGFTOP TOP ON TOP.CODTIPOPER = CAB.CODTIPOPER AND TOP.DHALTER = CAB.DHTIPOPER
        LEFT JOIN TGFEST EST ON EST.CODPROD = ITE.CODPROD
        WHERE TOP.ATUALEST = 'B' AND TOP.ATUALFIN = 1 AND TOP.TIPMOV = 'V' AND ITE.CODPROD <> 101
        AND CAB.DTENTSAI BETWEEN TRUNC(SYSDATE, 'IW') - 7 AND TRUNC(SYSDATE, 'IW') - 3
        GROUP BY ITE.CODPROD, PRO.DESCRPROD
        ORDER BY ITE.CODPROD, PRO.DESCRPROD
    </snk:query>

    <h1 class="text-3xl font-bold text-slate-800 text-center mb-8">Previsão de Produção</h1>

    <div class="bg-white p-6 rounded-xl shadow-lg mb-6">
        <h2 class="text-2xl font-bold text-slate-700 mb-4">Controle de Matéria-Prima (Leite)</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
                <label for="estoqueInicialSemana" class="block text-sm font-medium text-gray-700">Estoque Inicial da Semana (Litros)</label>
                <input type="number" id="estoqueInicialSemana" value="50000" class="mt-1 block w-full p-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500">
            </div>
        </div>
        <div>
            <h3 class="text-lg font-semibold text-slate-600 mb-2">Balanço Diário de Leite (Litros)</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-4">
                <div class="bg-slate-100 p-3 rounded-lg space-y-1">
                    <p class="text-sm font-bold text-gray-500 text-center">Segunda</p>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Disponível:</span> <span id="leiteDispSeg" class="font-semibold">0,00</span></div>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Necessário:</span> <span id="leiteNecSeg" class="font-semibold">0,00</span></div>
                </div>
                <div class="bg-slate-100 p-3 rounded-lg space-y-1">
                    <p class="text-sm font-bold text-gray-500 text-center">Terça</p>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Disponível:</span> <span id="leiteDispTer" class="font-semibold">0,00</span></div>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Necessário:</span> <span id="leiteNecTer" class="font-semibold">0,00</span></div>
                </div>
                <div class="bg-slate-100 p-3 rounded-lg space-y-1">
                    <p class="text-sm font-bold text-gray-500 text-center">Quarta</p>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Disponível:</span> <span id="leiteDispQua" class="font-semibold">0,00</span></div>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Necessário:</span> <span id="leiteNecQua" class="font-semibold">0,00</span></div>
                </div>
                <div class="bg-slate-100 p-3 rounded-lg space-y-1">
                    <p class="text-sm font-bold text-gray-500 text-center">Quinta</p>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Disponível:</span> <span id="leiteDispQui" class="font-semibold">0,00</span></div>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Necessário:</span> <span id="leiteNecQui" class="font-semibold">0,00</span></div>
                </div>
                <div class="bg-slate-100 p-3 rounded-lg space-y-1">
                    <p class="text-sm font-bold text-gray-500 text-center">Sexta</p>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Disponível:</span> <span id="leiteDispSex" class="font-semibold">0,00</span></div>
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Necessário:</span> <span id="leiteNecSex" class="font-semibold">0,00</span></div>
                </div>
            </div>
        </div>
    </div>
    <div class="bg-white p-6 rounded-xl shadow-lg">
        <div id="tabela-interativa"></div>
        <div class="mt-6 flex justify-end space-x-4">
            <button type="button" id="btnSalvarDadosSankhya" class="bg-blue-600 text-white font-semibold py-2 px-5 rounded-lg shadow-sm hover:bg-blue-700 transition-colors">Salvar Todas as Previsões</button>
        </div>
    </div>

    <script id="initial-data-source" type="application/json">
        [
            <c:forEach items="${produtosIniciais.rows}" var="row" varStatus="loop">
                { "CODPROD": "${row.CODPROD}", "DESCRPROD": "<c:out value='${row.DESCRPROD}' />", "TOTAL": "${row.TOTAL}", "ESTOQUE": "${row.ESTOQUE}", "SEG_FEIRA": "${row.SEG_FEIRA}", "TER_FEIRA": "${row.TER_FEIRA}", "QUA_FEIRA": "${row.QUA_FEIRA}", "QUI_FEIRA": "${row.QUI_FEIRA}", "SEX_FEIRA": "${row.SEX_FEIRA}" }
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
                let table;

                // LÓGICA DE CÁLCULO DO BALANÇO DE LEITE (SIMPLIFICADA)
                function recalcularEstoqueLeite() {
                    if (!table) return;

                    const produtos = table.getData();
                    const estoqueInicial = parseFloat($('#estoqueInicialSemana').val()) || 0;
                    const moneyFormatter = (value) => (value || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                    
                    let estoqueDisponivelHoje = estoqueInicial; // Começa com o estoque da semana
                    
                    const dias = [
                        { field: "SEG_FEIRA", dispId: "#leiteDispSeg", necId: "#leiteNecSeg" },
                        { field: "TER_FEIRA", dispId: "#leiteDispTer", necId: "#leiteNecTer" },
                        { field: "QUA_FEIRA", dispId: "#leiteDispQua", necId: "#leiteNecQua" },
                        { field: "QUI_FEIRA", dispId: "#leiteDispQui", necId: "#leiteNecQui" },
                        { field: "SEX_FEIRA", dispId: "#leiteDispSex", necId: "#leiteNecSex" }
                    ];

                    dias.forEach((dia) => {
                        // Opcional: Quando tiver a chegada diária, ela será somada aqui.
                        // let chegadaDoDia = ...; (virá da query futura)
                        // estoqueDisponivelHoje += chegadaDoDia;
                        
                        $(dia.dispId).text(moneyFormatter(estoqueDisponivelHoje));

                        let consumoDoDia = 0;
                        produtos.forEach(p => {
                            const producao = parseFloat(p[dia.field]) || 0;
                            const proporcao = parseFloat(p.LEITE_POR_UNIDADE) || 0;
                            consumoDoDia += producao * proporcao;
                        });

                        $(dia.necId).text(moneyFormatter(consumoDoDia));
                        
                        const cor = consumoDoDia > estoqueDisponivelHoje ? '#dc2626' : '#1e293b';
                        $(dia.necId).css('color', cor);
                        
                        const saldoFinalDoDia = estoqueDisponivelHoje - consumoDoDia;

                        // O estoque para o próximo dia é a sobra do dia anterior (se for positiva).
                        estoqueDisponivelHoje = Math.max(0, saldoFinalDoDia);
                    });
                }

                const columns = [
                    {title:"#", formatter:"rownum", hozAlign:"center", width:60},
                    {title: "Cód. Prod.", field: "CODPROD", width: 100},
                    {title: "Descrição", field: "DESCRPROD", width: 250},
                    {title: "Leite/Unid. (L)", field: "LEITE_POR_UNIDADE", width: 130, hozAlign:"center", editor:"number", editorParams:{step:0.01, min:0}, formatter:"money", formatterParams: moneyParams, cellEdited: recalcularEstoqueLeite},
                    {title: "Estoque", editor:"number", field: "ESTOQUE", width: 120, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Venda Semana Ant.", editor:"number", field: "TOTAL", width: 150, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}},
                    {title: "Sug. Seg", editor:"number", field: "SEG_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}, cellEdited: recalcularEstoqueLeite},
                    {title: "Sug. Ter", editor:"number", field: "TER_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}, cellEdited: recalcularEstoqueLeite},
                    {title: "Sug. Qua", editor:"number", field: "QUA_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}, cellEdited: recalcularEstoqueLeite},
                    {title: "Sug. Qui", editor:"number", field: "QUI_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}, cellEdited: recalcularEstoqueLeite},
                    {title: "Sug. Sex", editor:"number", field: "SEX_FEIRA", width: 110, hozAlign:"center", formatter:"money", formatterParams: moneyParams, editorParams:{step:0.01}, cellEdited: recalcularEstoqueLeite},
                ];
                
                table = new Tabulator("#tabela-interativa", { 
                    data: initialData, 
                    columns: columns, 
                    layout: "fitData", 
                    height: "450px", 
                    placeholder: "Nenhum produto encontrado.",
                    tableBuilt: function(){
                        recalcularEstoqueLeite();
                    }
                });
                
                $('#estoqueInicialSemana').on('change keyup', recalcularEstoqueLeite);

                function saveAllData() {
                    const dadosDaTabela = table.getData();
                    if (dadosDaTabela.length === 0) { alert("Nenhuma previsão para salvar."); return; }

                    const btn = document.getElementById('btnSalvarDadosSankhya');
                    const overlay = document.getElementById('loading-overlay');
                    const loadingMessage = document.getElementById('loading-message');
                    
                    btn.disabled = true;
                    overlay.style.display = 'flex'; 
                    let successCount = 0;
                    let errorCount = 0;
                    let errorMessages = [];

                    function processarLinha(index) {
                        if (index >= dadosDaTabela.length) {
                            overlay.style.display = 'none';
                            btn.disabled = false;
                            btn.textContent = 'Salvar Todas as Previsões';
                            
                            let finalMessage = `Processamento concluído!\n${successCount} previsão(ões) salva(s) com sucesso.`;
                            if (errorCount > 0) { finalMessage += `\n\n${errorCount} previsão(ões) com erro:\n` + errorMessages.join('\n'); }
                            alert(finalMessage);
                            
                            if (errorCount === 0 && successCount > 0) { window.location.reload(); }
                            return;
                        }
                        
                        loadingMessage.textContent = `Salvando dados na tabela`;
                        const record = dadosDaTabela[index];
                        const recordToSave = {
                            NPROD: 4,
                            CODPROD: Number(record.CODPROD),
                            CODVOL:  record.CODVOL || 0,
                            QTD:  record.QTD || 0,
                            LOTE:  record.LOTE || 0,
                            IDIPROC:  record.IDIPROC || 0,
                            MEDVDA3M:  record.MEDVDA3M || 0,
                            ULTMED: record.ULTMED || 0,
                            SUGESTAO: record.SUGESTAO || 0,
                            ESTOQUE: record.ESTOQUE || 0,
                            QTDVDASEMANAANT: record.TOTAL || 0,
                            SUGSEG: record.SEG_FEIRA || 0,
                            SUGTER: record.TER_FEIRA || 0,
                            SUGQUA: record.QUA_FEIRA || 0,
                            SUGQUI: record.QUI_FEIRA || 0,
                            SUGSEX: record.SEX_FEIRA || 0
                        };

                        JX.salvar(recordToSave, 'AD_PREVPROD')
                            .then(function(resultado) {
                                successCount++;
                                processarLinha(index + 1);
                            })
                            .catch(function(error) {
                                errorCount++;
                                let msg = (error && error.message) ? error.message : "Erro desconhecido";
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