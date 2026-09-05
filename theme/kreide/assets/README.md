# Le fond d'écran, et pourquoi il est déjà assombri

`backgrounds/00-gt3rs-kreide.jpg` est une photo de 6016 × 3760 déjà étalonnée à
la main, réduite à 3840 de large et avec **deux dégradés cuits dedans**.

L'original n'est **pas dans le dépôt** : c'est une entrée de fabrication, pas un
fichier que le thème lit, et 4,7 Mo entrés une fois dans l'historique d'un dépôt
public n'en sortent qu'en le réécrivant. `.gitignore` écarte
`theme/*/assets/*.jpg`. Il faut donc le garder ailleurs — la recette ci-dessous
en a besoin, et le dépôt ne le sauvegarde pas pour toi.

## 1. Le scrim de la maquette

Repris à l'identique de l'artefact :

```css
linear-gradient(100deg,
  #15181a 0.93  0%,
  #15181a 0.64  34%,
  #15181a 0.30  62%,
  #15181a 0.56  100%)
```

Il ne pouvait pas rester un calque. Sur la maquette, la scène est une boîte :
un pseudo-élément par-dessus le fond d'écran suffit. Sur un vrai bureau, rien
ne contient le fond d'écran. Le seul endroit où le dégradé peut vivre, c'est
l'image.

## 2. Un assombrissement du haut, sur toute la largeur

Le premier dégradé va de gauche à droite : il ne noircit que le coin
haut-gauche, alors que la barre du haut traverse tout l'écran. Celui-ci est
vertical et ne concerne que la bande supérieure :

```
0.72 à 0 %   0.60 à 3,5 %   0.22 à 10 %   0 à 20 %
```

La barre fait 26 px de haut sur 940 logiques, soit 2,8 % : la transition est
donc étalée bien au-delà, sinon on verrait une bande nette au lieu d'un fondu.

C'est ce qui rend les icônes de la barre lisibles maintenant qu'elle ne peint
plus aucun fond (`background-alpha = 0` dans `themed/shell.bar.toml.tpl`).
Les deux alphas se composent : au coin haut-gauche on arrive à 0,98, en haut à
droite à 0,88, et au centre on reste à 0,30 — la voiture garde sa présence.

## Ce que ça coûte

Le fond d'écran n'est plus neutre. Sous un autre thème il serait faux, et une
fenêtre plein écran s'ouvre sur un fond plus sombre.

## Refaire l'opération

Poser l'original en `assets/gt3rs-source.jpg` (il est gitignoré, il ne partira
pas au commit), puis, depuis `theme/kreide/` :

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

ramp("/tmp/r1.pgm", 2400, [(0.00,0.93),(0.34,0.64),(0.62,0.30),(1.00,0.56)])
ramp("/tmp/r2.pgm", 2400, [(0.00,0.72),(0.035,0.60),(0.10,0.22),(0.20,0.00),(1.00,0.00)])
PY

magick assets/gt3rs-source.jpg -resize 3840x -quality 92 /tmp/base.jpg
W=3840; H=2400

# le scrim à 100deg : rampe horizontale tournée de 10°, puis recadrée
magick /tmp/r1.pgm -resize 4600x4600! -rotate 10 \
       -gravity center -crop ${W}x${H}+0+0 +repage /tmp/m1.png
magick -size ${W}x${H} xc:'#15181a' /tmp/m1.png \
       -alpha off -compose CopyOpacity -composite /tmp/s1.png

# l'assombrissement du haut : rampe verticale, aucune rotation à compenser
magick /tmp/r2.pgm -rotate 90 -resize ${W}x${H}! /tmp/m2.png
magick -size ${W}x${H} xc:'#15181a' /tmp/m2.png \
       -alpha off -compose CopyOpacity -composite /tmp/s2.png

magick /tmp/base.jpg /tmp/s1.png -compose over -composite \
                     /tmp/s2.png -compose over -composite \
       -quality 92 backgrounds/00-gt3rs-kreide.jpg
```

`-rotate 10` et non 100 pour le premier : le `100deg` de CSS se compte depuis
le haut, la rampe d'ImageMagick part de la gauche — 100 − 90 = 10.
