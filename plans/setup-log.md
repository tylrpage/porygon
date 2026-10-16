# Setup log
This is for me to write down the steps I needed to take to run everything locally

1. Install go, docker, and awscli
2. Switch to node 24
3. Install go with goose
4. Start docker desktop
5. Start postgres `docker compose up -d`
    1. `docker compose ps` and check if status is healthy
6. Run the migration
    1. ` goose -dir db/migrations postgres "postgres://porygon:porygon@localhost:5432/porygon?sslmode=disable" up`
7. Install sqlc v1.31.1 (can't easily be installed as go tool on Windows)
