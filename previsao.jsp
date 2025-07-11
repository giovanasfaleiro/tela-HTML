<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Previsão de Produção</title>
    
    <!-- Tailwind CSS para estilização -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <style>
        body { font-family: sans-serif; background-color: #f1f5f9; }
        .table-input { width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; transition: all 0.2s; }
        .table-input:focus { outline: none; border-color: #4f46e5; box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.3); }
        .table-input[readonly] { background-color: #f8fafc; color: #64748b; cursor: not-allowed; }
        th, td { white-space: nowrap; }
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

    <div class="max-w-full mx-auto">
        <header class="mb-8">
            <h1 class="text-3xl font-bold text-gray-800">Previsão de Produção</h1>
            <p class="text-gray-600 mt-1">Visualize os produtos e preencha os dados para a previsão.</p>
        </header>

        <div class="bg-white p-6 rounded-xl shadow-md">
            <div class="overflow-x-auto mt-4">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cód. Prod.</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Descrição</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nº Prod.</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Qtd. a Produzir</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Lote</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estoque</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Média Venda 3M</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Média Últ. Semana</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Sugestão</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Unid.</th>
                            <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nº OP</th>
                        </tr>
                    </thead>
                    <tbody id="editableTableBody" class="bg-white divide-y divide-gray-200">
                        
                        <!-- CORREÇÃO APLICADA: As linhas da tabela são geradas diretamente pelo JSP -->
                        <c:forEach items="${produtosIniciais.rows}" var="row">
                            <tr class="hover:bg-gray-50">
                                <td class="px-3 py-4"><input type="text" name="codprod" class="table-input" value="<c:out value='${row.CODPROD}' />" readonly></td>
                                <td class="px-3 py-4"><input type="text" name="descrprod" class="table-input" value="<c:out value='${row.DESCRPROD}' />" readonly></td>
                                <td class="px-3 py-4"><input type="number" name="nprod" class="table-input" placeholder="Nº Prod."></td>
                                <td class="px-3 py-4"><input type="number" name="qtd" class="table-input" placeholder="Qtd."></td>
                                <td class="px-3 py-4"><input type="text" name="lote" class="table-input" placeholder="Lote"></td>
                                <td class="px-3 py-4"><input type="number" name="estoque" class="table-input" placeholder="Estoque"></td>
                                <td class="px-3 py-4"><input type="number" name="medvda3m" class="table-input" placeholder="Média 3M"></td>
                                <td class="px-3 py-4"><input type="number" name="ultmed" class="table-input" placeholder="Média Sem."></td>
                                <td class="px-3 py-4"><input type="number" name="sugestao" class="table-input" placeholder="Sugestão"></td>
                                <td class="px-3 py-4"><input type="text" name="codvol" class="table-input" placeholder="Unid."></td>
                                <td class="px-3 py-4"><input type="number" name="idiproc" class="table-input" placeholder="Nº OP"></td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Mensagem exibida se a query não retornar nenhum produto -->
                        <c:if test="${produtosIniciais.rowCount == 0}">
                            <tr>
                                <td colspan="11" class="text-center py-4">Nenhum produto encontrado.</td>
                            </tr>
                        </c:if>

                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- O bloco de script foi removido, pois não é mais necessário para exibir os dados -->

</body>
</html>
