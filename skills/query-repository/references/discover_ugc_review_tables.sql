SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'ugc'
  AND (
      LOWER(table_name) LIKE '%review%'
      OR LOWER(table_name) LIKE '%rating%'
  )
ORDER BY table_name
