Fala pessoal, tudo joia?!

Aqui está algumas questões resolvidas usando a linguagem SQL no SGBD PostgreSQL.
Nessa ativiade foram colocados em prática conhecimentos sobre Stored procedure, Trigger e 
Rules. Essa avaliação foi proposta pela professora da disciplina Programação para Banco de Dados.

Segue as questões:

 1) - Mostrar o nome do cliente, nome do produto, os valores totais do produto
agrupados por cliente pesquisados na tabela produtos_venda.

 2) - Criar uma função para inserir um produto não perecível na tabela de produtos.
A função deverá receber a descrição do produto como parâmetro e retornar o código do
produto inserido.

 3) - Criar uma função para inserir um produto perecível na tabela de produtos. A
função deverá receber a descrição do produto e a data de validade como parâmetros e
retornar o registro inserido.

 4) - Criar uma função para excluir todos os produtos que não estiverem presentes
em nenhuma venda, isto é, aqueles que não são usados na tabela produtos_venda.

 5) - Criar uma trigger que ao ser alterada, ou deletado, na tabela produtos_venda
seja guardado em uma nova tabela qual operação foi realizada, os dados alterados, usuário e
hora.

 6) - Criar uma regra que ao ser alterada, ou deletado, na tabela venda não seja
realizado a operação solicitada, e guardar dados que seriam alterados, usuário e hora.


OBS: A professora disponiblizou uma Database com as tabelas necessárias, ficando 
para estudante fazer as inserções e as questões.

Confira todo desenvolvimento da atividade no arquivo "AtividadePBD.sql"

