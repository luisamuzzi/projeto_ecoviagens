/* Receita total por período e diferença percentual 
 * 
 * Objetivo: Monitorar o crescimento da receita do negócio e identificar sazonalidades.
 * 
 * Calcula a receita total (qtde_pessoas X preco unitário) agrupada para cada ano e mês.
 * Calcula a diferença percentual entre a receita total no mês atual e a receita total no mês anterior.
 * Considera apenas reservas concluídas.
 * 
 * */
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

/* Valor médio gasto por pessoa
 * 
 * Objetivo: Identificar se os clientes estão investindo mais em experiências premium ou optando por opções econômicas.
 * 
 * Calcula a média de preço gasto por pessoa.
 * Considera apenas reservas concluídas.
 * */
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

/* Distribuição de reservas por tipo de oferta
 * 
 * Objetivo: Saber qual tipo de oferta é mais popular para orientar a divulgação dessas experiências no site da EcoViagens.
 * 
 * Calcula a contagem de reservas agrupadas por tipo (atividade e hospedagem).
 * A popularidade das ofertas é medida pela quantidade de reservas.
 * Considera apenas reservas confirmadas ou concluídas.
 * 
 *  */
SELECT
	o.tipo_oferta,
	COUNT(r.id_reserva) AS qtd_reservas,
	SUM(r.qtd_pessoas) AS total_viajantes -- Alternativamente, calcula-se também o total de viajantes
FROM reservas r
	LEFT JOIN ofertas o ON r.id_oferta = o.id_oferta
WHERE UPPER(r.status) <> 'CANCELADA'
GROUP BY o.tipo_oferta;

/* Taxa de repetição de clientes (fidelização)
 * 
 * Objetivo: Medir o engajamento, satisfação e fidelização com as experiências oferecidas.
 * 
 * Calcula o percentual de clientes que retornaram para novas experiências com a EcoViagens.
 * Considera apenas reservas concluídas.
 * 
 */
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

/* Avaliação média das ofertas
 * 
 * Objetivo: Identificar as ofertas com o melhor desempenho percebido pelo cliente.
 * Calcula a média de notas recebidas por cada oferta.
 * Considera apenas reservas concluídas.
 * 
 * */
-- Essa query prioriza a tabela ofertas, ou seja, traz registros dela que podem não ter correspondências na tabela reservas ou na tabela avaliações
SELECT
	o.id_oferta,
	o.titulo,
	ROUND(
		AVG(a.nota) 
		, 2
		  ) AS nota_media
FROM ofertas o
	LEFT JOIN reservas r ON o.id_oferta = r.id_oferta AND UPPER(r.status) = 'CONCLUÍDA' -- O join dessa forma considera que pode haver ofertas que nunca tiveram reservas concluídas
	LEFT JOIN avaliacoes a ON a.id_oferta = o.id_oferta -- O join dessa forma considera que pode haver ofertas que nunca tiveram avaliações
GROUP BY o.id_oferta, o.titulo
ORDER BY nota_media DESC;

-- Essa query traz apenas registros que têm correspondência entre as tabelas (ofertas que tiveram reservas concluídas e avaliações)
SELECT
	o.id_oferta,
	o.titulo,
	ROUND(
		AVG(a.nota) 
		, 2
		  ) AS nota_media
FROM ofertas o
	INNER JOIN reservas r ON o.id_oferta = r.id_oferta AND UPPER(r.status) = 'CONCLUÍDA' -- O join dessa forma considera apenas correspondências entre as duas tabelas
	INNER JOIN avaliacoes a ON a.id_oferta = o.id_oferta -- O join dessa forma considera apenas correspondências entre as duas tabelas
GROUP BY o.id_oferta, o.titulo
ORDER BY nota_media DESC;

-- Essa query separa as informações entre ofertas avaliadas; não avaliadas por não ter reserva concluída; e com reserva concluída, mas sem avaliação
SELECT
	o.id_oferta,
	o.titulo,
	ROUND(
		AVG(a.nota) 
		, 2
		  ) AS nota_media,
		CASE
			WHEN COUNT(DISTINCT r.id_reserva) = 0 THEN 'Sem reserva concluída' -- Conta quantas reservas únicas determinada oferta teve e as que tiveram zero são marcadas como "Sem reserva concluída"
			WHEN COUNT(DISTINCT r.id_reserva) > 0 AND COUNT(DISTINCT a.id_avaliacao) = 0 THEN 'Reserva concluída, mas sem avaliação' -- Conta reservas únicas e quantas avaliações únicas determinada oferta teve e as que tiveram mais de zero reservas e zero avaliações são marcadas como "Rerva concluída, mas sem avaliação"
			ELSE 'Reserva e avaliação presentes'		
		END AS status_oferta
FROM ofertas o
	LEFT JOIN reservas r ON o.id_oferta = r.id_oferta AND UPPER(r.status) = 'CONCLUÍDA' -- O join dessa forma considera que pode haver ofertas que nunca tiveram reservas concluídas
	LEFT JOIN avaliacoes a ON a.id_oferta = o.id_oferta -- O join dessa forma considera que pode haver ofertas que nunca tiveram avaliações
GROUP BY o.id_oferta, o.titulo
ORDER BY nota_media DESC;

/* Índice de adoção de práticas sustentáveis
 * 
 * Objetivo: Garantir que as ofertas estejam atreladas aos valores da marca (impacto ambiental positivo).
 * Calcula percentual de ofertas que têm práticas sustentáveis implementadas.
 * 
 */
WITH ofertas_praticas AS
(
-- Seleciona as ofertas e suas práticas sustentáveis associadas
	SELECT
		o.id_oferta,
		ps.id_pratica 
	FROM ofertas o
		LEFT JOIN oferta_pratica op on o.id_oferta = op.id_oferta
		LEFT JOIN praticas_sustentaveis ps on op.id_pratica = ps.id_pratica
)
-- Calcula o percentual de ofertas que têm práticas sustentáveis implementadas
SELECT
	ROUND(
	(SELECT
		COUNT(DISTINCT id_oferta)
	FROM ofertas_praticas 
	WHERE id_pratica IS NOT NULL) * 100.0 / COUNT(DISTINCT id_oferta)
		   , 2
		  ) AS percentual_ofertas_praticas
FROM ofertas_praticas;

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

/* Práticas sustentáveis mais populares 
 * 
 * Objetivo: Identificar quais práticas sustentáveis são mais valorizadas e têm maior impacto no posicionamento e narrativa da EcoViagens.
 * Calcula quais práticas sustentáveis aparecem com mais frequência nas experiências reservadas.
 * Considera apenas reservas concluídas.
 *
 */
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

/* Tempo médio entre reservas dos clientes recorrentes
 * 
 * Objetivo: Auxiliar na criação de campanhas de reengajamento no momento ideal e evitar churn.
 * Calcula com que frequência os clientes fiéis fizeram novas reservas.
 * Considera apenas reservas concluídas.
 * 
 * */
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
	id_cliente,
	ROUND(
		AVG(data_reserva - data_reserva_anterior)
		, 2) AS media_dias
FROM lag_reserva
GROUP BY id_cliente 
ORDER BY media_dias DESC;

/* Desempenho médio dos operadores por categoria de oferta 
 * 
 * Objetivo: Premiar os melhores parceiros e oferecer treinamento aos demais.
 * Calcula a média de avaliação dos operadores por tipo de experiência (atividade ou hospedagem).
 * 
 */
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
ORDER BY o.tipo_oferta, media_avaliacoes DESC;