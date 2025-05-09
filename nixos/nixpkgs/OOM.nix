{
  inputs,
  lib,
  config,
  outputs,
  ...
}:
{
  # OOM configuration:

  # Slice to limit CPU and memory hogs
  # DOCS https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html
  # DOCS https://discourse.nixos.org/t/nix-build-ate-my-ram/35752?u=yajo
  systemd.slices.anti-hungry.sliceConfig = {
    CPUAccounting = true;
    CPUQuota = "70%";
    MemoryAccounting = true; # Allow to control with systemd-cgtop
    MemoryHigh = "50%";
    MemoryMax = "75%";
  };

  systemd.services.nix-daemon.serviceConfig.Slice = "anti-hungry.slice";

  # Avoid freezing the system
  services.earlyoom = {
    enable = true;
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };

  # Garbage collection
  boot.loader.systemd-boot.configurationLimit = 50;
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 30d";

}
