# aws-vault + Terraform

## Architect
Github Actions -> AWS Fargate

## Usage
実行
```
aws-vault exec test
terraform apply
（aws-vault exec test -- terraform apply）
```

## Setting
aws-vaultへ追加
```
aws-vault add test
aws-vault list
```

configに設定追加
```
[profile sample]
region=ap-northeast-1
output=json
mfa_serial=arn:aws:iam::1111222233:mfa/sample
```

確認
```
aws-vault exec sample -- env | grep AWS_
```

解除（名前空間を抜ける）
```
exit
```