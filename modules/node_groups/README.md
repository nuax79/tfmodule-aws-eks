# eks `node_groups` submodule

[관리형 노드 그룹](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html)

관리형 노드는 클러스터에 조인한 이후 Kubernetes 애플리케이션(pod)을 배포할 수 있습니다. 

[eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) 을 통한 관리형 노드 그룹 생성 참고
```shell
eksctl create nodegroup \
  --cluster <my-cluster> \
  --region <us-west-2> \
  --name <my-mng> \
  --node-type <m5.large> \
  --nodes <3> \
  --nodes-min <2> \
  --nodes-max <4> \
  --ssh-access \
  --ssh-public-key <my-key> \
  --managed
```

## Assumptions
* node_groups 모듈은 직접 사용하지 않고 상위 모듈을 통해서 구성되도록 디자인 되었습니다.


## Node Groups' IAM Role
`var.default_iam_role_arn`에 지정된 역할 ARN이 기본적으로 사용됩니다. 간단한 구성에서 이것은 상위 모듈에 의해 생성 된 작업자 역할입니다.


The role ARN specified in `var.default_iam_role_arn` will be used by default. In a simple configuration this will be the worker role created by the parent module.

`iam_role_arn` must be specified in either `var.node_groups_defaults` or `var.node_groups` if the default parent IAM role is not being created for whatever reason, for example if `manage_worker_iam_resources` is set to false in the parent.

## `node_groups` and `node_groups_defaults` keys
`node_groups_defaults` is a map that can take the below keys. Values will be used if not specified in individual node groups.

`node_groups` is a map of maps. Key of first level will be used as unique value for `for_each` resources and in the `aws_eks_node_group` name. Inner map can take the below values.

| Name | Description | Type | If unset |
|------|-------------|:----:|:-----:|
| additional\_tags | Additional tags to apply to node group | map(string) | Only `var.tags` applied |
| ami\_release\_version | AMI version of workers | string | Provider default behavior |
| ami\_type | AMI Type. See Terraform or AWS docs | string | Provider default behavior |
| capacity\_type | Type of instance capacity to provision. Options are `ON_DEMAND` and `SPOT` | string | Provider default behavior |
| desired\_capacity | Desired number of workers | number | `var.workers_group_defaults[asg_desired_capacity]` |
| disk\_size | Workers' disk size | number | Provider default behavior |
| iam\_role\_arn | IAM role ARN for workers | string | `var.default_iam_role_arn` |
| instance\_types | Node group's instance type(s). Multiple types can be specified when `capacity_type="SPOT"`. | list | `[var.workers_group_defaults[instance_type]]` |
| k8s\_labels | Kubernetes labels | map(string) | No labels applied |
| key\_name | Key name for workers. Set to empty string to disable remote access | string | `var.workers_group_defaults[key_name]` |
| launch_template_id | The id of a aws_launch_template to use | string | No LT used |
| launch\_template_version | The version of the LT to use | string | none |
| max\_capacity | Max number of workers | number | `var.workers_group_defaults[asg_max_size]` |
| min\_capacity | Min number of workers | number | `var.workers_group_defaults[asg_min_size]` |
| name | Name of the node group | string | Auto generated |
| source\_security\_group\_ids | Source security groups for remote access to workers | list(string) | If key\_name is specified: THE REMOTE ACCESS WILL BE OPENED TO THE WORLD |
| subnets | Subnets to contain workers | list(string) | `var.workers_group_defaults[subnets]` |
| version | Kubernetes version | string | Provider default behavior |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of parent cluster | `string` | n/a | yes |
| create\_eks | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| default\_iam\_role\_arn | ARN of the default IAM worker role to use if one is not specified in `var.node_groups` or `var.node_groups_defaults` | `string` | n/a | yes |
| ng\_depends\_on | List of references to other resources this submodule depends on | `any` | `null` | no |
| node\_groups | Map of maps of `eks_node_groups` to create. See "`node_groups` and `node_groups_defaults` keys" section in README.md for more details | `any` | `{}` | no |
| node\_groups\_defaults | map of maps of node groups to create. See "`node_groups` and `node_groups_defaults` keys" section in README.md for more details | `any` | n/a | yes |
| tags | A map of tags to add to all resources | `map(string)` | n/a | yes |
| workers\_group\_defaults | Workers group defaults from parent | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_auth\_roles | Roles for use in aws-auth ConfigMap |
| node\_groups | Outputs from EKS node groups. Map of maps, keyed by `var.node_groups` keys. See `aws_eks_node_group` Terraform documentation for values |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
