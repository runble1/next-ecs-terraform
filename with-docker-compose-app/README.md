# Next.js with Docker Compose

This example contains everything needed to get a Next.js development and production environment up and running with Docker Compose.

## ローカル開発
### Build
```
docker compose -f docker-compose.dev.yml up -d
or
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml start
```

### 確認
http://localhost:3000/
```
docker compose ps -f docker-compose.dev.yml
docker exec -it next-app sh
```

### シャットダウン
```
docker compose -f docker-compose.dev.yml down
```

## 手動デプロイ
### 前提
```
aws-vault exec test
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export REPOSITORY_URL=404307571516.dkr.ecr.ap-northeast-1.amazonaws.com/nextjs
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/
```

### 準備
```
export GIT_COMMIT_ID=$(git rev-parse HEAD)
```

### ビルド(prod)
```
cd next-app && npm install
cd ..
docker compose -f docker-compose.prod.yml build
docker images
```

### 確認
http://localhost:3000/api/healthcheck で 200 が返ってくればOK
```
docker compose -f docker-compose.prod.yml up -d --build
```

### イメージをECRへプッシュ
```
docker compose -f docker-compose.prod.yml push
```
