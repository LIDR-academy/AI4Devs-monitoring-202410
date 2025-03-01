# Monitores de Datadog para alertas

# Monitor para CPU alto en instancias EC2
resource "datadog_monitor" "high_cpu" {
  name               = "Alta utilización de CPU en instancias EC2 - JLSO"
  type               = "metric alert"
  message            = <<EOT
La utilización de CPU está por encima del 80% durante más de 5 minutos.

@slack-${var.notification_slack}
@email-${var.notification_email}
EOT
  query              = "avg(last_5m):avg:aws.ec2.cpuutilization{*} by {instance_id} > 80"
  monitor_thresholds {
    critical = 80
    warning  = 70
  }
  notify_no_data    = false
  require_full_window = false
  include_tags      = true
  evaluation_delay  = 60
  new_group_delay   = 300
  renotify_interval = 60
  
  tags = ["service:ec2", "team:${var.team}", "env:${var.environment}", "application:${var.application}", "managed-by:terraform"]
}

# Monitor para memoria alta en instancias EC2
resource "datadog_monitor" "high_memory" {
  name               = "Alta utilización de memoria en instancias EC2 - JLSO"
  type               = "metric alert"
  message            = <<EOT
La utilización de memoria está por encima del 85% durante más de 5 minutos.

@slack-${var.notification_slack}
@email-${var.notification_email}
EOT
  query              = "avg(last_5m):avg:system.mem.used{*} by {host} / avg:system.mem.total{*} by {host} * 100 > 85"
  monitor_thresholds {
    critical = 85
    warning  = 75
  }
  notify_no_data    = false
  require_full_window = false
  include_tags      = true
  evaluation_delay  = 60
  new_group_delay   = 300
  renotify_interval = 60
  
  tags = ["service:ec2", "team:${var.team}", "env:${var.environment}", "application:${var.application}", "managed-by:terraform"]
}

# Monitor para espacio en disco alto en instancias EC2
resource "datadog_monitor" "high_disk" {
  name               = "Alto uso de disco en instancias EC2 - JLSO"
  type               = "metric alert"
  message            = <<EOT
El uso de disco está por encima del 85% durante más de 10 minutos.

@slack-${var.notification_slack}
@email-${var.notification_email}
EOT
  query              = "avg(last_10m):avg:system.disk.in_use{*} by {host,device} * 100 > 85"
  monitor_thresholds {
    critical = 85
    warning  = 75
  }
  notify_no_data    = false
  require_full_window = false
  include_tags      = true
  evaluation_delay  = 60
  new_group_delay   = 300
  renotify_interval = 60
  
  tags = ["service:ec2", "team:${var.team}", "env:${var.environment}", "application:${var.application}", "managed-by:terraform"]
}

# Monitor para instancias EC2 no disponibles
resource "datadog_monitor" "ec2_status_check" {
  name               = "Instancia EC2 no disponible - JLSO"
  type               = "metric alert"
  message            = <<EOT
La instancia EC2 no está pasando los status checks durante más de 5 minutos.

@slack-${var.notification_slack}
@email-${var.notification_email}
EOT
  query              = "min(last_5m):avg:aws.ec2.status_check_failed{*} by {instance_id} > 0"
  monitor_thresholds {
    critical = 0
  }
  notify_no_data    = true
  no_data_timeframe = 10
  require_full_window = false
  include_tags      = true
  evaluation_delay  = 60
  new_group_delay   = 300
  renotify_interval = 30
  
  tags = ["service:ec2", "team:${var.team}", "env:${var.environment}", "application:${var.application}", "managed-by:terraform"]
}

# Monitor para errores en logs de aplicación - Comentado temporalmente debido a problemas de validación
/*
resource "datadog_monitor" "application_errors" {
  name               = "Errores en logs de aplicación - JLSO"
  type               = "log alert"
  message            = <<EOT
Se han detectado muchos errores en los logs de la aplicación.

@slack-${var.notification_slack}
@email-${var.notification_email}
EOT
  query              = "logs(\"status:error OR level:error\").index(\"*\").count() > 10"
  monitor_thresholds {
    critical = 10
    warning  = 5
  }
  notify_no_data    = false
  require_full_window = false
  include_tags      = true
  
  tags = ["service:application", "team:${var.team}", "env:${var.environment}", "application:${var.application}", "managed-by:terraform"]
}
*/ 