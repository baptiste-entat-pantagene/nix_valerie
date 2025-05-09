{
  pkgs-unstable,
  ...
}:
{
  environment.systemPackages = [
    pkgs-unstable.firefoxpwa
  ];

  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    nativeMessagingHosts.packages = [ pkgs-unstable.firefoxpwa ];
  };
}
