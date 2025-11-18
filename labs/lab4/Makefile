start:
	docker-compose --env-file .env up -d

stop:
	docker-compose --env-file .env down

drop:
	rm -r ./data_lab4

migrate:
	docker exec -i db.lab4.postgres psql -U postgres -d lab4db < ddl.sql

mock:
	docker exec -i db.lab4.postgres psql -U postgres -d lab4db < mock.sql