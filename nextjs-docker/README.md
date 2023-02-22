# Next.js + ECS Fargate

## Usage

### Built

```
docker build -t nextjs-docker .
docker run -p 3000:3000 nextjs-docker
```

### Run

```
docker compose up -d
```

```
docker compose ps
docker exec -it nextjs-docker-next-1 sh
```

```
docker compose down
```

### Git

```
git add .
git commit -m "first commit"
git remote add origin https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/next-docker
git branch -M main
git push --set-upstream origin main
```