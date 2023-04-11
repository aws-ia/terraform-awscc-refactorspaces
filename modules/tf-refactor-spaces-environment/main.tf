/*
    AWS Migration Hub Refactor Spaces : Environment
    Create a AWS Migration Hub Refactor Spaces Environment
*/
resource "awscc_refactorspaces_environment" "current" {
  name                = var.environment_name
  description         = var.environment_description
  network_fabric_type = var.provision_network_bridge ? "TRANSIT_GATEWAY" : "NONE"
  tags = [
    for tag_key, tag_value in local.tags : {
      key   = tag_key
      value = tag_value
    }
  ]

  lifecycle {
    # Tags can not be updated (throws update error for the resource)
    ignore_changes = [
      tags
    ]
  }
}

/*
    AWS Resource Access Manager Share : Environment
    Creates a AWS Resource Access Manager (RAM) share for the environment and associate it with the provided list of principals
*/
resource "aws_ram_resource_share" "refactor_spaces_environment" {
  name                      = var.environment_name
  allow_external_principals = true

  tags = merge(
    local.tags,
  )
}

resource "aws_ram_resource_association" "refactor_spaces_environment" {
  resource_arn       = awscc_refactorspaces_environment.current.arn
  resource_share_arn = aws_ram_resource_share.refactor_spaces_environment.arn
}

resource "aws_ram_principal_association" "refactor_spaces_environment" {
  for_each = toset(var.shared_to_principals)

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.refactor_spaces_environment.arn
}

