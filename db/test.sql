
-- *****Get answers with no JOIN*****
-- SELECT
--   json_build_object(
--     'question', 1,
--     'page', 0,
--     'count', 5,
--     'results', results
--     )
-- FROM (
--   SELECT coalesce(json_agg(answers_rows), '[]') AS results
--   FROM (
--     SELECT
--       a.id AS answer_id,
--       body,
--       date_written AS date,
--       answerer_name,
--       helpful AS helpfulness, (
--       SELECT coalesce(json_agg(photos_rows), '[]') AS photos
--       FROM (
--         SELECT
--           id,
--           url
--         FROM photos
--         WHERE answer_id = a.id
--         ) AS photos_rows
--       )
--     FROM answers AS a WHERE question_id=888
--   ) AS answers_rows
-- ) AS _unused_



-- *****GET Questions with no JOIN*****
-- SELECT
--   json_build_object(
--     'product_id', 5,
--     'results', results
--     )
-- FROM
--   (
--   SELECT coalesce(json_agg(question_rows), '[]') AS results
--   FROM (
--     SELECT
--       q.id AS question_id,
--       body AS question_body,
--       date_written AS question_date,
--       asker_name,
--       helpful AS question_helpfulness,
--       reported,
--       (
--         SELECT
--           jsonb_object_agg(
--             id, answers
--           ) AS answers
--         FROM (
--           SELECT
--             a.id,
--             body,
--             date_written AS date,
--             answerer_name,
--             helpful AS helpfulness, (
--             SELECT coalesce(json_agg(photos_rows), '[]') AS photos
--             FROM (
--               SELECT
--                 id,
--                 url
--               FROM photos
--               WHERE answer_id = a.id
--               ) AS photos_rows
--             )
--           FROM answers AS a
--           WHERE question_id=q.id
--           LIMIT 2
--         ) AS answers
--       )
--     FROM questions AS q
--     WHERE q.product_id=5
--   ) AS question_rows
--   ) AS _unused_

-- ****GET answers using JOIN*****
-- WITH result_rows AS (
-- 	SELECT
-- 		a.id AS answer_id,
-- 		body,
-- 		date_written AS date,
-- 		answerer_name,
-- 		helpful AS helpfulness,
-- 		coalesce(
-- 		json_agg(
-- 			json_build_object('id', p.id, 'url', p.url)
-- 		) FILTER (WHERE p.id IS NOT NULL), '[]'
-- 		) AS photos
-- 	FROM answers a
-- 	LEFT JOIN photos p ON a.id=p.answer_id
-- 	WHERE a.question_id=1
-- 	GROUP BY a.id
-- )
-- SELECT json_build_object(
-- 	'question', 1,
-- 	'page', 0,
-- 	'count', 5,
-- 	'results', json_agg(
-- 		json_build_object(
-- 			'answer_id', answer_id,
-- 			'body', body,
-- 			'date', date,
-- 			'answerer_name', answerer_name,
-- 			'helpfulness', helpfulness,
-- 			'photos', photos
-- 		)
-- 	)
-- ) AS results
-- FROM result_rows