--VISÃO OPERAÇÃO (Validação)

-- Quantidade de reservas por status
SELECT 
	COUNT(r.id_reserva),
	r.status 
FROM reservas r
GROUP BY r.status;

-- Percentual de cancelamento
WITH cancelamento AS 
(
	SELECT
		COUNT(r.id_reserva) AS qtd_canceladas
	FROM reservas r
	WHERE UPPER(r.status) = 'CANCELADA'
)
SELECT 
	ROUND(
			100.0*(SELECT qtd_canceladas FROM cancelamento) / COUNT(r.id_reserva)
			, 1) AS percentual_cancelamentos
FROM reservas r;

-- Quantidade de ofertas concluídas por tipo
SELECT
	COUNT(r.id_reserva),
	o.tipo_oferta
FROM reservas r
	LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta
WHERE UPPER(r.status) = 'CONCLUÍDA'
GROUP BY o.tipo_oferta;

-- Quantidade de reservas concluídas com avaliação
SELECT
	COUNT(DISTINCT r.id_reserva)
FROM reservas r
	LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta 
	LEFT JOIN avaliacoes a ON a.id_oferta = o.id_oferta
WHERE a.id_avaliacao IS NOT NULL AND UPPER(r.status) = 'CONCLUÍDA';

-- Receita total das reservas concluídas
SELECT
	SUM(r.qtd_pessoas * o.preco) AS receita
FROM reservas r
	LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta
WHERE UPPER(r.status) = 'CONCLUÍDA'

-- Receita das reservas concluídas por mês/ano
SELECT
		EXTRACT (YEAR FROM r.data_reserva) AS ano,
		EXTRACT (MONTH FROM r.data_reserva) AS mes, -- Atua no "background" para ordenar os dados
		TO_CHAR(r.data_reserva , 'Month') AS nome_mes, -- Para exibir o nome do mês em vez do número
		SUM(r.qtd_pessoas * o.preco) AS receita
	FROM reservas r
		LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta
	WHERE UPPER(r.status) = 'CONCLUÍDA' -- Para garantir consistência dos dados
	GROUP BY ano, mes, nome_mes
	ORDER BY ano, mes;

-- Variação mensal das receita das reservas concluídas
WITH receita_periodo AS 
-- Calcula a receita agrupada por período
(
	SELECT
		EXTRACT (YEAR FROM r.data_reserva) AS ano,
		EXTRACT (MONTH FROM r.data_reserva) AS mes, -- Atua no "background" para ordenar os dados
		TO_CHAR(r.data_reserva , 'Month') AS nome_mes, -- Para exibir o nome do mês em vez do número
		SUM(r.qtd_pessoas * o.preco) AS receita
	FROM reservas r
		LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta
	WHERE UPPER(r.status) = 'CONCLUÍDA' -- Para garantir consistência dos dados
	GROUP BY ano, mes, nome_mes
	ORDER BY ano, mes
)
-- Calcula a diferença percentual
SELECT
	ano,
	nome_mes,
	receita,
	ROUND(
			(receita - LAG(receita) OVER(ORDER BY ano, mes))*100 / NULLIF(LAG(receita) OVER(ORDER BY ano, mes), 0) -- 100*(Mês atual - Mês anterior)/Mês anterior
			, 2
		  ) AS diferenca_percentual
FROM receita_periodo;

-- Gasto médio por pessoa
WITH media_gastos_pessoas AS 
-- Calcula  média de gastos por pessoa
(
	SELECT
		ROUND(
			SUM(r.qtd_pessoas * o.preco) / SUM(r.qtd_pessoas )
			, 2
			  ) AS media_pessoa
	FROM reservas r
		LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta
	WHERE UPPER(r.status) = 'CONCLUÍDA'
)
SELECT
	media_pessoa,
	(SELECT
		ROUND(AVG(o.preco), 2) AS media_ofertas -- Calcula a média de preço por oferta
	FROM ofertas o),
	(SELECT
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY o.preco) as mediana_ofertas -- Calcula a mediana de preço por oferta
	FROM ofertas o)
FROM media_gastos_pessoas;

