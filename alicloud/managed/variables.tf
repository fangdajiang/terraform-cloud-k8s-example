variable "TF_REQUIRED_PROVIDER_SOURCE" {
  default = "aliyun/alicloud"
}
variable "TF_REQUIRED_PROVIDER_VERSION" {
  default = "1.185.0"
}
variable "TF_REQUIRED_VERSION" {
  default = ">= 0.12"
}
variable "ALICLOUD_ACCESS_KEY" {
  default = ""
}
variable "ALICLOUD_SECRET_KEY" {
  default = ""
}
variable "ALICLOUD_REGION" {
  default = "cn-shanghai"
}
variable "ALICLOUD_PROFILE" {
  default = "default"
}
variable "image_id" {
  default = ""
}
# 默认资源名称
variable "name" {
  default = "k8s-demo"
}
# 日志服务项目名称
variable "log_project_name" {
  default = "k8s-sls-demo"
}
variable "key_name" {
  default = "sh-test"
}
variable "key_path" {
  default = "~/.ssh/id_rsa"
}

variable "k8s_number" {
  description = "The number of kubernetes cluster."
  default     = 1
}

variable "availability_zone" {
  description = "The availability zones of vswitches."
  default     = ["cn-shanghai-b", "cn-shanghai-d", "cn-shanghai-b"]
}

# leave it to empty would create a new one
variable "vpc_id" {
  description = "Existing vpc id used to create several vswitches and other resources."
  default     = ""
}
variable "vpc_name" {
  default = "terraform_created_vpc"
}
variable "vpc_cidr" {
  description = "The cidr block used to launch a new vpc when 'vpc_id' is not specified."
  default     = "10.0.0.0/8"
}

variable "vswitch_name" {
  default = ["terraform_created_vswitch_1", "terraform_created_vswitch_2", "terraform_created_vswitch_3"]
}
# leave it to empty then terraform will create several vswitches
variable "vswitch_ids" {
  description = "List of existing vswitch id."
  type        = list(string)
  default     = []
}
variable "vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches when 'vswitch_ids' is not specified."
  type        = list(string)
  default     = ["10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16"]
}

variable "new_nat_gateway" {
  description = "Whether to create a new nat gateway. In this template, a new nat gateway will create a nat gateway, eip and server snat entries."
  default     = "true"
}

variable "cluster_spec" {
  default     = "ack.pro.small"
}

# 3 masters is default settings,so choose three appropriate instance types in the availability zones above.
variable "master_instance_types" {
  description = "The ecs instance types used to launch master nodes."
  default     = ["ecs.g5ne.large"]
#  default     = ["ecs.g5ne.large", "ecs.g5ne.xlarge"]
}

variable "worker_instance_types" {
  description = "The ecs instance types used to launch worker nodes."
  default     = ["ecs.g5ne.large"]
#  default     = ["ecs.g5ne.large", "ecs.g5ne.xlarge"]
}

# options: between 24-28
variable "node_cidr_mask" {
  description = "The node cidr block to specific how many pods can run on single node."
  default     = 24
}

variable "enable_ssh" {
  description = "Enable login to the node through SSH."
  default     = true
}

variable "is_enterprise_security_group" {
  default     = true
}

variable "install_cloud_monitor" {
  description = "Install cloud monitor agent on ECS."
  default     = true
}

# options: none|static
variable "cpu_policy" {
  description = "kubelet cpu policy.default: none."
  default     = "none"
}

# options: ipvs|iptables
variable "proxy_mode" {
  description = "Proxy mode is option of kube-proxy."
  default     = "ipvs"
}

#variable "password" {
#  description = "The password of ECS instance."
#  default     = "Just4Test"
#}

variable "worker_number" {
  description = "The number of worker nodes in kubernetes cluster."
  default     = 3
}

# k8s_pod_cidr is only for flannel network
variable "pod_cidr" {
  description = "The kubernetes pod cidr block. It cannot be equals to vpc's or vswitch's and cannot be in them."
  default     = "172.20.0.0/16"
}

variable "service_cidr" {
  description = "The kubernetes service cidr block. It cannot be equals to vpc's or vswitch's or pod's and cannot be in them."
  default     = "172.21.0.0/20"
}


variable "cluster_addons" {
  description = "Addon components in kubernetes cluster"

  type = list(object({
    name   = string
    config = string
  }))

  default = [
    {
      "name"   = "flannel",
      "config" = "",
    },
    {
      "name"   = "flexvolume",
      "config" = "",
    },
    {
      "name"     = "arms-prometheus",
      "config"   = "",
    },
    {
      "name"     = "csi-plugin",
      "config"   = "",
    },
    {
      "name"     = "csi-provisioner",
      "config"   = "",
    },
    {
      "name"   = "alicloud-disk-controller",
      "config" = "",
    },
    {
      "name"   = "logtail-ds",
      "config" = "{\"IngressDashboardEnabled\":\"true\",\"sls_project_name\":\"your-sls-project-name\"}",
    },
    {
      "name"   = "nginx-ingress-controller",
      "config" = "{\"IngressSlbNetworkType\":\"internet\"}",
    },
  ]
}
