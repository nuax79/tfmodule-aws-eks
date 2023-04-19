# terraform-aws-eks

terraform-aws-eks 모듈을 DevOps 툴체인을 위한 모듈 자동화를 목적으로 합니다.

## Reference

HashiCorp 의 [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) 모듈을 참고 하세요.

## Customize Features

기능 개선 Features

- Naming 룰 자동화
- IAM Role 생성 (어드민, 개발자)
- IAM Role 생성 (마스터용, 워커노드용)
- IAM EC2 인스턴스 프로파일 참조
- 워커 노드용 AMI 필터 자동화
- ec2 launch template 구성 자동화
- vpc 참조 자동화
- eks 클러스터 노드를 위한 subnet 식별(필터) 자동화
- eks 워커 노드를 위한 subnet 식별(필터) 자동화
- 보안 그룹 정책 적용 (워커노드용)
- k8s 클러스터 롤 바인딩 자동화 (어드민 / 개발자)
- Istio 서비스 메시 구성 자동화

## Example

# simple

Simple EKS 를 구성 합니다.

## Prerequisite

- AWS Account 가 준비되어야 합니다.
- IaC 툴(Terraform)에 AWS 클라우드 자원을 구성 할 수 있는 IAM 권한이 준비되어야 합니다.
- AWS Profile 환경을 구성 합니다.

[AWS Profile 구성 예시](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-configure-files.html)

```
aws configure --profile test

AWS Access Key ID [None]: *********
AWS Secret Access Key [None]: *******
Default region name [None]: ap-northeast-2
Default output format [None]: json

export AWS_DEFAULT_PROFILE=test
export AWS_PROFILE=test
export AWS_REGION=ap-northeast-2
```

## Context 상수 선언

```hcl
테라폼 프로젝트를 참조하는 여러 변수를 context 를 구조체를 통해 한번에 정의 하여 전달 합니다.
variable "context" {
type = object({
aws_credentials_file = string # describe a path to locate a credentials from access aws cli
aws_profile = string # describe a specifc profile to access a aws cli
aws_region = string # describe default region to create a resource from aws
region_alias            = string # region alias or AWS
project = string # project name is usally account's project name or platform name
environment = string # Runtime Environment such as develop, stage, production
env_alias = string # Runtime Environment such as develop, stage, production
owner = string # project owner
team = string # Team name of Devops Transformation
cost_center = string # Cost Center
})
}

# terraform.tfvars 파일의 context 상수 선언 예시
context = {
aws_credentials_file = "$HOME/.aws/credentials"
aws_profile = "test"
aws_region = "ap-northeast-2"
region_alias            = "an2"

project = "simple"
environment = "Testbed"
env_alias = "t"
owner = "devdataopsx_bgk@bespinglobal.com"
team_name = "Devops Transformation"
team = "test"
cost_center = "20080718"
domain = "devapp.shop"
pri_domain = "toolchain"
}
```

## Build

테라폼 모듈을 통해 EKS 클러스터를 신속하게 구성합니다.

```shell
git clone https://github.com/nuax79/tfmodule-aws-vpc.git
cd tfmodule-aws-eks/examples/simple

terraform init
terraform plan
terraform apply
```

## Destroy

```shell
terraform destroy
```

## Checking

kubernetes 리소스를 kubectl API 를 통해 확인 할 수 있습니다.

```shell
export AWS_PROFILE=test
aws eks update-kubeconfig --name simple-an2t-eks

kubectl get namespace
kubectl get node -A
kubectl get po -A
kubectl get gateway, svc, deploy -A
```
 



