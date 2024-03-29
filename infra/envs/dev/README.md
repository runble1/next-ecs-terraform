# aws-vault + Terraform


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
tagを最初だけ手打ち
```
terraform apply --target=module.ssm
```

### 5 ECS
```
terraform apply --target=module.ecs2
```

### 6 ローカルからecspressoでデプロイ
デプロイ
```
ecspresso deploy --config ecspresso.yml
```
リスト確認
```
terraform state list
```

### 7 Github Actions でデプロイ
- タスク定義が更新された場合（Terraform）
- アプリが更新された場合（Github Actions）

## 9 Destroy
ECRのimageを手動で削除
terraform destroy