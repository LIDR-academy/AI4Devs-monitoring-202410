resource "datadog_dashboard" "aws_dashboard" {
  title       = "AWS Infrastructure Dashboard"
  description = "Dashboard para monitorizar métricas clave de AWS"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "Utilización de CPU"
      request {
        q = "avg:aws.ec2.cpuutilization{*} by {instance_id}"
        display_type = "line"
      }
      yaxis {
        scale = "linear"
        include_zero = true
        label = "Percentage"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Red - Tráfico Entrante"
      request {
        q = "avg:aws.ec2.network_in{*} by {instance_id}"
        display_type = "line"
      }
      yaxis {
        scale = "linear"
        include_zero = true
        label = "Bytes"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Red - Tráfico Saliente"
      request {
        q = "avg:aws.ec2.network_out{*} by {instance_id}"
        display_type = "line"
      }
      yaxis {
        scale = "linear"
        include_zero = true
        label = "Bytes"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Lecturas de Disco"
      request {
        q = "avg:aws.ec2.disk_read_bytes{*} by {instance_id}"
        display_type = "line"
      }
      yaxis {
        scale = "linear"
        include_zero = true
        label = "Bytes"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Escrituras de Disco"
      request {
        q = "avg:aws.ec2.disk_write_bytes{*} by {instance_id}"
        display_type = "line"
      }
      yaxis {
        scale = "linear"
        include_zero = true
        label = "Bytes"
      }
    }
  }
}