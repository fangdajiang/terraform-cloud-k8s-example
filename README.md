## Use Terraform to create K8s on mainstream cloud platforms.

| Platform             | Platform Version | Terraform Version |
|----------------------|:----------------:|:-----------------:|
| AliCloud Managed Pro | 1.185.0          |      >= 0.12      |
| AliCloud Dedicated   | N/A              |        N/A        |
| Azure                | N/A              |        N/A        |
| AWS                  | N/A              |        N/A        |

### Prerequisite Variables

|        Name         | Position        | Remarks                                                |
|:-------------------:|-----------------|--------------------------------------------------------|
|       id_rsa        | ~/.ssh/         | for SSH login from local                               |
| ALICLOUD_ACCESS_KEY | Env or Var file | [create one](https://ram.console.aliyun.com/manage/ak) |
| ALICLOUD_SECRET_KEY | Env or Var file | ref: ↑                                                 |
|   ALICLOUD_REGION   | Env or Var file | ex: cn-shanghai                                        |
|      image_id       | Var file        | if you want to use customized image                    |
|      key_name       | Var file        | optional                                               |
|      key_path       | Var file        | ex: ~/.ssh/id_rsa                                      |

### Results

| Item          | value                                 |
|---------------|---------------------------------------|
| VPC CIDR      | 10.0.0.0/8                            |
| VSwitch CIDRs | 10.1.0.0/16  10.2.0.0/16  10.3.0.0/16 |


