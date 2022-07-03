
/*TABELAS DO BANCO*/
create table clientes (
codigo serial not null primary key,
nome varchar(50) not null check (length(nome) > 0),
endereco varchar(40) not null,
cidade varchar(30) not null,
estado char(2) not null,
cep int not null check (cep > 1000));

create table produtos (
codigo serial not null primary key,
descricao varchar(50) not null,
perecivel boolean not null default FALSE,
validade date default (current_date+15),
detalhes text,
foto bytea,
unique (descricao),
valor numeric (10,3),
check (validade > current_date),
check ((perecivel AND validade is not null) or (not perecivel AND validade is null)));

create table vendas (
codigo int not null,
cliente int not null,
primary key (codigo, cliente),
foreign key (cliente) references clientes (codigo));

create table produtos_venda (
venda int not null,
cliente int not null,
produto int not null,
quant int check (quant > 0),
primary key (venda, cliente, produto),
foreign key (venda, cliente) references vendas (codigo, cliente),
foreign key (produto) references produtos (codigo));



/*---->POPULANDO AS TABELAS COM INSERT
-->TABELA CLIENTE*/
INSERT INTO CLIENTES VALUES(1,'José Moura','308 SUL','Palmas','TO',7702168);
INSERT INTO CLIENTES VALUES(2,'Mario Carvalho','101 SUL','Colinas','TO',7702155);
INSERT INTO CLIENTES VALUES(3,'Simone Dutra','1005 SUL','Palmas','TO',7702199);
INSERT INTO CLIENTES VALUES(4,'Danilo Oliveira','601 SUL','Miranorte','TO',7702144);
INSERT INTO CLIENTES VALUES(5,'Matheus Silva','1500 SUL','Porto Nacional','TO',7702122);

-->TABELA PRODUTOS
--Produto perecivél
INSERT INTO PRODUTOS VALUES(1,'Carne',true, '2022-07-18','Costela',null,25.03);
INSERT INTO PRODUTOS VALUES(2,'Goiaba',true, '2022-07-22','Goiaba da terra',null,01.35);
--Produto não perecivél
INSERT INTO PRODUTOS VALUES(3,'Arroz',false, null,'Tio Hurbano',null,8.00);
INSERT INTO PRODUTOS VALUES(4,'Feijão',false, null,'Carioca tipo 1',null,12.00);

-->TABELA  VENDAS
INSERT INTO VENDAS VALUES(1,1);
INSERT INTO VENDAS VALUES(2,2);

-->TABELA PRODUTOS_VENDA
INSERT INTO PRODUTOS_VENDA VALUES(1,1,1,2);
INSERT INTO PRODUTOS_VENDA VALUES(2,2,3,5);



/*
1)Mostrar o nome do cliente, nome do produto, os valores totais do produto
agrupados por cliente pesquisados na tabela produtos_venda.*/

SELECT C.NOME, P.DESCRICAO, (P.VALOR*PV.QUANT) AS "TOTAL DA VENDA" FROM CLIENTES C
INNER JOIN VENDAS VE ON C.CODIGO=VE.CLIENTE
INNER JOIN PRODUTOS_VENDA PV ON VE.CODIGO=PV.VENDA AND VE.CLIENTE=PV.CLIENTE
INNER JOIN PRODUTOS P ON PV.PRODUTO=P.CODIGO WHERE PV.CLIENTE=2;

/*
2)Criar uma função para inserir um produto não perecível na tabela de produtos.
A função deverá receber a descrição do produto como parâmetro e retornar o código do
produto inserido.
*/

CREATE OR REPLACE FUNCTION inserirProdutoNaoPerecivel(des text) RETURNS INT AS
$$
DECLARE
	id int;
BEGIN
	INSERT INTO PRODUTOS(descricao,perecivel,validade,detalhes,foto,valor) VALUES(des,false,null,null,null,0.00) returning codigo into id;
	RETURN id;
END;
$$
LANGUAGE 'plpgsql';

SELECT inserirprodutonaoperecivel('macarrão');


