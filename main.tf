resource "google_compute_instance_group_manager" "compute_instance_group_managers" {
  for_each = var.compute_instance_group_managers

  base_instance_name             = each.value.base_instance_name
  name                           = each.value.name
  deletion_policy                = each.value.deletion_policy
  description                    = each.value.description
  list_managed_instances_results = each.value.list_managed_instances_results
  project                        = each.value.project
  target_pools                   = each.value.target_pools
  target_size                    = each.value.target_size
  target_stopped_size            = each.value.target_stopped_size
  target_suspended_size          = each.value.target_suspended_size
  wait_for_instances             = each.value.wait_for_instances
  wait_for_instances_status      = each.value.wait_for_instances_status
  zone                           = each.value.zone

  dynamic "version" {
    for_each = each.value.version
    content {
      instance_template = version.value.instance_template
      name              = version.value.name
      dynamic "target_size" {
        for_each = version.value.target_size != null ? [version.value.target_size] : []
        content {
          fixed   = target_size.value.fixed
          percent = target_size.value.percent
        }
      }
    }
  }

  dynamic "all_instances_config" {
    for_each = each.value.all_instances_config != null ? [each.value.all_instances_config] : []
    content {
      labels   = all_instances_config.value.labels
      metadata = all_instances_config.value.metadata
    }
  }

  dynamic "auto_healing_policies" {
    for_each = each.value.auto_healing_policies != null ? [each.value.auto_healing_policies] : []
    content {
      health_check      = auto_healing_policies.value.health_check
      initial_delay_sec = auto_healing_policies.value.initial_delay_sec
    }
  }

  dynamic "instance_lifecycle_policy" {
    for_each = each.value.instance_lifecycle_policy != null ? [each.value.instance_lifecycle_policy] : []
    content {
      default_action_on_failure = instance_lifecycle_policy.value.default_action_on_failure
      force_update_on_repair    = instance_lifecycle_policy.value.force_update_on_repair
      on_failed_health_check    = instance_lifecycle_policy.value.on_failed_health_check
      dynamic "on_repair" {
        for_each = instance_lifecycle_policy.value.on_repair != null ? [instance_lifecycle_policy.value.on_repair] : []
        content {
          allow_changing_zone = on_repair.value.allow_changing_zone
        }
      }
    }
  }

  dynamic "named_port" {
    for_each = each.value.named_port != null ? each.value.named_port : []
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  dynamic "resource_policies" {
    for_each = each.value.resource_policies != null ? [each.value.resource_policies] : []
    content {
      workload_policy = resource_policies.value.workload_policy
    }
  }

  dynamic "standby_policy" {
    for_each = each.value.standby_policy != null ? [each.value.standby_policy] : []
    content {
      initial_delay_sec = standby_policy.value.initial_delay_sec
      mode              = standby_policy.value.mode
    }
  }

  dynamic "stateful_disk" {
    for_each = each.value.stateful_disk != null ? each.value.stateful_disk : []
    content {
      delete_rule = stateful_disk.value.delete_rule
      device_name = stateful_disk.value.device_name
    }
  }

  dynamic "stateful_external_ip" {
    for_each = each.value.stateful_external_ip != null ? each.value.stateful_external_ip : []
    content {
      delete_rule    = stateful_external_ip.value.delete_rule
      interface_name = stateful_external_ip.value.interface_name
    }
  }

  dynamic "stateful_internal_ip" {
    for_each = each.value.stateful_internal_ip != null ? each.value.stateful_internal_ip : []
    content {
      delete_rule    = stateful_internal_ip.value.delete_rule
      interface_name = stateful_internal_ip.value.interface_name
    }
  }

  dynamic "target_size_policy" {
    for_each = each.value.target_size_policy != null ? each.value.target_size_policy : []
    content {
      mode = target_size_policy.value.mode
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }

  dynamic "update_policy" {
    for_each = each.value.update_policy != null ? [each.value.update_policy] : []
    content {
      max_surge_fixed                = update_policy.value.max_surge_fixed
      max_surge_percent              = update_policy.value.max_surge_percent
      max_unavailable_fixed          = update_policy.value.max_unavailable_fixed
      max_unavailable_percent        = update_policy.value.max_unavailable_percent
      minimal_action                 = update_policy.value.minimal_action
      most_disruptive_allowed_action = update_policy.value.most_disruptive_allowed_action
      replacement_method             = update_policy.value.replacement_method
      type                           = update_policy.value.type
    }
  }
}