-- Nota média de avaliação das reservas concluídas
WITH avaliacoes_unicas AS
(
	SELECT
		DISTINCT a.id_avaliacao,
		a.nota
	FROM ofertas o -- Considera ofertas que não têm reservas ou avaliações
		LEFT JOIN reservas r ON o.id_oferta = r.id_oferta 
		LEFT JOIN avaliacoes a ON a.id_oferta = o.id_oferta
WHERE UPPER(r.status) = 'CONCLUÍDA'
)
SELECT	
	ROUND(AVG(nota), 2)
FROM avaliacoes_unicas;

-- VISÃO CLIENTES (Validação)

-- Total de clientes únicos que fizeram reservas
SELECT
	COUNT(DISTINCT r.id_cliente)
FROM clientes c
	LEFT JOIN reservas r ON r.id_cliente = c.id_cliente;
	
-- Percentual de repetição de clientes
WITH qtde_reservas_cliente AS
-- Calcula a quantidade de reservas por cliente
(
	SELECT
		r.id_cliente,
		COUNT(r.id_reserva) AS qtd_reservas
	FROM reservas r
	WHERE UPPER(r.status) = 'CONCLUÍDA'
	GROUP BY r.id_cliente
)
-- Calcula a quantidade de clientes únicos que fizeram mais de uma reserva (subquery) dividido pela quantidade total de clientes únicos.
SELECT
	ROUND(
			(
			SELECT 
				COUNT(id_cliente) 
			FROM qtde_reservas_cliente 
			WHERE qtd_reservas > 1 -- Essa subquery conta os clientes que fizeram mais de uma reserva concluída
			) * 100.0/ COUNT(id_cliente) -- Divisão pelo total de clientes que fizeram reservas concluídas
			, 2
	      ) AS percentual_repeticao
FROM qtde_reservas_cliente;


-- Tempo médio entre as reservas de clientes recorrentes
WITH lag_reserva AS 
-- Exibe a data da reserva e a data da reserva anterior para cada cliente 
(
	SELECT 
			r.id_cliente,
			r.data_reserva,
			LAG(r.data_reserva) OVER(PARTITION BY r.id_cliente ORDER BY r.data_reserva) AS data_reserva_anterior
		FROM reservas r
		WHERE UPPER(r.status) = 'CONCLUÍDA'
			AND r.id_cliente IN (
									SELECT
										r2.id_cliente
									FROM reservas r2
									WHERE UPPER(r2.status) = 'CONCLUÍDA'
									GROUP BY r2.id_cliente
									HAVING COUNT(r2.id_cliente) > 1
								) -- Essa subquery filtra apenas os clientes que tiveram mais de uma reserva
)
-- Calcula a média da diferença de dias entre as reservas dos clientes
SELECT
	ROUND(
		AVG(data_reserva - data_reserva_anterior)
		, 2) AS media_dias,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY data_reserva - data_reserva_anterior) as mediana_dias
FROM lag_reserva;

-- VISÃO OPERADORES (Validação)

-- Receita e quantidade de reservas por operador
SELECT
	op.nome_fantasia,
	COUNT(r.id_reserva) AS qtde_reservas,
	SUM(r.qtd_pessoas * o.preco) AS receita_bruta
FROM reservas r
	LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta 
	LEFT JOIN operadores op ON o.id_operador = op.id_operador
WHERE UPPER(r.status) = 'CONCLUÍDA'
GROUP BY op.nome_fantasia
ORDER BY receita_bruta DESC;

-- Quantidade de operadores por localidade
SELECT
	op.localidade,
	COUNT(op.id_operador) AS qtde_operadores
FROM operadores op
GROUP BY op.localidade
ORDER BY qtde_operadores DESC;

-- Desempenho médio dos operadores por categoria de oferta 
SELECT
	o.id_operador,
	o2.nome_fantasia,
	o.tipo_oferta,
	ROUND(AVG(a.nota), 2) AS media_avaliacoes
FROM avaliacoes a 
	LEFT JOIN ofertas o
		ON a.id_oferta = o.id_oferta 
	LEFT JOIN operadores o2 
		ON o2.id_operador = o.id_operador
WHERE o.id_oferta IN (
						SELECT
							r.id_oferta
						FROM reservas r
						WHERE UPPER(r.status) = 'CONCLUÍDA'
						)
