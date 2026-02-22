# AWS Portfolio Infrastructure

**⚠️ Heavily Work In Progress: 現在構築・学習中のプロジェクトです。**
AWS(東京・大阪リージョン)を活用した高可用性(HA)サイトのインフラ構成です。
趣味とAWS-SAAの学習を兼ねて、Terraformによるインフラ配備の自動化を段階的に実装しています。

## 構成概要

このプロジェクトは現在、以下のインフラ要素の実装を目的としています。

- **マルチリージョン・フェイルオーバー**: 東京リージョンをメイン、大阪リージョンをスタンバイとして運用。
- **Infrastructure as Code (IaC)**: Terraformによるリソース管理のモジュール化。
<!-- - **自動DNS更新**: Route 53のヘルスチェックに基づき、CloudflareのNSレコードを自動制御。-->

<!--
## ネットワーク構成図

![Architecture Diagram](./architecture.png)
*(※後日追加)*
-->

## ファイル構成

- `providers.tf`: AWSおよびCloudflareのプロバイダー設定
- `vpc.tf`: VPC、サブネット、インターネットゲートウェイ、ルートテーブル
- `security.tf`: セキュリティグループ(ポート80等の開放設定)
- `compute.tf`: EC2インスタンス、AMI選択、Apache自動起動
- `dns.tf`: Route 53ホストゾーン、ヘルスチェック、デプロイ時のCloudflare連携設定
- `outputs.tf`: 情報出力用

## 導入手順

### 1. 事前準備

以下の内容を含む `terraform.tfvars` を作成してください(このファイルはGit管理から除外されます)。

```hcl
cloudflare_api_token = "CLOUDFLARE_API_TOKEN"
cloudflare_zone_id    = "CLOUDFLARE_ZONE_ID"