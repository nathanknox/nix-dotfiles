# Tokyo Night (dark) — the default theme. base16 palette + metadata.
# Colors are hex WITHOUT the leading '#'; consumers add '#' or '0x' as needed.
{
  meta = {
    name = "tokyo-night";
    polarity = "dark"; # "dark" | "light" — drives GTK prefer-dark, etc.
    # Suggested wallpaper is intentionally null: static themes don't require
    # one. Set rocinante.theme.wallpaper in your host to point hyprpaper at an
    # image of your choosing.
  };

  # base16 palette
  base00 = "1a1b26"; # background
  base01 = "1f2335";
  base02 = "292e42"; # selection
  base03 = "565f89"; # comments
  base04 = "a9b1d6";
  base05 = "c0caf5"; # default foreground
  base06 = "cbd6f2";
  base07 = "d5def5";
  base08 = "f7768e"; # red
  base09 = "ff9e64"; # orange
  base0A = "e0af68"; # yellow
  base0B = "9ece6a"; # green
  base0C = "7dcfff"; # cyan
  base0D = "7aa2f7"; # blue (used as accent)
  base0E = "bb9af7"; # magenta
  base0F = "c0785b"; # brown

  # A few named roles so app modules don't hardcode base0X meanings.
  accent = "7aa2f7"; # base0D
}
