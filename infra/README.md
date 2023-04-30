# Infrastructure by Terraform

## Install
### Github Projects
project -> Workflow
```
Item closed
Pull request merged
Item added to project <- 追加
Auto added to project <- 追加
```

### Github Apps
個人アカウントで Github Apps を作成
```
https://github.com/settings/apps/
```
Github Apps から対象リポジトリへインストール
```
https://github.com/settings/apps/test-code-scanning/installations
```
リポジトリで Webhook を有効化
```
https://github.com/runble1/infra/settings/hooks
```

## Deploy
aws-vault only
```
aws-vault exec jitsudan
terraform init
terraform apply
```
aws-vualt + Docker
```
aws-vault exec jitsudan
docker compose up
docker compose run --rm terraform init
```

## セキュリティチェック
```
Dockle : 
git-secrets : 
Trivy : 
```

### 0. コンテナレジストリとコードリポジトリ作成
```
cd resource/enviroments/dev
terraform apply --target=module.ecr
terraform apply --target=module.codecommit
```

### レジストリへ認証
```
aws-vault exec jitsudan
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/
```


## 1 Network
```
terraform apply --target=module.network
```

## 3 ECS
```
terraform apply --target=module.ecs
```

## 2 ALB
```
terraform apply --target=module.alb
```

## 3 Pipeline

