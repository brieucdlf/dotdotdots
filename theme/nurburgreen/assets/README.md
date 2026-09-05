# Le fond d'écran est assombri en haut, et pourquoi

`backgrounds/00-nurburgring-two-cars.jpg` porte un dégradé vertical cuit dans
l'image, sur la bande du haut uniquement :

```
0.72 à 0 %   0.60 à 3,5 %   0.22 à 10 %   0 à 20 %
```

en `#001a0f`, le `background` du thème.

## Pourquoi il le faut

La barre ne peint plus aucun fond — `background-alpha = 0` dans
`omarchy/.config/omarchy/themed/shell.bar.toml.tpl`, et ce gabarit vaut pour
**tous** les thèmes. Sans traitement, le texte de la barre se pose directement
sur la photo : mesuré sur l'originale, la bande du haut montait à une luminance
linéaire de 0,87 par endroits, où le cognac `#d4b88a` tombait à **1,67:1**.
Après, le maximum est 0,12 et le pire pixel donne **3,15:1**.

C'est la même opération que pour kreide, dont le
[README des assets](../../kreide/assets/README.md) porte la recette complète —
seul le second dégradé (l'assombrissement du haut) s'applique ici ; le premier,
à 100°, était fait pour la maquette du lanceur.

**Toute nouvelle image de fond, dans n'importe quel thème, doit passer par là**,
sinon la barre redevient illisible sur les zones claires.

## Refaire l'opération

Depuis `theme/nurburgreen/`, avec l'image d'origine en `/tmp/base.jpg` :

```bash
python3 - <<'PY'
def ramp(path, L, stops):
    vals = []
    for i in range(L):
        t = i / (L - 1)
        for j in range(len(stops) - 1):
            t0, a0 = stops[j]; t1, a1 = stops[j + 1]
            if t0 <= t <= t1:
                k = 0 if t1 == t0 else (t - t0) / (t1 - t0)
                vals.append(round(255 * (a0 + k * (a1 - a0))))
                break
    open(path, "w").write("P2\n%d 1\n255\n%s\n" % (L, " ".join(map(str, vals))))

ramp("/tmp/r.pgm", 1707, [(0.00,0.72),(0.035,0.60),(0.10,0.22),(0.20,0.00),(1.00,0.00)])
PY

W=2560; H=1707
magick /tmp/r.pgm -rotate 90 -resize ${W}x${H}! /tmp/m.png
magick -size ${W}x${H} xc:'#001a0f' /tmp/m.png \
       -alpha off -compose CopyOpacity -composite /tmp/s.png
magick /tmp/base.jpg /tmp/s.png -compose over -composite \
       -quality 92 backgrounds/00-nurburgring-two-cars.jpg
```

`H` est la hauteur de l'image, pas celle de l'écran : la rampe est en
proportion.
