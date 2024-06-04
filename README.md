# kde-desktop-scale

## 1. Description

Bash script to scale KDE UI on X11. This script scales:

- KDE UI:
  - Display scale;
  - Font DPI;
  - Cursor size.
- Extra programs, if installed:
  - VirtualBox (VMs);
  - Remmina.

## 2. Requirements

- KDE running X11.

## 3. Installation / Update

```bash
{ curl --fail --silent https://raw.githubusercontent.com/Nikolai2038/kde-desktop-scale/main/kde-desktop-scale.sh | sudo tee /usr/bin/kde-desktop-scale; } > /dev/null && \
sudo chmod +x /usr/bin/kde-desktop-scale
```

## 4. Usage

```bash
kde-desktop-scale <percentage>
```

where `<percentage>` is from `1` to `400`.

If you are using KDE 5, set `KDE_VERSION=5` environment variable or pass it like:

```bash
KDE_VERSION=5 kde-desktop-scale <percentage>
```

I am testing this script on KDE 6, so some things need to be reviewed for KDE 5 support.

## 5. Example

Scale UI to the `150%`:

```bash
kde-desktop-scale 150
```

Return to the `100%`:

```bash
kde-desktop-scale 100
```
