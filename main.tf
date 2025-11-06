data "alicloud_cloud_sso_directories" "default" {}

locals {
  groups_flatten = flatten([
    for group in var.groups : [
      for user in group.users :
      {
        user  = user
        group = group.group_name
      }
    ]
  ])
  directory_id = try(data.alicloud_cloud_sso_directories.default.directories[0].id, "")
}

resource "alicloud_cloud_sso_user" "default" {
  for_each     = { for user in var.users : user.user_name => user }
  directory_id = local.directory_id

  user_name    = each.key
  display_name = lookup(each.value, "display_name", null)
  email        = lookup(each.value, "email", null)
  first_name   = lookup(each.value, "first_name", null)
  last_name    = lookup(each.value, "last_name", null)
  status       = lookup(each.value, "status", "Enabled")
  description  = lookup(each.value, "description", null)
}

resource "alicloud_cloud_sso_group" "default" {
  for_each     = { for group in var.groups : group.group_name => group }
  directory_id = local.directory_id

  group_name  = each.key
  description = lookup(each.value, "description", null)
}

resource "alicloud_cloud_sso_user_attachment" "default" {
  for_each     = { for group in local.groups_flatten : "${group.group}-${group.user}" => group }
  directory_id = local.directory_id

  group_id = alicloud_cloud_sso_group.default[each.value.group].group_id
  user_id  = alicloud_cloud_sso_user.default[each.value.user].user_id
}