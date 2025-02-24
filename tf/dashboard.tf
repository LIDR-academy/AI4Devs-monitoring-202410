resource "datadog_dashboard" "ec2_monitoring" {
  title       = "EC2 Monitoring Dashboard"
  description = "Dashboard para monitorizar instancias EC2"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "CPU Utilization por Instancia"
      request {
        query {
          metric_query {
            name = "cpu_usage"
            query = "avg:system.cpu.user{*} by {host}"
          }
        }
        style {
          line_type  = "solid"
          line_width = "normal"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Memoria Utilizada por Instancia"
      request {
        query {
          metric_query {
            name = "memory_usage"
            query = "avg:system.mem.used{*} by {host}"
          }
        }
        style {
          line_type  = "solid"
          line_width = "normal"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Network In/Out por Instancia"
      request {
        formula {
          formula_expression = "bytes_in + bytes_out"
        }
        query {
          metric_query {
            name = "bytes_in"
            query = "avg:system.net.bytes_rcvd{*} by {host}.as_rate()"
          }
        }
        query {
          metric_query {
            name = "bytes_out"
            query = "avg:system.net.bytes_sent{*} by {host}.as_rate()"
          }
        }
        style {
          line_type  = "solid"
          line_width = "normal"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "EC2 Status Checks"
      request {
        query {
          metric_query {
            name = "status_checks"
            query = "avg:aws.ec2.status_check_failed{*} by {instance_id}"
          }
        }
        style {
          line_type  = "solid"
          line_width = "normal"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "EBS Volume Read/Write Ops"
      request {
        formula {
          formula_expression = "reads + writes"
        }
        query {
          metric_query {
            name = "reads"
            query = "avg:aws.ebs.read_ops{*} by {volume_id}"
          }
        }
        query {
          metric_query {
            name = "writes"
            query = "avg:aws.ebs.write_ops{*} by {volume_id}"
          }
        }
        style {
          line_type  = "solid"
          line_width = "normal"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Docker Container Stats"
      request {
        formula {
          formula_expression = "cpu + memory"
        }
        query {
          metric_query {
            name = "cpu"
            query = "avg:docker.cpu.usage{*} by {container_name}"
          }
        }
        query {
          metric_query {
            name = "memory"
            query = "avg:docker.mem.in_use{*} by {container_name}"
          }
        }
        style {
          line_type  = "solid"
          line_width = "normal"
        }
      }
    }
  }
}

