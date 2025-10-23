# RustFS NixOS Module

A comprehensive NixOS module for deploying RustFS object storage system with S3-compatible API.

## Features

- ✅ **Three Deployment Modes**: SNSD, SNMD, and MNMD
- ✅ **S3-Compatible API**: Works with any S3 client
- ✅ **Web Console**: Built-in management interface
- ✅ **TLS Support**: Encrypted communication
- ✅ **Erasure Coding**: Data protection and redundancy
- ✅ **Systemd Integration**: Proper service management
- ✅ **Security Hardening**: Runs as dedicated user with restricted permissions
- ✅ **Firewall Configuration**: Automatic port management
- ✅ **Comprehensive Logging**: Structured logging with configurable levels

## Quick Start

1. **Add the module to your configuration**:

```nix
{ config, pkgs, ... }:

{
  imports = [ ./modules/services/rustfs.nix ];
  
  services.rustfs = {
    enable = true;
    deploymentMode = "snsd";  # or "snmd", "mnmd"
    dataDir = "/data/rustfs";
    accessKey = "rustfsadmin";
    secretKey = "rustfsadmin";
    console.enable = true;
  };
}
```

2. **Rebuild your system**:

```bash
sudo nixos-rebuild switch
```

3. **Access the web console**:

Open `http://your-server:9001` in your browser.

## Files

- `rustfs.nix` - Main NixOS module
- `rustfs-example.nix` - Example configurations for all deployment modes
- `../overlays/rustfs.nix` - Package derivation for RustFS binary
- `../../docs/rustfs-module-guide.md` - Comprehensive documentation

## Deployment Modes

### Single Node Single Disk (SNSD)
- **Use case**: Testing, development
- **Requirements**: 1 server, 1 disk
- **Redundancy**: None

### Single Node Multiple Disk (SNMD)
- **Use case**: Single server with multiple disks
- **Requirements**: 1 server, 2+ disks
- **Redundancy**: Erasure coding across disks

### Multiple Node Multiple Disk (MNMD)
- **Use case**: Production clusters
- **Requirements**: 4+ servers, multiple disks per server
- **Redundancy**: Erasure coding across nodes and disks

## Configuration Examples

See `rustfs-example.nix` for detailed examples of all deployment modes and advanced configurations.

## Documentation

For complete documentation, see `../../docs/rustfs-module-guide.md`.

## Requirements

- **Filesystem**: XFS recommended for storage disks
- **Memory**: 2GB minimum, 128GB recommended for production
- **Storage**: JBOD mode (avoid NFS)
- **Network**: All nodes must use same port
- **Time Sync**: Required for multi-node deployments

## Security Notes

- Change default credentials in production
- Enable TLS for encrypted communication
- Configure firewall appropriately
- Use dedicated storage disks (not shared filesystems)

## Troubleshooting

- Check service status: `systemctl status rustfs`
- View logs: `journalctl -u rustfs -f`
- Check ports: `netstat -ntpl | grep 9000`
- Verify console: `http://your-server:9001`
