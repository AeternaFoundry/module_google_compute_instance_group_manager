variable "compute_instance_group_managers" {
  description = <<EOT
Map of compute_instance_group_managers, attributes below
Required:
    - base_instance_name
    - name
    - version (block):
        - instance_template (required)
        - name (optional)
        - target_size (optional, block):
            - fixed (optional)
            - percent (optional)
Optional:
    - deletion_policy
    - description
    - list_managed_instances_results
    - project
    - target_pools
    - target_size
    - target_stopped_size
    - target_suspended_size
    - wait_for_instances
    - wait_for_instances_status
    - zone
    - all_instances_config (block):
        - labels (optional)
        - metadata (optional)
    - auto_healing_policies (block):
        - health_check (required)
        - initial_delay_sec (required)
    - instance_lifecycle_policy (block):
        - default_action_on_failure (optional)
        - force_update_on_repair (optional)
        - on_failed_health_check (optional)
        - on_repair (optional, block):
            - allow_changing_zone (optional)
    - named_port (block):
        - name (required)
        - port (required)
    - resource_policies (block):
        - workload_policy (optional)
    - standby_policy (block):
        - initial_delay_sec (optional)
        - mode (optional)
    - stateful_disk (block):
        - delete_rule (optional)
        - device_name (required)
    - stateful_external_ip (block):
        - delete_rule (optional)
        - interface_name (optional)
    - stateful_internal_ip (block):
        - delete_rule (optional)
        - interface_name (optional)
    - target_size_policy (block):
        - mode (required)
    - timeouts (block):
        - create (optional)
        - delete (optional)
        - update (optional)
    - update_policy (block):
        - max_surge_fixed (optional)
        - max_surge_percent (optional)
        - max_unavailable_fixed (optional)
        - max_unavailable_percent (optional)
        - minimal_action (required)
        - most_disruptive_allowed_action (optional)
        - replacement_method (optional)
        - type (required)
EOT

  type = map(object({
    base_instance_name             = string
    name                           = string
    deletion_policy                = optional(string)
    description                    = optional(string)
    list_managed_instances_results = optional(string)
    project                        = optional(string)
    target_pools                   = optional(set(string))
    target_size                    = optional(number)
    target_stopped_size            = optional(number)
    target_suspended_size          = optional(number)
    wait_for_instances             = optional(bool)
    wait_for_instances_status      = optional(string)
    zone                           = optional(string)
    version = list(object({
      instance_template = string
      name              = optional(string)
      target_size = optional(object({
        fixed   = optional(number)
        percent = optional(number)
      }))
    }))
    all_instances_config = optional(object({
      labels   = optional(map(string))
      metadata = optional(map(string))
    }))
    auto_healing_policies = optional(object({
      health_check      = string
      initial_delay_sec = number
    }))
    instance_lifecycle_policy = optional(object({
      default_action_on_failure = optional(string)
      force_update_on_repair    = optional(string)
      on_failed_health_check    = optional(string)
      on_repair = optional(object({
        allow_changing_zone = optional(string)
      }))
    }))
    named_port = optional(list(object({
      name = string
      port = number
    })))
    resource_policies = optional(object({
      workload_policy = optional(string)
    }))
    standby_policy = optional(object({
      initial_delay_sec = optional(number)
      mode              = optional(string)
    }))
    stateful_disk = optional(list(object({
      delete_rule = optional(string)
      device_name = string
    })))
    stateful_external_ip = optional(list(object({
      delete_rule    = optional(string)
      interface_name = optional(string)
    })))
    stateful_internal_ip = optional(list(object({
      delete_rule    = optional(string)
      interface_name = optional(string)
    })))
    target_size_policy = optional(list(object({
      mode = string
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    update_policy = optional(object({
      max_surge_fixed                = optional(number)
      max_surge_percent              = optional(number)
      max_unavailable_fixed          = optional(number)
      max_unavailable_percent        = optional(number)
      minimal_action                 = string
      most_disruptive_allowed_action = optional(string)
      replacement_method             = optional(string)
      type                           = string
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        length(v.version) >= 1
      )
    ])
    error_message = "Each version list must contain at least 1 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        alltrue([for item in v.version : (item.target_size == null || (item.target_size.percent == null || (item.target_size.percent >= 0 && item.target_size.percent <= 100)))])
      )
    ])
    error_message = "must be between 0 and 100"
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.list_managed_instances_results == null || (contains(["PAGELESS", "PAGINATED"], v.list_managed_instances_results))
      )
    ])
    error_message = "must be one of: \"PAGELESS\", \"PAGINATED\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.auto_healing_policies == null || (v.auto_healing_policies.initial_delay_sec >= 0 && v.auto_healing_policies.initial_delay_sec <= 3600)
      )
    ])
    error_message = "must be between 0 and 3600"
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.standby_policy == null || (v.standby_policy.initial_delay_sec == null || (v.standby_policy.initial_delay_sec >= 0 && v.standby_policy.initial_delay_sec <= 3600))
      )
    ])
    error_message = "must be between 0 and 3600"
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.standby_policy == null || (v.standby_policy.mode == null || (contains([for v in ["MANUAL", "SCALE_OUT_POOL"] : lower(v)], lower(v.standby_policy.mode))))
      )
    ])
    error_message = "must be one of: \"MANUAL\", \"SCALE_OUT_POOL\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.update_policy == null || (contains(["NONE", "REFRESH", "RESTART", "REPLACE"], v.update_policy.minimal_action))
      )
    ])
    error_message = "must be one of: \"NONE\", \"REFRESH\", \"RESTART\", \"REPLACE\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.update_policy == null || (v.update_policy.most_disruptive_allowed_action == null || (contains(["NONE", "REFRESH", "RESTART", "REPLACE"], v.update_policy.most_disruptive_allowed_action)))
      )
    ])
    error_message = "must be one of: \"NONE\", \"REFRESH\", \"RESTART\", \"REPLACE\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.update_policy == null || (contains(["OPPORTUNISTIC", "PROACTIVE"], v.update_policy.type))
      )
    ])
    error_message = "must be one of: \"OPPORTUNISTIC\", \"PROACTIVE\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.update_policy == null || (v.update_policy.max_surge_percent == null || (v.update_policy.max_surge_percent >= 0 && v.update_policy.max_surge_percent <= 100))
      )
    ])
    error_message = "must be between 0 and 100"
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.update_policy == null || (v.update_policy.max_unavailable_percent == null || (v.update_policy.max_unavailable_percent >= 0 && v.update_policy.max_unavailable_percent <= 100))
      )
    ])
    error_message = "must be between 0 and 100"
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.update_policy == null || (v.update_policy.replacement_method == null || (contains(["RECREATE", "SUBSTITUTE", ""], v.update_policy.replacement_method)))
      )
    ])
    error_message = "must be one of: \"RECREATE\", \"SUBSTITUTE\", \"\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.instance_lifecycle_policy == null || (v.instance_lifecycle_policy.default_action_on_failure == null || (contains([for v in ["REPAIR", "DO_NOTHING"] : lower(v)], lower(v.instance_lifecycle_policy.default_action_on_failure))))
      )
    ])
    error_message = "must be one of: \"REPAIR\", \"DO_NOTHING\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.instance_lifecycle_policy == null || (v.instance_lifecycle_policy.on_failed_health_check == null || (contains([for v in ["DEFAULT_ACTION", "REPAIR", "DO_NOTHING"] : lower(v)], lower(v.instance_lifecycle_policy.on_failed_health_check))))
      )
    ])
    error_message = "must be one of: \"DEFAULT_ACTION\", \"REPAIR\", \"DO_NOTHING\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.instance_lifecycle_policy == null || (v.instance_lifecycle_policy.force_update_on_repair == null || (contains([for v in ["YES", "NO"] : lower(v)], lower(v.instance_lifecycle_policy.force_update_on_repair))))
      )
    ])
    error_message = "must be one of: \"YES\", \"NO\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.instance_lifecycle_policy == null || (v.instance_lifecycle_policy.on_repair == null || (v.instance_lifecycle_policy.on_repair.allow_changing_zone == null || (contains([for v in ["YES", "NO"] : lower(v)], lower(v.instance_lifecycle_policy.on_repair.allow_changing_zone)))))
      )
    ])
    error_message = "must be one of: \"YES\", \"NO\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.wait_for_instances_status == null || (contains(["STABLE", "UPDATED"], v.wait_for_instances_status))
      )
    ])
    error_message = "must be one of: \"STABLE\", \"UPDATED\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.stateful_internal_ip == null || alltrue([for item in v.stateful_internal_ip : (item.delete_rule == null || (contains([for v in ["NEVER", "ON_PERMANENT_INSTANCE_DELETION"] : lower(v)], lower(item.delete_rule))))])
      )
    ])
    error_message = "must be one of: \"NEVER\", \"ON_PERMANENT_INSTANCE_DELETION\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.stateful_external_ip == null || alltrue([for item in v.stateful_external_ip : (item.delete_rule == null || (contains([for v in ["NEVER", "ON_PERMANENT_INSTANCE_DELETION"] : lower(v)], lower(item.delete_rule))))])
      )
    ])
    error_message = "must be one of: \"NEVER\", \"ON_PERMANENT_INSTANCE_DELETION\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.stateful_disk == null || alltrue([for item in v.stateful_disk : (item.delete_rule == null || (contains([for v in ["NEVER", "ON_PERMANENT_INSTANCE_DELETION"] : lower(v)], lower(item.delete_rule))))])
      )
    ])
    error_message = "must be one of: \"NEVER\", \"ON_PERMANENT_INSTANCE_DELETION\""
  }
  validation {
    condition = alltrue([
      for k, v in var.compute_instance_group_managers : (
        v.target_size_policy == null || alltrue([for item in v.target_size_policy : (contains(["BULK", "INDIVIDUAL"], item.mode))])
      )
    ])
    error_message = "must be one of: \"BULK\", \"INDIVIDUAL\""
  }
}

