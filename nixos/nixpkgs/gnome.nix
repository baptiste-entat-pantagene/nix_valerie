{
  pkgs,
  ...
}:
{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xkb = {
      layout = "fr";
      variant = "oss_nodeadkeys";
    };

  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-panel
    gnomeExtensions.clipboard-indicator
  ];

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  services.udev.packages = [ pkgs.gnome-settings-daemon ];
}
