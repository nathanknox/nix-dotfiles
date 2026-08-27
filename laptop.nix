{config, pkgs, ... }:
{
  home.username = "nathan.knox";
  home.homeDirectory = "/Users/nathan.knox";

  home.packages = [
    pkgs.codex
    pkgs.cursor-cli # provides the `cursor-agent` binary
  ];
}
