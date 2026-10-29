# circuit-lastrack

You found it.

A Conn3x circuit that installs [Last Rack Standing](https://github.com/conn3xorg/lastrack), a small terminal game about keeping a rack floor alive through a bad night, on your hosts. It downloads the release binary for each host's architecture, checks it against a pinned SHA-256, and puts it at `/usr/local/bin/lastrack`. Nothing listens on the network and nothing runs until you do.

## Usage

```hcl
module "lastrack" {
  source = "github.com/conn3xorg/circuit-lastrack?ref=v0.1.0"

  hosts                = { web1 = "203.0.113.10" }
  ssh_private_key_file = "~/.ssh/id_ed25519"
}
```

Then, from a terminal at least 80 columns by 24 rows:

```sh
ssh web1 lastrack
```

Arrow keys or `hjkl` aim, space fires, `p` pauses, `q` quits. `lastrack -ascii` draws with plain characters for terminals that can't do better.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `hosts` | any | (required) | Hosts to configure: a map of names to addresses, or to host objects with an address and optional host_key, user, port, private_key_file or jump_hosts. |
| `ssh_user` | string | `"root"` | User to log in as. |
| `ssh_port` | number | `22` | SSH port. |
| `ssh_private_key_file` | string | `null` | Path to a private key. When null, Conn3x uses the SSH agent. |
| `ssh_known_hosts_file` | string | `null` | known_hosts file to check host keys against. When null, ~/.ssh/known_hosts. |
| `ssh_become` | bool | `false` | Run commands as root through sudo. |
| `lastrack_version` | string | `"0.1.0"` | Release to install, without the leading v. |
| `checksums` | map(string) | the 0.1.0 binaries | SHA-256 of the binary for each architecture, from the release's SHA256SUMS. Change these with `lastrack_version`. |

## Outputs

| Name | Description |
| --- | --- |
| `command` | What to run on each host, over SSH, to play. |

## Requirements

Conn3x v0.6.4 or later, amd64 or arm64 hosts, and outbound HTTPS to github.com.

## Tested on

Rocky Linux 10, Fedora 45, Ubuntu 24.04 and Debian 13. CI applies [examples/local](examples/local) to each, checks that the second plan has no changes, and runs `lastrack -version` on the host.

## Removing it

Drop the module and apply, and `/usr/local/bin/lastrack` goes with it. Your high score lives in `~/.local/state/lastrack` and stays too. We'd keep it.

## License

MPL-2.0. See [LICENSE](LICENSE).
