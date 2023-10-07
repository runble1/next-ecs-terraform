# Infrastructure by Terraform

## Install

## Deploy
aws-vault
```
aws-vault exec test
terraform init
terraform apply
```

aws-vualt + Docker
```
aws-vault exec test
docker compose up
docker compose run --rm terraform init
```

### 1. コンテナレジストリとコードリポジトリ作成
```
cd envs/dev
terraform apply -target=module.ecr
```

### 1.5
ECRへイメージプッシュ

### 2 Network
```
terraform apply -target=module.network
```

### 3 ALB
```
terraform apply --target=module.alb
```

### 4 SSM
```
terraform apply --target=module.ssm
```

### 5 ECS
imageを最初だけ手打ち？
```
terraform apply --target=module.ecs
```

### 5 確認
public dnsにアクセスし503 Service Temporarily Unavailable

### 6
Github Actions?

## Destroy
ECRのimageを手動で削除
terraform destroy