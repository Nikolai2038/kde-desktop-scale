#!/bin/bash

# Exit on any error
set -e

function main() {
  local percents="${1:-100}" && { shift || true; }

  local panel_size
  local cursor_size
  local scale_factor
  local font_dpi
  if ((percents == 100)); then
    panel_size=44
    cursor_size=24
    scale_factor=1.0
    font_dpi=96
  elif ((percents == 150)); then
    panel_size=56
    cursor_size=36
    scale_factor=1.5
    font_dpi=144
  else
    echo "Unsupported size!" >&2
    return 1
  fi

  # Bottom panel size
  kwriteconfig5 --file plasmashellrc --group PlasmaViews --group "Panel 2" --group Defaults --key thickness "${panel_size}"

  # Display scale
  kwriteconfig5 --file kdeglobals --group KScreen --key ScaleFactor "${scale_factor}"
  kwriteconfig5 --file kdeglobals --group KScreen --key ScreensScaleFactors "VNC-0=${scale_factor}"

  # Font DPI
  kwriteconfig5 --file kcmfonts --group General --key forceFontDPI "${font_dpi}"

  # Cursor size
  sed -E "s/(Gtk\\/CursorThemeSize )[0-9]+/\\1${cursor_size}/" /home/nikolai/.config/xsettingsd/xsettingsd.conf

  # VirtualBox VMs scale (VirtualBox must be shut down)
  if [ -f "${HOME}/.config/VirtualBox/VirtualBox.xml" ]; then
    sed -Ei "s/(^.*?<ExtraDataItem name=\"GUI\\/ScaleFactor\" value=\").*?(\"\\/>\$)/\1${scale_factor}\2/" "${HOME}/.config/VirtualBox/VirtualBox.xml"
  fi

  # TODO: Not sure if it is needed
  # qdbus org.kde.KWin /KWin reconfigure

  # Restart UI
  {
    kwin --replace &
    plasmashell --replace &
  } &> /dev/null
}

main "$@"