/*
3)Criar uma função para inserir um produto perecível na tabela de produtos. A
função deverá receber a descrição do produto e a data de validade como parâmetros e
retornar o registro inserido.*/

CREATE OR REPLACE FUNCTION inserirProdutoPerecivel(des text, datav date) RETURNS SETOF produtos AS
$$
DECLARE
	registroinsert produtos%ROWTYPE;
BEGIN
	IF datav IS NOT null THEN
		INSERT INTO PRODUTOS(descricao,perecivel,validade,detalhes,foto,valor) VALUES(des,true,datav,null,null,25.03) returning codigo,descricao,perecivel,validade,detalhes,foto,valor into registroinsert;
		RETURN NEXT registroinsert;
	END IF;
END;
$$
LANGUAGE 'plpgsql';

SELECT * FROM produtos;
SELECT * from inserirprodutoperecivel('Tomate','2022-07-25');
SELECT * from inserirprodutoperecivel('Alface',null);


/*
4) Criar uma função para excluir todos os produtos que não estiverem presentes
em nenhuma venda, isto é, aqueles que não são usados na tabela produtos_venda.*/

CREATE OR REPLACE FUNCTION excluirProdutos() returns void as
$$
BEGIN
	DELETE FROM PRODUTOS WHERE CODIGO NOT IN (SELECT PRODUTO FROM PRODUTOS_VENDA);
END;
$$
LANGUAGE 'plpgsql';

SELECT excluirProdutos();
SELECT * FROM produtos;

/*
5)Criar uma trigger que ao ser alterada, ou deletado, na tabela produtos_venda
seja guardado em uma nova tabela qual operação foi realizada, os dados alterados, usuário e
hora.*/

--TABELA DE AUDITORIA
CREATE TABLE produtos_venda_audit (
operacao text not null,
dataop timestamp not null,
usuario varchar not null,
venda int not null,
cliente int not null,
produto int not null,
quant int check (quant > 0),
foreign key (venda, cliente) references vendas (codigo, cliente),
foreign key (produto) references produtos (codigo));

SELECT * FROM produtos_venda_audit;

CREATE OR REPLACE FUNCTION auditProdudoVenda() RETURNS TRIGGER AS
$$
BEGIN
	IF (TG_OP='DELETE') THEN
		INSERT INTO produtos_venda_audit SELECT 'DELETE',now(),user,old.*;
	ELSE
		INSERT INTO produtos_venda_audit SELECT 'UPDATE',now(),user,old.*;
	END IF;
	RETURN null;
END;
$$
language 'plpgsql';

CREATE OR REPLACE TRIGGER prod_audit AFTER UPDATE OR DELETE ON produtos_venda
FOR EACH ROW EXECUTE PROCEDURE auditProdudoVenda();

SELECT * FROM PRODUTOS_VENDA;
UPDATE PRODUTOS_VENDA SET quant=20 WHERE venda=2;
DELETE FROM PRODUTOS_VENDA WHERE venda=2;
--TABELAS DE AUDITORIA
SELECT * FROM produtos_venda_audit;

/*
6)Criar uma regra que ao ser alterada, ou deletado, na tabela venda não seja
realizado a operação solicitada, e guardar dados que seriam alterados, usuário e hora.*/

CREATE TABLE vendas_audit (
horadata timestamp not null,
usuario varchar not null,
operacao varchar not null,
codigo int not null,
cliente int not null,
foreign key (cliente) references clientes (codigo));

CREATE RULE vendaUpdate AS ON UPDATE TO vendas
            DO INSTEAD INSERT INTO vendas_audit
            VALUES (NOW(),CURRENT_USER,'UPDATE',NEW.codigo,new.cliente);
			
CREATE RULE vendaDelete AS ON DELETE TO vendas
            DO INSTEAD INSERT INTO vendas_audit
            VALUES (NOW(),CURRENT_USER,'DELETE',OLD.codigo,OLD.cliente);

SELECT * FROM vendas_audit;
DELETE FROM vendas WHERE cliente=1;





