{config, pkgs, ...}:
{
  home.username = "nknox";
  home.homeDirectory = "/home/nknox";
  home.packages = [
    pkgs.libgcc
  ];
}
