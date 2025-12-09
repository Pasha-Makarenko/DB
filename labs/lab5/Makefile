start:
	docker-compose --env-file .env up -d

stop:
	docker-compose --env-file .env down

drop:
	rm -r ./data_lab5

migrate:
	docker exec -i db.lab5.postgres psql -U postgres -d lab5db < ddl.sql