# secrets/

Les secrets du poste, chiffrés ici, déchiffrables uniquement avec une YubiKey
enrôlée.

## Le modèle

Une identité `age` vit dans l'applet **PIV** de la YubiKey. La clé privée est
générée *sur* le token et n'en sort jamais — impossible de la copier, de la
sauvegarder, ou de la voler autrement qu'en volant la clé physique.

Ce qui est committé ici est donc sans valeur pour qui n'a pas le token :

| Fichier | Contenu | Committé |
|---|---|---|
| `manifest` | quel secret va où | ✅ |
| `recipients.txt` | les clés **publiques** des YubiKeys enrôlées | ✅ |
| `*.age` | les secrets **chiffrés** | ✅ |
| tout le reste | ignoré par `.gitignore` (refus par défaut) | ❌ |

Les secrets déchiffrés atterrissent dans les paquets stow
(`common/.config/bash/local.bash`…), où ils sont gitignorés, et de là stow les
lie dans `~`. Il n'y a **aucune** clé privée sur le disque, à aucun moment.

## Réinstaller un poste

```bash
git clone git@github.com:brieucdlf/dotdotdots ~/.dotfiles
cd ~/.dotfiles && ./install.sh      # branche la YubiKey avant
```

`install.sh` déchiffre tout seul. Rien à restaurer d'ailleurs, aucun fichier à
recopier à la main depuis une sauvegarde : le token *est* la sauvegarde.

Si la clé n'était pas branchée, l'install se termine quand même — il manque
juste les secrets. Branche-la et lance `dots-secrets unseal`.

## Éprouver les clés

Une clé de secours jamais testée n'est pas une sauvegarde, c'est une
supposition. `verify` chiffre un canari pour **tous** les destinataires, puis
tente de l'ouvrir — et ouvre aussi chaque secret réellement scellé.

```bash
# clé A branchée
dots-secrets verify
# clé B branchée, seule
dots-secrets verify
```

À faire **une fois par clé, branchées tour à tour** — c'est le seul moyen de
vérifier que la seconde ouvre sans l'aide de la première. À refaire après
chaque `reseal`.

### Étiqueter les clés

`recipients.txt` ne dit rien du format physique d'une clé. Sans étiquette, le
jour où tu en perds une, tu ne sais pas quelle ligne retirer.

```bash
# la clé à étiqueter, branchée seule
dots-secrets label "USB-C quotidien"
```

`label` lit le destinataire que le token présente et annote **cette ligne-là** —
il ne déduit rien de l'ordre d'enrôlement, qui ne prouve rien.

## Au quotidien

```bash
dots-secrets status          # état complet de la chaîne
dots-secrets verify          # la clé branchée ouvre-t-elle tout ?
dots-secrets label "USB-C"   # étiqueter la clé branchée
dots-secrets edit local.bash # éditer un secret (le clair ne touche pas le disque)
dots-secrets seal            # chiffrer les fichiers en clair déjà en place
dots-secrets unseal          # (re)déposer les secrets sur la machine
```

`edit` déchiffre dans `/dev/shm` (un tmpfs), ouvre `$EDITOR`, rechiffre et
efface. Rien n'est jamais écrit sur un bloc de disque.

## Ajouter une YubiKey

**Le plus simple est d'enrôler les deux clés AVANT de créer le moindre
secret** — il n'y a alors jamais rien à re-sceller.

On n'enrôle jamais deux fois la même clé : `recipients.txt` est cumulatif,
`enroll` ajoute et dédoublonne. Enrôler la seconde ne touche pas à la première.

```bash
dots-secrets enroll   # clé neuve : génère une identité dans un slot PIV
dots-secrets enroll   # clé portant déjà une identité age : reprise telle
                      # quelle, aucun slot n'est écrasé
```

### Si des secrets sont déjà scellés

Un `.age` ne s'ouvre que pour les destinataires connus **au moment où il a été
chiffré**. Ajouter une clé n'ouvre donc rien rétroactivement : il faut
re-sceller, et re-sceller suppose de pouvoir d'abord *déchiffrer*.

D'où la contrainte : **branche les deux YubiKeys en même temps** avant de
lancer `enroll`. `age` essaie toutes les clés qu'il voit ; l'ancienne ouvre,
la nouvelle est ajoutée, tout est re-scellé d'un coup.

Si tu ne peux pas (un seul port, ou la seconde clé est enrôlée ailleurs) :

```bash
dots-secrets enroll     # la nouvelle clé entre dans recipients.txt,
                        # le re-scellement échoue faute de clé qui déchiffre
# … rebrancher une clé déjà destinataire …
dots-secrets reseal     # rattrapage
```

Cet état intermédiaire n'est pas silencieux : `dots-secrets status` affiche
`à RE-SCELLER` tant que l'écart existe, et un `enroll` relancé le rattrape de
lui-même. Le contrôle ne déchiffre rien — il compare le nombre de strophes de
l'en-tête `age` (qui est en clair) au nombre de destinataires connus.

Ensuite : commiter le `recipients.txt` et les `.age` mis à jour.

## Ajouter un secret

1. Une ligne dans `manifest` : `<nom>  <chemin dans le paquet stow>  <mode>`
2. `dots-secrets edit <nom>`
3. Commiter `secrets/<nom>.age`

Si un `<destination>.sample` existe, `edit` part de ce modèle — c'est ce qui
garde les samples versionnés utiles comme documentation des variables attendues.

## Si une YubiKey est perdue

1. La retirer de `recipients.txt`.
2. `dots-secrets reseal` avec une clé encore valide — les `.age` sont
   réécrits sans elle.
3. Commiter. La clé perdue n'ouvre plus rien de ce qui sera chiffré ensuite.

⚠️ Les commits **antérieurs** restent déchiffrables par la clé perdue : l'objet
git ne change pas rétroactivement. Pour les secrets réellement compromis, la
seule réponse valable est de **les faire tourner** (révoquer et régénérer les
clés API concernées) — pas de réécrire l'historique.
