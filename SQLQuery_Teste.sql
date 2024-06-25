SELECT *
FROM CONSUMO

SELECT *
FROM CONTEUDO

--CRIA��O DE TABELA PARA CONSULTA
SELECT CONSUMO.id_user
	,CONSUMO.id_conteudo
	,CONTEUDO.conteudo
	,CONTEUDO.categoria
	,CONSUMO.data
	,CONSUMO.horas_consumidas
INTO DADOS
FROM CONSUMO
FULL OUTER JOIN CONTEUDO ON CONSUMO.id_conteudo = CONTEUDO.id_conteudo
ORDER BY CONSUMO.data

SELECT *
FROM DADOS

--Quantidade de horas consumidas e plays por categoria
SELECT categoria
	,SUM(horas_consumidas) AS total_horas_consumidas
FROM DADOS
GROUP BY categoria;
--NOVELA = 3,70 horas
--SERIE = 7,27 horas

SELECT categoria
	,COUNT(*) AS quantidade_plays
FROM DADOS
GROUP BY categoria;
--NOVELA = 9 PLAYS
--SERIE = 13 PLAYS

--Ranking de novelas com mais horas consumidas por m�s.
SELECT conteudo
	,YEAR(data) AS ano
	,MONTH(data) AS mes
	,SUM(horas_consumidas) AS total_horas_consumidas
FROM DADOS
WHERE categoria = 'novela'
GROUP BY conteudo
	,YEAR(data)
	,MONTH(data)
ORDER BY ano
	,mes
	,total_horas_consumidas DESC;
--M�S 7
--CONTE�DO A = 1,13 horas
--CONTE�DO C = 1,01 horas
--M�S 10
--CONTE�DO A = 0,58 horas
--M�S 11
--CONTE�DO A = 0,97 horas

--Conte�do de primeiro play do usu�rio
WITH FirstPlays
AS (
	SELECT id_user
		,id_conteudo
		,conteudo
		,categoria
		,data
		,horas_consumidas
		,ROW_NUMBER() OVER (
			PARTITION BY id_user ORDER BY data
				,id_conteudo
			) AS rn
	FROM DADOS
	)
SELECT id_user
	,id_conteudo
	,conteudo
	,categoria
	,data
	,horas_consumidas
FROM FirstPlays
WHERE rn = 1;
--id_user 136 = C
--id_user 139 = B
--id_user 144 = A
--id_user 150 = A
--id_user 182 = C
--id_user 185 = D
--id_user 199 = A

--Minutos por play para cada usu�rio
SELECT id_user
	,AVG(horas_consumidas * 60) AS media_minutos_por_play
FROM DADOS
GROUP BY id_user;
--id_user 136 = 17,44 minutos
--id_user 139 = 25,29 minutos
--id_user 144 = 29,79 minutos
--id_user 150 = 20,10 minutos
--id_user 182 = 47,36 minutos
--id_user 185 = 33,10 minutos
--id_user 199 = 32,66 minutos

--Qual a categoria mais consumida para cada usu�rio
WITH CategoriaConsumo
AS (
	SELECT id_user
		,categoria
		,SUM(horas_consumidas) AS total_horas_consumidas
		,ROW_NUMBER() OVER (
			PARTITION BY id_user ORDER BY SUM(horas_consumidas) DESC
			) AS rn
	FROM DADOS
	GROUP BY id_user
		,categoria
	)
SELECT id_user
	,categoria
	,total_horas_consumidas
FROM CategoriaConsumo
WHERE rn = 1;
--id_user 136 = serie (0,80 horas)
--id_user 139 = serie (0,59 horas)
--id_user 144 = serie (1,71 horas)
--id_user 150 = serie (0,61 horas)
--id_user 182 = serie (1,55 horas)
--id_user 185 = serie (1,23 horas)
--id_user 199 = outra (1,24 horas) => foi considerada a categoria NULL como outra categoria n�o especificada na base de dados

