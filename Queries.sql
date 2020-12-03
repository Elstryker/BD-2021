USE BD_Zoologico;

-- ------------Requisitos de Exploração------------ --


-- ---------------------QUERY 1-----------------------
-- Consultar que animais um padrinho apadrinhou     --
-- ---------------------------------------------------

DELIMITER $$
CREATE PROCEDURE animaisApadrinhados 
	(IN idPadrinho INT)
BEGIN
	SELECT idAnimal AS IDAnimal, nome AS Nome
		FROM Animal
        WHERE Padrinho_idPadrinho = idPadrinho;
END $$

-- -----------------------------QUERY 2---------------------------------
-- Consultar qual o valor mensal total que cada padrinho deve pagar   --
-- ---------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE valorMensalAPagar
	()
BEGIN
	SELECT Padrinho_idPadrinho AS IDPadrinho, SUM(E.valor_de_apadrinhamento) AS ValorAPagar
		FROM Animal AS A INNER JOIN Especie AS E
			ON A.Especie_idEspecie=E.idEspecie
		WHERE Padrinho_idPadrinho IS NOT NULL
		GROUP BY Padrinho_idPadrinho;
END $$
    
-- --------------------QUERY 3---------------------------
-- Consultar as crias de um animal existentes no zoo   --
-- ------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE criasDeAnimal
	(IN idAnimal INT)
BEGIN
	SELECT Animal_idAnimalFilho AS IDCria
		FROM Animal_has_Animal
		WHERE Animal_idAnimalProgenitor=idAnimal;
END $$
-- -----------------------QUERY 4-------------------------
-- Determinar todos os descendentes de um animal no zoo --
-- -------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE descendentesAnimal
	(IN idAnimal INT)
BEGIN
	WITH RECURSIVE arvoreDescendente AS (
	SELECT Animal_idAnimalProgenitor AS IDProgenitor,Animal_idAnimalFilho AS IDCria, 1 AS Profundidade_Relativa
	FROM Animal_has_Animal
	WHERE Animal_idAnimalProgenitor = idAnimal

	UNION ALL

	SELECT pais.Animal_idAnimalProgenitor, pais.Animal_idAnimalFilho, aD.Profundidade_Relativa + 1
	FROM Animal_has_Animal pais, arvoreDescendente aD
	WHERE pais.Animal_idAnimalProgenitor = aD.IDCria
	)
	SELECT * FROM arvoreDescendente;
END $$

-- -------------------------QUERY 5---------------------------
-- Consultar os progenitores de um animal existentes no zoo --
-- -----------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE progenitoresDeAnimal
	(IN idAnimal INT)
BEGIN
SELECT Animal_idAnimalProgenitor AS IDCria
	FROM Animal_has_Animal
    WHERE Animal_idAnimalFilho=idAnimal;
END $$
    
-- ---------------------------QUERY 6----------------------------
-- Mostrar todos os ascendentes de um animal existentes no zoo --
-- --------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE ascendentesAnimal
	(IN idAnimal INT)
BEGIN
	WITH RECURSIVE arvoreAscendente AS (
	SELECT Animal_idAnimalFilho AS IDCria, Animal_idAnimalProgenitor AS IDProgenitor, -1 AS Profundidade_Relativa
	FROM Animal_has_Animal
	WHERE Animal_idAnimalFilho = idAnimal

	UNION ALL

	SELECT pais.Animal_idAnimalFilho, pais.Animal_idAnimalProgenitor, aA.Profundidade_Relativa - 1
	FROM Animal_has_Animal pais, arvoreAscendente aA
	WHERE pais.Animal_idAnimalFilho = aA.IDProgenitor
	)
	SELECT * FROM arvoreAscendente;
END $$

-- --------------------------QUERY 7------------------------------
-- Conhecer todas as espécies que um tipo de bilhete dá acesso  --
-- ---------------------------------------------------------------

SELECT E.nome_comum AS NomeComum, E.nome_cientifico AS NomeCientifico, Z.nome AS NomeZona
	FROM Tipo AS T 
    INNER JOIN Tipo_has_Zona AS TZ
		ON T.idTipo = TZ.Tipo_idTipo
        INNER JOIN Zona AS Z
			ON Z.idZona=TZ.Zona_idZona
            INNER JOIN Recinto AS R
				ON R.Zona_idZona=Z.idZona
                INNER JOIN Animal AS A
					ON A.Recinto_ID = R.ID 
					INNER JOIN Especie AS E
						ON E.idEspecie = A.Especie_idEspecie
	WHERE T.idTipo=4
    GROUP BY E.idEspecie;


-- ---------------------------------QUERY 8--------------------------------------
-- Consultar quantos animais, existem em cada bioma do jardim zoológico --
-- ------------------------------------------------------------------------------

CREATE VIEW vwNAnimaisBioma AS
	SELECT bioma AS Bioma, SUM(A.vivo) AS NAnimaisVivos ,SUM(CASE WHEN A.vivo=0 THEN 1 ELSE 0 END)AS NAnimaisMortos
		FROM Recinto as R INNER JOIN Animal AS A
		ON R.ID = A.Recinto_ID
		GROUP BY bioma;

-- --------------------QUERY 9------------------------
-- Calcular o TOP 3 tipo de bilhetes mais comprados --
-- ---------------------------------------------------
DELIMITER $$
CREATE PROCEDURE top3TiposBilheteMaisComprado
	()
BEGIN
SELECT T.nome AS TipoBilhete, COUNT(B.tipo_idTipo) AS NBilhetesVendidos
	FROM Bilhete as B
		INNER JOIN Tipo AS T
		ON B.Tipo_idTipo = T.idTipo
	GROUP BY B.tipo_idTipo
    ORDER BY COUNT(B.tipo_idTipo) DESC
    LIMIT 3;
END $$
    
-- ------------QUERY 13--------------------
-- Saber o crescimento de visitas anual  --
-- ----------------------------------------

DROP VIEW vwNBilhetesAno;
DROP VIEW vwNbilhetesAnos;

-- Numero de bilhetes por ano
CREATE VIEW vwNBilhetesAno AS
	SELECT YEAR(B.momento_aquisicao) AS Ano,COUNT(B.idBilhete) AS NumeroBilhetes
		FROM Bilhete as B
		GROUP BY YEAR(B.momento_aquisicao);

-- Usa view anterior para ter uma tabela com o ano, o n de bilhetes desse ano e o n de bilhetes do ano anterior
CREATE VIEW vwNbilhetesAnos AS        
	SELECT Atual.Ano AS Ano, Atual.NumeroBilhetes AS NumeroBilhetes, Anterior.NumeroBilhetes AS NumeroBilhetesAnterior
		FROM (SELECT * FROM vwNBilhetesAno) AS Atual
		INNER JOIN (SELECT * FROM vwNBilhetesAno) AS Anterior
		ON Atual.Ano= Anterior.Ano+1;

SELECT Ano, NumeroBilhetes, (NumeroBilhetes-NumeroBilhetesAnterior)*100/NumeroBilhetes AS CrescimentoPercentagem
	FROM vwNbilhetesAnos;








