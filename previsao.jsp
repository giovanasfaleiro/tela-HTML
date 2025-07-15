<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Previsão de Produção</title>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Biblioteca SankhyaJX-->
    <script src="https://cdn.jsdelivr.net/gh/wansleynery/SankhyaJX@main/jx.min.js"></script>
    
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f4f7f6; color: #333; }
        h1 { color: #2c3e50; text-align: center; margin-bottom: 30px; }
        .form-container { background-color: #fff; padding: 25px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); overflow-x: auto; }
        table { width: 100%; min-width: 1200px; border-collapse: collapse; margin-bottom: 20px; }
        th, td { border: 1px solid #dfe6e9; padding: 10px 12px; text-align: left; vertical-align: middle; white-space: nowrap; }
        th { background-color: #3498db; color: white; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; font-size: 0.9em; }
        td input[type="text"], td input[type="number"] { width: calc(100% - 16px); padding: 8px; border: 1px solid #b2bec3; border-radius: 4px; box-sizing: border-box; font-size: 0.95em; }
        td input[readonly] { background-color: #f0f0f0; cursor: not-allowed; }
        button { padding: 10px 18px; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; margin-right: 8px; }
        button.adicionar { background-color: #2ecc71; }
        button.remover { background-color: #e74c3c; padding: 6px 10px; font-size: 14px; }
        button#btnSalvarDadosSankhya { background-color: #3498db; }
        .acoes { text-align: center; min-width: 80px; }
        .form-actions { text-align: right; margin-top: 20px; }
    </style>
</head>
<body class="p-4 sm:p-6 md:p-8">

    <!-- Query para buscar os produtos iniciais -->
    <snk:query var="produtosIniciais">
        SELECT CODPROD, DESCRPROD 
        FROM TGFPRO 
        WHERE ROWNUM <= 3 AND ATIVO = 'S' 
        ORDER BY CODPROD
    </snk:query>

    <h1>Lançamento de Previsão de Produção (AD_PREVPROD)</h1>

    <div class="form-container">
        <table id="tabelaPrevisao">
            <thead>
                <tr>
                    <th>Produto (Cód.)</th>
                    <th>Descrição</th>
                    <th>Nro. Produção</th>
                    <th>Qtd. a Produzir</th>
                    <th>Lote</th>
                    <th>Nro. OP</th>
                    <th>Média Venda 3M</th>
                    <th>Média Últ. Semana</th>
                    <th>Saldo Estoque</th>
                    <th>Sugestão</th>
                    <th>Unidade</th>
                    <th class="acoes">Ação</th>
                </tr>
            </thead>
            <tbody id="editableTableBody">
                <!-- Linhas iniciais são geradas pelo JSP -->
                <c:forEach items="${produtosIniciais.rows}" var="row">
                    <tr>
                        <td><input type="number" name="CODPROD" value="<c:out value='${row.CODPROD}' />" readonly></td>
                        <td><input type="text" name="DESCRPROD" value="<c:out value='${row.DESCRPROD}' />" readonly></td>
                        <td><input type="number" name="NPROD" placeholder="Nro. Prod."></td>
                        <td><input type="number" step="any" name="QTD" placeholder="Quantidade"></td>
                        <td><input type="text" name="LOTE" placeholder="Lote"></td>
                        <td><input type="number" name="IDIPROC" placeholder="Nro. OP"></td>
                        <td><input type="number" step="any" name="MEDVDA3M" placeholder="Média"></td>
                        <td><input type="number" step="any" name="ULTMED" placeholder="Média"></td>
                        <td><input type="number" step="any" name="ESTOQUE" placeholder="Estoque"></td>
                        <td><input type="number" step="any" name="SUGESTAO" placeholder="Sugestão"></td>
                        <td><input type="text" name="CODVOL" placeholder="Unidade"></td>
                        <td class="acoes"><button type="button" class="remover" onclick="removerLinhaIndividual(this)">Remover</button></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div class="form-actions">
            <button type="button" class="adicionar" onclick="adicionarLinha()">Adicionar Linha</button>
            <button type="button" id="btnSalvarDadosSankhya">Salvar Dados</button>
        </div>
    </div>

    <snk:load>
        <script type="text/javascript">
            function adicionarLinha() {
                const tabelaBody = document.getElementById('tabelaPrevisao').getElementsByTagName('tbody')[0];
                const novaLinha = tabelaBody.insertRow();
                novaLinha.innerHTML = `
                    <td><input type="number" name="CODPROD" placeholder="Cód. Prod."></td>
                    <td><input type="text" name="DESCRPROD" placeholder="Descrição (opcional)"></td>
                    <td><input type="number" name="NPROD" placeholder="Nro. Prod."></td>
                    <td><input type="number" step="any" name="QTD" placeholder="Quantidade"></td>
                    <td><input type="text" name="LOTE" placeholder="Lote"></td>
                    <td><input type="number" name="IDIPROC" placeholder="Nro. OP"></td>
                    <td><input type="number" step="any" name="MEDVDA3M" placeholder="Média"></td>
                    <td><input type="number" step="any" name="ULTMED" placeholder="Média"></td>
                    <td><input type="number" step="any" name="ESTOQUE" placeholder="Estoque"></td>
                    <td><input type="number" step="any" name="SUGESTAO" placeholder="Sugestão"></td>
                    <td><input type="text" name="CODVOL" placeholder="Unidade"></td>
                    <td class="acoes"><button type="button" class="remover" onclick="removerLinhaIndividual(this)">Remover</button></td>
                `;
            }

            function removerLinhaIndividual(botao) {
                const linha = botao.closest('tr');
                linha.parentNode.removeChild(linha);
            }

            // Função para coletar os dados da linha e montar o objeto para salvar
            function buildRecord(row) {
                const record = {};
                const inputs = row.querySelectorAll('input[name]');

                inputs.forEach(input => {
                    const name = input.getAttribute('name').toUpperCase();
                    const value = input.value;

                    // Ignora o campo de descrição, que é apenas para visualização
                    if (name === 'DESCRPROD') {
                        return;
                    }

                    if (value) { // Apenas adiciona se houver valor
                        if (input.type === 'number') {
                            record[name] = parseFloat(value);
                        } else {
                            record[name] = value;
                        }
                    }
                });
                return record;
            }

            // Função principal para salvar os dados
            async function saveAllData() {
                const rows = document.querySelectorAll('#editableTableBody tr');
                let successCount = 0;
                let errorCount = 0;
                
                const btn = $('#btnSalvarDadosSankhya');
                btn.prop('disabled', true).text('Salvando...');

                for (const row of rows) {
                    const record = buildRecord(row);

                    // Pula a linha se não tiver os campos essenciais (CODPROD e QTD)
                    if (!record.CODPROD || !record.QTD) {
                        continue;
                    }
                    
                    try {
                        
                        await JX.salvar(record, 'AD_PREVPROD');
                        successCount++;
                    } catch (error) {
                        errorCount++;
                        console.error("Erro ao salvar a linha com CODPROD " + record.CODPROD, error);
                    }
                }

                btn.prop('disabled', false).text('Salvar Dados');
                alert(`Processamento concluído!\n${successCount} linha(s) salva(s) com sucesso.\n${errorCount} linha(s) com erro.`);

                if (errorCount === 0 && successCount > 0) {
                    window.location.reload();
                }
            }
            
            // Espera o documento carregar para adicionar o evento de clique
            $(document).ready(function() {
                $('#btnSalvarDadosSankhya').on('click', function() {
                    saveAllData();
                });
            });

        </script>
    </snk:load>

</body>
</html>
