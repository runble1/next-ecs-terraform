# Usage

## コンテナレジストリの構築
```
cd resource/enviroments/dev
terraform apply --target=module.ecr
```

## レジストリへ認証
```
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/
```

## レジストリへイメージ登録
```
cd nextjs-docker
GIT_COMMIT_ID=$(git log --format="%H" -n 1)
docker image build -t nextjs-docker:"${GIT_COMMIT_ID}" .
docker image tag nextjs-docker:"${GIT_COMMIT_ID}" ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/next-docker:"${GIT_COMMIT_ID}"
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/next-docker:"${GIT_COMMIT_ID}"
```

## 1 Network
```
terraform apply --target=module.network
```

## 2 ALB
```
terraform apply --target=module.alb
```

## 3 ECS
```
terraform apply --target=module.ecs
```


aws cloudformation deploy \
--stack-name sbctr-network \
--template-file network_step2.yml

## 2 Backend
aws cloudformation deploy \
--stack-name sbcntr-backend-stack \
--template-file backend.cf.yml \
--capabilities CAPABILITY_NAMED_IAM

## 3 Frontend
aws cloudformation deploy \
--stack-name sbcntr-frontend-stack \
--template-file frontend.cf.yml

## 4 Aurora
aws cloudformation deploy \
--stack-name sbctr-db \
--template-file db.yml

## 5 Bastion(humidai)
aws cloudformation deploy \
--stack-name sbctr-ec2 \
--template-file ec2.yml

## 5.5 踏み台準備 (EC2 Instance Connect & )
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v14.16.1
nvm alias default v14.16.1
npm i -g yarn

git clone https://github.com/uma-arai/sbcntr-frontend.git
cd sbcntr-frontend
yarn install --pure-lockfile --roduction
npx blitz -v

yum install docker

## 6 db 準備
mysql -h -u admin -p 

CREATE USER sbcntruser@'%' IDENTIFIED BY 'sbcntrEncP';
GRANT ALL ON sbcntrapp.* TO sbcntruser@'%' WITH GRANT OPTION;

CREATE USER migrate@'%' IDENTIFIED BY 'sbcntrMigrate';
GRANT ALL ON sbcntrapp.* TO migrate@'%' WITH GRANT OPTION;
GRANT ALL ON `prisma_migrate_shadow_db%`.* TO migrate@'%' WITH GRANT OPTION;

SELECT Host, User FROM mysql.user;

mysql -h sbcntr-db.cluster-cwr5ao9wqdny.ap-northeast-1.rds.amazonaws.com -u sbcntruser -p
mysql -h sbcntr-db.cluster-cwr5ao9wqdny.ap-northeast-1.rds.amazonaws.com -u migrate -p

## 7 テーブル作成、データ投入
export DB_USERNAME=migrate
export DB_PASSWORD=sbcntrMigrate
export DB_HOST=sbcntr-db.cluster-cwr5ao9wqdny.ap-northeast-1.rds.amazonaws.com
export DB_NAME=sbcntrapp

npm run migrate:dev
npm run seed


## 8 Secret Manager
aws cloudformation deploy \
--stack-name sbctr-secrets \
--template-file secrets.yml \
--capabilities CAPABILITY_NAMED_IAM

## 9 Backend2
aws cloudformation deploy \
--stack-name sbcntr-backend-stack \
--template-file backend2.cf.yml \
--capabilities CAPABILITY_NAMED_IAM

## 10 CodeCommit
git remote -v
git remote set-url origin https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/sbcntr-backend



aws cloudformation deploy \
--stack-name sbcntr-code \
--template-file code.yml \
--capabilities CAPABILITY_NAMED_IAM


## 11 base 共通イメージ
docker image pull golang:1.16.8-alpine3.13

docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/

docker image tag golan:1.16.8-alpine3.13 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:golang1.16.8-alpine3.13


docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:golang1.16.8-alpine3.13

## 12 確認
hello world 修正
踏み台から curl


## 13 Log Router
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

docker image build -t sbcntr-log-router .

aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/

docker image tag sbcntr-log-router:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:log-router

docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:log-router

## 14 ログ保管場所作成
aws cloudformation deploy \
--stack-name sbcntr-log \
--template-file log.yml \
--capabilities CAPABILITY_NAMED_IAM

## 15 backend3
aws cloudformation deploy \
--stack-name sbcntr-backend-stack \
--template-file backend3.cf.yml \
--capabilities CAPABILITY_NAMED_IAM


## 15.5 確認
curl
s3確認


## Bastion
SystemsManagerインスタンスティアをアドバンスドに変更


git clone https://github.com/uma-arai/sbcntr-resources.git

docker image build -t fargate-bastion .

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)


aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/


docker image tag fargate-bastion:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:bastion

docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:bastion

aws cloudformation deploy \
--stack-name sbctr-bastion \
--template-file bastion.yml

## Trivy