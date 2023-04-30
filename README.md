# Next.js + ECS Fargate

## Install
### Github Code Scanning
有効化
```
Settings > Security > Code security and analysis > Code scanning > Set up > Default
```
CodeQL Analysis が完了すること

## Usage
### .github
何かする用の Github Actions

### gh_codescan
Github Apps 用の Lambda

### infra
ECS 用の Terraform、別リポジトリ

### next-docker
ECS デプロイサンプル用の Next.js

### security
AWS へのセキュリティ設定