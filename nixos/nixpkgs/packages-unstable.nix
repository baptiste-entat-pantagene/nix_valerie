{ pkgs-unstable, lib, ... }:
{

  users.users.valerie.packages = with pkgs-unstable; [
    home-manager

    #vesktop # Do not work on Gnome
    discord

    # -- Browser --

    tor-browser
  ];

}
