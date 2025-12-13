# nix-loongarch-kernel

Linux 6.17 内核，为 LoongArch 平台打了额外的 patch。

## Patches

- Motorcomm YT6801 网卡驱动（来自 Deepin）

## 使用

在 NixOS 配置中：

```nix
{
  inputs.nix-loongarch-kernel.url = "github:darkyzhou/nix-loongarch-kernel";

  outputs = { self, nixpkgs, nix-loongarch-kernel, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "loongarch64-linux";
      modules = [
        {
          nixpkgs.overlays = [ nix-loongarch-kernel.overlay ];
          boot.kernelPackages = pkgs.linuxPackages-nix4loong;
        }
      ];
    };
  };
}
```

## 构建

```bash
nix build .#kernel
```

