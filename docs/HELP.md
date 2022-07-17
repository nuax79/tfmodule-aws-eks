## EKS 클러스터 구성 
[cluster.tf 참고](../cluster.tf)
aws_eks_cluster 리소스를 생성 합니다.

## EKS 클러스터의 사용자 / IAM 역할 관리
[aws_auth.tf](../aws_auth.tf) AWS IAM 사용자 / 역할을 쿠버네티스 사용자 및 그룹에 매핑 합니다. [AWS AUTH 참고](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/add-user-role.html)

Amazon EKS 클러스터를 생성할 경우, 클러스터를 생성하는 IAM 사용자나 역할은 Control Plane 에서 클러스터 RBAC 그룹 권한(system:masters)이 자동으로 부여됩니다. 

IAM 엔터티(역할 및 사용자)는 EKS의 ConfigMap 등에서 보여지지 않으므로 클러스터를 생성한 IAM 엔터티를 구성 해야 합니다.
이를 위해 Kubernetes 내에서 aws-auth ConfigMap을 편집해야 합니다.


```yaml
apiVersion: v1
data:
  mapRoles: |
    - rolearn: <arn:aws:iam::111122223333:role/eksctl-my-cluster-nodegroup-standard-wo-NodeInstanceRole-1WP3NUE3O6UCF>
      username: <system:node:{{EC2PrivateDNSName}}>
      groups:
        - <system:bootstrappers>
        - <system:nodes>
  mapUsers: |
    - userarn: <arn:aws:iam::111122223333:user/admin>
      username: <admin>
      groups:
        - <system:masters>
    - userarn: <arn:aws:iam::111122223333:user/ops-user>
      username: <ops-user>
      groups:
        - <system:masters>
```

mapRoles 는 AWS IAM 역할 권한을 kubernetes 사용자 및 그룹에 매핑 합니다.
"system:bootstrappers"은 kubernetes 의 빌트인 그룹으로 구동에 관련한 관리를 포함 합니다.
"system:nodes"은 kubernetes 의 빌트인 그룹으로 node 관리를 포함 합니다.

mapUsers 는 AWS IAM 사용자 계정을 kubernetes 사용자 및 그룹에 매핑 합니다.
"system:masters" 의 kubernetes 그룹은 admin 권한을 포함하며 "system:bootstrappers"와 "system:nodes" 해당하는 권한은 기본으로 가지게 됩니다.


## EKS 클러스터 RBAC 구성
클러스터 전체의 API / 리소스(pod,deploy,...) 에 대한 사용 권한을 구성 합니다.
클러스터 롤 바인딩은 User와 Cluster-Role을 묶어주는 역할을 수행하고, User에 한해서 롤에 명시한 규칙들을 기준으로 권한을 사용할 수 있도록 관리 합니다.


다음은 ClusterRoleBinding을 통해 dev01 사용자는 dev-clusterrole 클러스터 롤(권한)을 위임 받는 구성의 예제 입니다.

[클러스터 롤 생성]
```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-clusterrole
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

[사용자 생성]
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev01
  namespace: default
```

[클러스터롤 바인딩 생성]
```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: dev01
  namespace: default
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: dev-clusterrole
  apiGroup: rbac.authorization.k8s.io
```

쿠버네티스 RBAC 은 [Default roles and role bindings](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings) 을 참조 하세요.
API discovery roles, User-facing roles, Core component roles, Other component roles 을 확인 할 수 있습니다.

### 참고 
- [cluster-rbac.tf](../cluster-rbac.tf) 
- [EKS Full Access RBAC](https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml)
