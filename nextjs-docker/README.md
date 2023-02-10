# Next.js + ECS Fargate

## Built

```
docker build -t nextjs-docker .
docker run -p 3000:3000 nextjs-docker
```

## Run

```
docker compose up -d
```

```
docker compose ps
docker exec -it nextjs-docker-next-1 sh
```

```
docker compose down down
```

## Deploy on AWS
```
```
