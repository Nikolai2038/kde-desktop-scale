#!/bin/bash

# Exit on any error
set -e

if [ -z "${KDE_VERSION}" ]; then
  KDE_VERSION=6
fi

KDE_PANEL_SIZE_AT_100_PERCENTS=44
KDE_CURSOR_SIZE_AT_100_PERCENTS=24
KDE_SCALE_FACTOR_AT_100_PERCENTS=1.0
KDE_FONT_DPI_AT_100_PERCENTS=96
KDE_FONT_DPI_GTK_AT_100_PERCENTS=98304

if [ -z "${MIN_PERCENTS}" ]; then
  MIN_PERCENTS=1
fi
if [ -z "${MAX_PERCENTS}" ]; then
  MAX_PERCENTS=400
fi

# Scales KDE interface and some X11 programs to the specified percents.
# KDE needs to be restarted after that.
# It is good to apply scaling before starting KDE.
function main() {
  local percents="${1}" && { shift || true; }
  if [ -z "${percents}" ]; then
    echo "Usage: kde-desktop-scale <percents>
Where percents is from ${MIN_PERCENTS} to ${MAX_PERCENTS} (%)." >&2
    return 1
  elif [ "${percents}" -lt "${MIN_PERCENTS}" ]; then
    echo "Percents must be greater or equal to ${MIN_PERCENTS}!" >&2
    return 1
  elif [ "${percents}" -gt "${MAX_PERCENTS}" ]; then
    echo "Percents must be lower or equal to ${MAX_PERCENTS}!" >&2
    return 1
  fi

  local scale_factor
  scale_factor="$(echo "${KDE_SCALE_FACTOR_AT_100_PERCENTS}" "${percents}" | awk '{ print $1 * $2 / 100; }')"
  local font_dpi
  font_dpi="$(echo "${KDE_FONT_DPI_AT_100_PERCENTS}" "${percents}" | awk '{ print int($1 * $2 / 100); }')"
  local font_dpi_gtk
  font_dpi_gtk="$(echo "${KDE_FONT_DPI_GTK_AT_100_PERCENTS}" "${percents}" | awk '{ print int($1 * $2 / 100); }')"
  local panel_size
  panel_size="$(echo "${KDE_PANEL_SIZE_AT_100_PERCENTS}" "${percents}" | awk '{ print int($1 * $2 / 100); }')"
  local cursor_size
  cursor_size="$(echo "${KDE_CURSOR_SIZE_AT_100_PERCENTS}" "${percents}" | awk '{ print int($1 * $2 / 100); }')"

  echo "Calculated values for ${percents}%:
- scale_factor = ${scale_factor}
- font_dpi = ${font_dpi}
- font_dpi_gtk = ${font_dpi_gtk}
- panel_size = ${panel_size}
- cursor_size = ${cursor_size}"

  # Display scale
  "kwriteconfig${KDE_VERSION}" --file kdeglobals --group KScreen --key ScaleFactor "${scale_factor}"
  # For RDP and VNC connections
  "kreadconfig${KDE_VERSION}" --file kdeglobals --group KScreen --key ScreensScaleFactors "rdp0=${scale_factor};rdp1=${scale_factor};rdp2=${scale_factor};rdp3=${scale_factor};VNC-0=${scale_factor};VNC-1=${scale_factor};VNC-2=${scale_factor};VNC-3=${scale_factor}"

  # Font DPI
  "kwriteconfig${KDE_VERSION}" --file kcmfonts --group General --key forceFontDPI "${font_dpi}"
  if [ -f "${HOME}/.config/xsettingsd/xsettingsd.conf" ]; then
    sed -Ei "s/(^Gtk\\/UnscaledDPI )[0-9]+\$/\\1${font_dpi_gtk}/" "${HOME}/.config/xsettingsd/xsettingsd.conf"
  fi
  if [ -f "${HOME}/.config/gtk-3.0/settings.ini" ]; then
    sed -Ei "s/(^gtk-xft-dpi=)[0-9]+\$/\\1${font_dpi_gtk}/" "${HOME}/.config/gtk-3.0/settings.ini"
  fi
  if [ -f "${HOME}/.config/gtk-4.0/settings.ini" ]; then
    sed -Ei "s/(^gtk-xft-dpi=)[0-9]+\$/\\1${font_dpi_gtk}/" "${HOME}/.config/gtk-4.0/settings.ini"
  fi

  # Bottom panel size
  "kwriteconfig${KDE_VERSION}" --file plasmashellrc --group PlasmaViews --group "Panel 2" --group Defaults --key thickness "${panel_size}"

  # Cursor size
  if [ -f "${HOME}/.config/xsettingsd/xsettingsd.conf" ]; then
    sed -Ei "s/(^Gtk\\/CursorThemeSize )[0-9]+\$/\\1${cursor_size}/" "${HOME}/.config/xsettingsd/xsettingsd.conf"
  fi

  # VirtualBox VMs scale (VirtualBox must be shut down before)
  if [ -f "${HOME}/.config/VirtualBox/VirtualBox.xml" ]; then
    sed -Ei "s/(^.*?<ExtraDataItem name=\"GUI\\/ScaleFactor\" value=\").*?(\"\\/>\$)/\1${scale_factor}\2/" "${HOME}/.config/VirtualBox/VirtualBox.xml"
  fi

  # Remmina clients scale
  if [ -f "${HOME}/.config/remmina/remmina.pref" ]; then
    sed -Ei "s/(^rdp_desktopScaleFactor=)[0-9]+\$/\\1${percents}/" "${HOME}/.config/remmina/remmina.pref"
  fi

  # Restart UI
  {
    kwin --replace &
    plasmashell --replace &
  } &> /dev/null

  echo "Success!"
  echo "Now you need to relogin to your account to apply changes!"
  return 0
}

main "$@"
