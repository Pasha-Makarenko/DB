start:
	docker-compose --env-file .env up -d

stop:
	docker-compose --env-file .env down

drop:
	rm -r ./data_lab2

migrate:
	docker exec -i db.lab2.postgres psql -U postgres -d lab2db < dump.sql