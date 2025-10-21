start:
	docker-compose --env-file .env up -d

migrate:
	docker exec -i db.lab2.postgres psql -U postgres -d lab2db < dump.sql