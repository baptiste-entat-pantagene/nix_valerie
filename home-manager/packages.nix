{
  config,
  pkgs,
  lib,
  ...
}:
# The home.packages option allows you to install Nix packages into your
# environment.
{
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    pkgs.dotacat
    pkgs.fastfetch
    pkgs.thefuck

    (pkgs.writeShellScriptBin "fetch" (builtins.readFile ./scripts/fetch.sh))
    (pkgs.writeShellScriptBin "mktmp_pkg" (builtins.readFile ./scripts/mktmp.sh))
  ];
}
