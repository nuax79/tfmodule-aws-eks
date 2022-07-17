/**
 * @see ./docs/HELP.md - EKS 클러스터 RBAC 구성
 * Cluster Role Binding for admin, viewer
 */
resource "kubernetes_cluster_role_binding" "admin" {
  count = var.create_eks ? 1 : 0

  metadata {
    name = "admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }

}

resource "kubernetes_cluster_role_binding" "viewer" {
  count = var.create_eks ? 1 : 0

  metadata {
    name = "viewer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "Group"
    name      = "system:viewers"
    api_group = "rbac.authorization.k8s.io"
  }

}