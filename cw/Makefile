start:
	docker-compose --env-file .env up -d

stop:
	docker-compose --env-file .env down

drop:
	rm -r ./data_cw

migrate:
	docker exec -i db.cw.postgres psql -U postgres -d cwdb < ddl.sql

mock:
	docker exec -i db.cw.postgres psql -U postgres -d cwdb < dump.sql