# Terraform + aws-vault
## Reference
https://zenn.dev/himekoh/books/202210261312

## aws-vault
aws-vaultへ追加
```
aws-vault add sample
aws-vault list
```

configに設定追加
```
[profile sample]
region=ap-northeast-1
output=json
mfa_serial=arn:aws:iam::1111222233:mfa/sample
```

実行
```
aws-vault exec sample
terraform apply
（aws-vault exec sample -- terraform apply）
```

解除（名前空間を抜ける）
```
exit
```

## Docker Terraform + aws-vault



```
aws-vault exec sample
docker compose up
docker compose run --rm terraform init
```