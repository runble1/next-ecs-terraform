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

### Github Code Scanning
有効化
```
Settings > Security > Code security and analysis > Code scanning > Set up > Default
```
CodeQL Analysis が完了すること
