/*
output "user_ids" {
  description = "The User ID list of the users."
  value = [
    for user in alicloud_cloud_sso_user.default : user.user_id
  ]
}

output "group_ids" {
  description = "The Group ID list of the group"
  value = [
    for group in alicloud_cloud_sso_group.default : group.group_id
  ]
}

output "user_attachment_ids" {
  description = "The resource ID of User Attachment. The value formats as <directory_id>:<group_id>:<user_id>"
  value = [
    for attachment in alicloud_cloud_sso_user_attachment.default : attachment.id
  ]
}
*/

output "user_ids" {
  description = "List of created user IDs"
  value = [
    for user in alicloud_cloud_sso_user.default : user.user_id
  ]
}

output "user_details" {
  description = "Complete user details including metadata"
  value = {
    for user_name, user in alicloud_cloud_sso_user.default :
    user_name => {
      user_id      = user.user_id
      user_name    = user.user_name
      display_name = user.display_name
      email        = user.email
      first_name   = user.first_name
      last_name    = user.last_name
      status       = user.status
      description  = user.description
    }
  }
  sensitive = true
}

output "group_ids" {
  description = "List of created group IDs"
  value = [
    for group in alicloud_cloud_sso_group.default : group.group_id
  ]
}

output "group_details" {
  description = "Complete group details including membership"
  value = {
    for group_name, group in alicloud_cloud_sso_group.default :
    group_name => {
      group_id    = group.group_id
      group_name  = group.group_name
      description = group.description
      member_count = length([
        for attachment_key, attachment in alicloud_cloud_sso_user_attachment.default :
        attachment if attachment.group_id == group.group_id
      ])
      members = [
        for attachment_key, attachment in alicloud_cloud_sso_user_attachment.default :
        split("-", attachment_key)[1]
        if attachment.group_id == group.group_id
      ]
    }
  }
}

output "user_attachment_ids" {
  description = "List of user attachment IDs with format <directory_id>:<group_id>:<user_id>"
  value = [
    for attachment in alicloud_cloud_sso_user_attachment.default : attachment.id
  ]
}

output "user_group_memberships" {
  description = "User to groups mapping"
  value = {
    for user_name in keys(alicloud_cloud_sso_user.default) :
    user_name => [
      for attachment_key, attachment in alicloud_cloud_sso_user_attachment.default :
      split("-", attachment_key)[0]
      if split("-", attachment_key)[1] == user_name
    ]
  }
}

output "group_membership_summary" {
  description = "Summary of group memberships"
  value = {
    total_groups      = length(alicloud_cloud_sso_group.default)
    total_users       = length(alicloud_cloud_sso_user.default)
    total_memberships = length(alicloud_cloud_sso_user_attachment.default)
    groups_with_members = length([
      for group_name, group_config in var.groups :
      group_name if length(group_config.users) > 0
    ])
  }
}