GROUP BY o.tipo_oferta, o.id_operador, o2.nome_fantasia
ORDER BY o2.nome_fantasia;

-- Avaliação média por tipo de atividade
SELECT
	o.tipo_oferta,
	ROUND(AVG(a.nota), 2) AS media_avaliacoes
FROM avaliacoes a 
	LEFT JOIN ofertas o
		ON a.id_oferta = o.id_oferta 
WHERE o.id_oferta IN (
						SELECT
							r.id_oferta
						FROM reservas r
						WHERE UPPER(r.status) = 'CONCLUÍDA'
						)
GROUP BY o.tipo_oferta
ORDER BY O.tipo_oferta, media_avaliacoes DESC;

-- VISÃO OFERTAS (Validação)

-- Quantidade de ofertas por tipo
SELECT
	o.tipo_oferta,
	COUNT(o.id_oferta) AS qtde_operadores
FROM ofertas o
GROUP BY o.tipo_oferta;

-- Pço médio das ofertas
SELECT
	ROUND(
		AVG(o.preco),
		2) AS preco_medio
FROM ofertas o;

-- Quantidade de reservas por tipo de acomodação
SELECT 
	h.tipo_acomodacao,
	COUNT(DISTINCT id_reserva)
FROM reservas r
	LEFT JOIN ofertas o ON o.id_oferta = r.id_oferta
	LEFT JOIN hospedagens h ON h.id_oferta = o.id_oferta
WHERE UPPER(r.status) = 'CONCLUÍDA'
GROUP BY h.tipo_acomodacao;

-- Quantidade de reservas por nível de dificuldade
SELECT 
	a.nivel_dificuldade,
	COUNT(DISTINCT id_reserva)
FROM reservas r
	LEFT JOIN ofertas o ON o.id_oferta = r.id_oferta
	LEFT JOIN atividades a ON a.id_oferta = o.id_oferta
WHERE UPPER(r.status) = 'CONCLUÍDA'
GROUP BY a.nivel_dificuldade;

-- Média de avaliação por oferta
SELECT
	o.id_oferta,
	ROUND(AVG(a.nota), 2) AS media_avaliacoes
FROM avaliacoes a 
	LEFT JOIN ofertas o
		ON a.id_oferta = o.id_oferta 
WHERE o.id_oferta IN (
						SELECT
							r.id_oferta
						FROM reservas r
						WHERE UPPER(r.status) = 'CONCLUÍDA'
						)
GROUP BY o.id_oferta
ORDER BY media_avaliacoes DESC;

-- Quantidade de ofertas sem reserva concluída
SELECT
	COUNT(DISTINCT o.id_oferta)
FROM ofertas o LEFT JOIN reservas r
	ON o.id_oferta = r.id_oferta
	AND UPPER(r.status) = 'CONCLUÍDA'
WHERE r.id_reserva IS NULL;

-- VISÃO SUSTENTABILIDADE (Validação)

-- Índice de adoção de práticas sustentáveis
-- Outra forma
SELECT
	ROUND(
		100.0 * COUNT(DISTINCT op.id_oferta) / (
												SELECT 
													COUNT(DISTINCT o.id_oferta)
												FROM ofertas o 
												)
			, 2) AS percentual_ofertas_praticas
FROM oferta_pratica op; 

-- Práticas sustentáveis mais populares 
SELECT
	ps.nome AS pratica_sustentavel, 	
	COUNT(r.id_reserva) AS frequencia
FROM reservas r 
	INNER JOIN oferta_pratica op -- Traz apenas as ofertas que já foram reservadas e que têm práticas sustentáveis associadas
		ON op.id_oferta = r.id_oferta AND UPPER(r.status) = 'CONCLUÍDA'
	INNER JOIN praticas_sustentaveis ps 
		ON ps.id_pratica = op.id_pratica
GROUP BY pratica_sustentavel
ORDER BY frequencia DESC;

-- Quantidade de práticas sustentáveis por oferta
SELECT 
	o.id_oferta,
	COUNT(DISTINCT op.id_pratica) AS qtde_praticas
FROM ofertas o LEFT JOIN oferta_pratica op 
	ON o.id_oferta = op.id_oferta 
GROUP BY o.id_oferta
ORDER BY qtde_praticas, o.id_oferta;