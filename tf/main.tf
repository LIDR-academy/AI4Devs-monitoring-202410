terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

# Configuración del proveedor de AWS
provider "aws" {
  region = "us-east-1" # Cambia a la región donde están tus instancias EC2
}

# Configuración del proveedor de Datadog
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

# Variables de entorno para las claves de Datadog
// Removing duplicate variable declarations as they are defined in variables.tf
// variable "datadog_api_key" {
//   description = "API Key para Datadog"
//   type        = string
// }
// 
// variable "datadog_app_key" {
//   description = "App Key para Datadog"
//   type        = string
// }
// 
// variable "datadog_api_url" {
//   description = "API URL for Datadog"
//   type        = string
// }

# Política de IAM para permitir a Datadog acceder a CloudWatch
resource "aws_iam_policy" "datadog_policy" {
  name        = "DatadogPolicy-jlso"
  description = "Política para permitir a Datadog acceder a CloudWatch"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues",
          "cloudtrail:LookupEvents",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:DescribeTrails",
          "health:DescribeEvents",
          "health:DescribeEventDetails",
          "health:DescribeAffectedEntities"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Obtener los nombres de las instancias EC2 automáticamente
data "aws_instances" "all" {
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# Crear un dashboard en Datadog
resource "datadog_dashboard" "ec2_dashboard" {
  title       = "EC2 Monitoring Dashboard - JLSO"
  description = "Dashboard para monitorizar instancias EC2 - Creado por JLSO"
  layout_type = "ordered"

  widget {
    group_definition {
      title = "CPU Metrics"
      layout_type = "ordered"
      widget {
        timeseries_definition {
          title = "CPU Utilization"
          request {
            q = "avg:aws.ec2.cpuutilization{*} by {instance_id}"
            display_type = "line"
          }
          yaxis {
            max = "100"
            min = "0"
            scale = "linear"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "CPU Credit Usage"
          request {
            q = "avg:aws.ec2.cpucredit_usage{*} by {instance_id}"
            display_type = "line"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "CPU Credit Balance"
          request {
            q = "avg:aws.ec2.cpucredit_balance{*} by {instance_id}"
            display_type = "line"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title = "Memory Metrics"
      layout_type = "ordered"
      widget {
        timeseries_definition {
          title = "Memory Used"
          request {
            q = "avg:system.mem.used{*} by {host}"
            display_type = "line"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "Memory Free"
          request {
            q = "avg:system.mem.free{*} by {host}"
            display_type = "line"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "Memory Usage (%)"
          request {
            q = "avg:system.mem.used{*} by {host} / avg:system.mem.total{*} by {host} * 100"
            display_type = "line"
          }
          yaxis {
            max = "100"
            min = "0"
            scale = "linear"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title = "Network Metrics"
      layout_type = "ordered"
      widget {
        timeseries_definition {
          title = "Network In"
          request {
            q = "avg:aws.ec2.network_in{*} by {instance_id}"
            display_type = "area"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "Network Out"
          request {
            q = "avg:aws.ec2.network_out{*} by {instance_id}"
            display_type = "area"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "Network Packets In/Out"
          request {
            q = "avg:aws.ec2.network_packets_in{*} by {instance_id}"
            display_type = "line"
          }
          request {
            q = "avg:aws.ec2.network_packets_out{*} by {instance_id}"
            display_type = "line"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title = "Disk Metrics"
      layout_type = "ordered"
      widget {
        timeseries_definition {
          title = "Disk Read Bytes"
          request {
            q = "avg:aws.ec2.disk_read_bytes{*} by {instance_id}"
            display_type = "area"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "Disk Write Bytes"
          request {
            q = "avg:aws.ec2.disk_write_bytes{*} by {instance_id}"
            display_type = "area"
          }
        }
      }
      widget {
        timeseries_definition {
          title = "Disk Usage (%)"
          request {
            q = "avg:system.disk.in_use{*} by {host,device} * 100"
            display_type = "line"
          }
          yaxis {
            max = "100"
            min = "0"
            scale = "linear"
          }
        }
      }
    }
  }

  widget {
    toplist_definition {
      title = "Top Instances by CPU Usage"
      request {
        q = "top(avg:aws.ec2.cpuutilization{*} by {instance_id}, 10, 'mean', 'desc')"
      }
    }
  }

  widget {
    note_definition {
      content = "Dashboard creado con Terraform para monitorizar instancias EC2 en AWS. Última actualización: ${formatdate("DD-MM-YYYY", timestamp())}"
      background_color = "gray"
      font_size = "14"
      text_align = "center"
      show_tick = true
      tick_pos = "bottom"
      tick_edge = "bottom"
    }
  }
}
