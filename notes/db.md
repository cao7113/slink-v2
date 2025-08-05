# DB ops

## Reset sequence last-value

```
SELECT setval('links_id_seq', COALESCE((SELECT MAX(id) FROM links), 0));
SELECT * FROM pg_sequences WHERE sequencename = 'links_id_seq';
```
