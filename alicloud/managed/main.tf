// If there is not specifying vpc_id, the module will launch a new vpc
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_name
  count      = var.vpc_id == "" ? 1 : 0
  cidr_block = var.vpc_cidr
}
// According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "vswitches" {
  count      = length(var.vswitch_ids) > 0 ? 0 : length(var.vswitch_cidrs)
  vpc_id     = var.vpc_id == "" ? join("", alicloud_vpc.vpc.*.id) : var.vpc_id
  cidr_block = element(var.vswitch_cidrs, count.index)
  zone_id    = element(var.availability_zone, count.index)
  vswitch_name = element(var.vswitch_name, count.index)
}
# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cs_managed_kubernetes
resource "alicloud_cs_managed_kubernetes" "k8s" {
  name               = var.name
  count              = var.k8s_number
  cluster_spec       = var.cluster_spec
  is_enterprise_security_group = var.is_enterprise_security_group
  # version can not be defined in variables.tf.
  version            = "1.22.10-aliyun.1"
  worker_vswitch_ids = length(var.vswitch_ids) > 0 ? split(",", join(",", var.vswitch_ids)): length(var.vswitch_cidrs) < 1 ? [] : split(",", join(",", alicloud_vswitch.vswitches.*.id))
  new_nat_gateway    = var.new_nat_gateway
  node_cidr_mask     = var.node_cidr_mask
  proxy_mode         = var.proxy_mode
  service_cidr       = var.service_cidr
  pod_cidr           = var.pod_cidr
  slb_internet_enabled = false
  tags = {
    "key-a" = "value-a"
    "key-b" = "value-b"
    "env"   = "dev"
  }

  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name   = lookup(addons.value, "name", var.cluster_addons)
      config = lookup(addons.value, "config", var.cluster_addons)
    }
  }
}
# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cs_kubernetes_node_pool
resource "alicloud_cs_kubernetes_node_pool" "default" {
  cluster_id     = alicloud_cs_managed_kubernetes.k8s.0.id
  instance_types = var.worker_instance_types
#  instance_types = [data.alicloud_instance_types.default.instance_types[0].id]
  name           = "tf_node_pool"
  vswitch_ids    = length(var.vswitch_ids) > 0 ? split(",", join(",", var.vswitch_ids)) : length(var.vswitch_cidrs) < 1 ? [] : split(",", join(",", alicloud_vswitch.vswitches.*.id))
  cpu_policy     = var.cpu_policy
  desired_size   = var.worker_number
  system_disk_category = "cloud_efficiency"
  install_cloud_monitor = var.install_cloud_monitor
  runtime_name = "docker"
  runtime_version = "19.03.15"
  key_name        = var.key_name
  image_id        = var.image_id
  # 公网带宽，设置internet_max_bandwidth_out > 0 可以分配一个public IP
  internet_max_bandwidth_out = 10
  security_group_ids = [alicloud_cs_managed_kubernetes.k8s[0].security_group_id]
  instance_charge_type = "PostPaid"
  internet_charge_type = "PayByTraffic"
  labels {
    key   = "app"
    value = "nginx"
  }
  taints {
    key    = "test"
    value  = "test"
    effect = "NoSchedule"
  }
  scaling_config {
    max_size = 3
    min_size = 1
  }
}
# 节点ECS实例配置
data "alicloud_instance_types" "default" {
#  availability_zone    = var.availability_zone
  cpu_core_count       = 2
  memory_size          = 4
  kubernetes_node_role = "Worker"
}

resource "alicloud_instance" "jumper" {
  key_name = var.key_name

  # 绑定安全组
  security_groups = alicloud_security_group.sg.*.id

  # 实例规格
  instance_type        = "ecs.n1.small"
  # 系统盘类型
  system_disk_category = "cloud_efficiency"
  # 自定义镜像
  image_id             = "centos_7_9_x64_20G_alibase_20220824.vhd"
#  image_id             = var.image_id
  # 实例名称
  instance_name        = "centos-jumper"
  # 所在交换机
  vswitch_id = alicloud_vswitch.vswitches[0].id
  # 公网带宽，设置internet_max_bandwidth_out > 0 可以分配一个public IP
  internet_max_bandwidth_out = 10

  instance_charge_type = "PostPaid"
  internet_charge_type = "PayByTraffic"

  user_data = file("cloud_init.sh")

  provisioner "file" {
    source      = var.key_path
    destination = "/root/.ssh/id_rsa"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /root/.ssh/id_rsa",
    ]
  }
  connection {
    type = "ssh"
    user = "root"
    password = ""
    private_key = file(var.key_path)
    host = self.public_ip
  }
}
resource "alicloud_security_group" "sg" {
  name = "jumper"
  security_group_type = "normal"
  vpc_id = alicloud_vpc.vpc[0].id
  description = "Terraform created."
}

resource "alicloud_security_group_rule" "icmp" {
  description       = "ping allowed"
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 100
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "allow_22" {
  description       = "ssh only"
  type              = "ingress"
  # tcp/udp/icmp,gre,all
  ip_protocol       = "tcp"
  # the default value is internet
  nic_type          = "intranet"
  # accept/drop
  policy            = "accept"
  # Default to "-1/-1". When the protocol is tcp or udp, each side port number range from 1 to 65535 and '-1/-1' will be invalid. For example, 1/200 means that the range of the port numbers is 1-200. Other protocols' 'port_range' can only be "-1/-1", and other values will be invalid
  port_range        = "22/22"
  priority          = 100
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "allow_internal_22" {
  description       = "internal ssh only"
  type              = "ingress"
  # tcp/udp/icmp,gre,all
  ip_protocol       = "tcp"
  # the default value is internet
  nic_type          = "intranet"
  # accept/drop
  policy            = "accept"
  # Default to "-1/-1". When the protocol is tcp or udp, each side port number range from 1 to 65535 and '-1/-1' will be invalid. For example, 1/200 means that the range of the port numbers is 1-200. Other protocols' 'port_range' can only be "-1/-1", and other values will be invalid
  port_range        = "22/22"
  priority          = 100
  security_group_id = alicloud_cs_kubernetes_node_pool.default.security_group_ids[0]
  cidr_ip           = "10.0.0.0/8"
}
resource "alicloud_log_project" "log" {
  name        = var.log_project_name
  description = "created by terraform for managed kubernetes cluster"
}