# Facts give each host's architecture, which picks the release binary.
data "conn3x_host" "facts" {
  for_each = var.hosts

  ssh {
    host             = try(each.value.address, each.value)
    host_key         = try(each.value.host_key, null)
    user             = try(each.value.user, var.ssh_user)
    port             = try(each.value.port, var.ssh_port)
    private_key_file = try(each.value.private_key_file, var.ssh_private_key_file)
    jump_hosts       = try(each.value.jump_hosts, null)
    known_hosts_file = var.ssh_known_hosts_file
  }
}

locals {
  goarch = { x86_64 = "amd64", aarch64 = "arm64" }
  arch   = { for name, f in data.conn3x_host.facts : name => local.goarch[f.arch] }
}

circuit "lastrack" {
  hosts = var.hosts

  ssh {
    user             = var.ssh_user
    port             = var.ssh_port
    private_key_file = var.ssh_private_key_file
    known_hosts_file = var.ssh_known_hosts_file
    become           = var.ssh_become
  }

  # Minimal images can lack it.
  step "curl" {
    package {
      name = "curl"
    }
  }

  step "binary" {
    download {
      url       = "https://github.com/conn3xorg/lastrack/releases/download/v${var.lastrack_version}/lastrack_linux_${local.arch[each.key]}"
      sha256    = var.checksums[local.arch[each.key]]
      dest      = "/usr/local/bin/lastrack"
      mode      = "0755"
      on_remove = "delete"
    }
  }
}
