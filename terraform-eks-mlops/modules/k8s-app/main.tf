resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = "${var.image_repo}:${var.image_tag}"

          port {
            container_port = var.container_port
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.this]
}

resource "kubernetes_service" "this" {
  metadata {
    name      = "${var.app_name}-svc"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = 80
      target_port = var.container_port
    }

    type = "ClusterIP"
  }
  depends_on = [kubernetes_deployment.this]
}

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace.this.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                 = "alb"
      "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"       = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path"   = "/health"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.this.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_service.this]
}