start:
	docker-compose --env-file .env up -d

stop:
	docker-compose --env-file .env down

drop:
	rm -r ./data_lab3

migrate:
	docker exec -i db.lab3.postgres psql -U postgres -d lab3db < ddl.sql