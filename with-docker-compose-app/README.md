# Next.js with Docker Compose

This example contains everything needed to get a Next.js development and production environment up and running with Docker Compose.

## ローカル開発
### Build
```
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up -d
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

## デプロイ
### 準備
```
aws-vault exec test
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export GIT_COMMIT_ID=$(git rev-parse HEAD)
export REPOSITORY_URL=<repository_url>
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/
```

### ビルド(prod)
```
cd next-app && npm install
cd ..
docker compose -f docker-compose.prod.yml build
docker images
```

### イメージをプッシュ
```
docker compose -f docker-compose.prod.yml push
```
