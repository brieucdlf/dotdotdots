# dotdotdots
:warning: Dots not ready !

### Some details

---

- Labtops: XPS 13 7390 (late 2019) | Macbook Pro tb (early 2017)
- OS: Arch
- WM: i3-gaps
- Terminals: urxvt | Termite
- File Manager: Thunar
- Launcher: Rofi
- Editors: Vim | Code
- Browser: Firefox
- Themes: [Nord](https://github.com/arcticicestudio/nord) | [Challenger-deep](https://github.com/challenger-deep-theme) | [Ephemeral](https://github.com/elenapan/dotfiles/blob/master/.xfiles/ephemeral)


### Issues found

---
Seems that electron apps not working correctly if I do not disable the gpu

```shell
code --disable-gpu
```

Cannot connect to some wifi with wifi-menu. Instead use:
```zsh
nmcli dev wifi list
```

```zsh
nmcli dev wifi connect <SSID> password <PWD>
```
