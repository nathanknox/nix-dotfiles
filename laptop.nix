{config, pkgs, ... }:
{
  home.username = "nathan.knox";
  home.homeDirectory = "/Users/nathan.knox";

  home.packages = with pkgs; [
    codex
    cursor-cli # provides the `cursor-agent` binary
  ];
}
