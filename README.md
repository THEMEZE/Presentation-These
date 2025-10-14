
---

## ⚙️ Git Mise à jour
```bash
git add .
git commit -m "Mise à jour"
git push
```

Une solution **complète, en ligne de commande**, pour (A) **créer** un PDF contenant une animation à l’intérieur (avec LaTeX), et (B) les options réalistes pour afficher/lire cette animation depuis la ligne de commande.

> [!IMPORTANT]
> **beaucoup de lecteurs PDF ne supportent pas les animations intégrées** — seul Adobe Acrobat Reader (desktop) gère correctement certaines animations/vidéos/objets RichMedia. Je détaille aussi des alternatives pratiques (jouer le GIF/vidéo en CLI, extraire les images, etc.).

## 1) Préparer les images (si tu as un GIF)
Si tu as un GIF animé et que tu veux l’insérer comme animation LaTeX, découpe-le en frames PNG :
```bash
# requires ImageMagick
convert animation.gif frame_%03d.png
# cela produit frame_000.png, frame_001.png, ...
```
Si tu as une série d'images déjà (frame_001.png ... frame_100.png) passe à l'étape suivante.

## 2) Créer un PDF animé avec LaTeX (``animate package)
Crée un fichier `anim.tex` avec le contenu suivant (exemple minimal) :
```tex
\documentclass{standalone}
\usepackage{graphicx}
\usepackage{animate}

\begin{document}

% affiche 12 images par seconde, avec contrôles
\animategraphics[controls,loop]{12}{frame_}{000}{099}

\end{document}
```
Explications :

- `\animategraphics{fps}{pre}{first}{last}` charge `pre + number + .png` (ici frame_000.png → frame_099.png).
- `controls` ajoute des boutons (lire/pause) dans le PDF (si le lecteur PDF les supporte).
- `loop` : boucle.

Compiler en CLI :
```bash
# option -shell-escape parfois nécessaire
pdflatex -interaction=nonstopmode -halt-on-error anim.tex
```

Résultat : `anim.pdf`.

> [!WARNING]
> **Remarque importante** : l’animation créée par animate fonctionne dans les lecteurs PDF qui gèrent les animations du package animate. Beaucoup de lecteurs Linux (mupdf, zathura, evince) **ne jouent** pas ces animations ; Adobe Reader Desktop est souvent nécessaire pour voir le comportement complet (controls, lecture).

## 3) Insérer une vidéo/MP4 dans un PDF (autre méthode)

On peut aussi embarquer une vidéo (MP4) avec `media9` / `media4svg` / `embedfile` ; historically media9 (Flash) est obsolète. Moderne : `media9`/`media4pdf` peuvent fonctionner mais la compatibilité reste limitée. Exemple (simple) — mais **attention** : la lecture requiert souvent Adobe Reader.

## 4) Si tu veux juste afficher l’animation depuis la ligne de commande (sans dépendre du PDF)

Souvent la solution la plus robuste est **jouer le GIF/MP4** directement en CLI plutôt que via un PDF (plus fiable) :

- Avec `mpv`:
```bash
mpv animation.gif
# ou pour mp4
mpv video.mp4
```
- Avec `ffplay` (fourni par ffmpeg) :
```bash
ffplay -loop 0 animation.gif
# ou pour frames :
ffplay -framerate 12 frame_%03d.png
```
- Sur macOS & iTerm2, tu peux afficher images directement dans le terminal avec `imgcat` (kit iTerm) ou `catimg`.
- Sur Linux sans X (framebuffer), `fbi` peut afficher des images plein écran ; `fbi` accepte une série d'images pour un diaporama.

## 5) Extraire une animation depuis un PDF (si tu reçois un PDF animé)
Si tu veux récupérer les frames/vidéo embarquées dans un PDF :
```bash 
# liste les pièces jointes
pdfdetach -list fichier.pdf

# extraire toutes les pièces jointes
pdfdetach -saveall -o out_dir fichier.pdf
```
Pour extraire images rasterisées d’une page (si animation est une série de pages) :
```bash
pdftoppm -png fichier.pdf page
# -> page-1.png, page-2.png, ...
```
Ensuite tu peux lire les images avec `ffplay`/`mpv`.

## 6) Conclusions et recommandations pratiques
- **Pour créer** : la méthode la plus simple en CLI est LaTeX + `animate` + `pdflatex` (avec frames générées par ImageMagick). Commandes données plus haut.
- **Pour afficher** : la réalité est que **les lecteurs PDF en CLI ou les visionneuses Linux souvent NE LECTURENT PAS les animations** intégrées. Si tu veux la solution la plus portable en ligne de commande, **ne pas mettre l’animation dans le PDF** : fournis plutôt le GIF/MP4 et lance `mpv`/`ffplay`.
- Si tu dois absolument un PDF animé et que l’utilisateur final utilise Windows/macOS, informe-le qu’il faudra ouvrir le PDF dans **Adobe Acrobat Reader** pour voir l’animation complète.
- Si ton but est d’intégrer l’animation pour un partage web, mieux vaut convertir l’animation en vidéo ou GIF et l’intégrer dans une page HTML (très portable).

---

Tu veux donc **afficher un fichier PDF en ligne de commande**, sans logiciel graphique.
Voici **toutes les méthodes possibles selon ton système (Linux/macOS)**.

## 🧭 1. Vérifier ton système
Tu es sur macOS (d’après nos échanges précédents), donc les solutions suivantes sont valides.

## 🖥️ 2. Afficher un PDF en ligne de commande (macOS)

### 🔹 Option A — Ouvrir avec *Preview.app* (la visionneuse native macOS)
C’est la méthode la plus simple, **même si elle ouvre une fenêtre graphique** :
```bash
open fichier.pdf
```
➡️ Cela ouvrira `fichier.pdf` dans Aperçu (`Preview.app`).
Si tu veux **ouvrir dans Safari** :
```bash
open -a Safari fichier.pdf
```
Si tu veux **ouvrir dans Chrome** :
```bash
open -a "Google Chrome" fichier.pdf
```

### 🔹 Option B — Ouvrir en ligne de commande sans interface graphique
Si tu veux **vraiment afficher dans le terminal**, il faut convertir le PDF en texte ou en images ASCII.
① Lire **le texte du PDF** :
```bash
pdftotext fichier.pdf -
```
➡️ Cela affiche le contenu texte directement dans le terminal.
② **Afficher les pages en ASCII (avec catimg ou imgcat)** :
Si ton terminal supporte les images (comme iTerm2 ou Kitty) :
```bash
brew install catimg
catimg fichier.pdf
```
⚠️ Ça affichera seulement la première page. Pour toutes les pages :
```bash
pdftoppm fichier.pdf page -png
catimg page-1.png
```
③ **Convertir en images pour visualiser les pages** :
```bash
pdftoppm -png fichier.pdf page
open page-1.png
```

### 🔹 Option C — Visionneuse CLI Linux (si tu utilises un terminal complet)

Si tu travailles sur un serveur ou un environnement Linux (sans GUI) :
```bash
sudo apt install mupdf
mupdf fichier.pdf
```
ou :
```bash
sudo apt install zathura
zathura fichier.pdf
```
Mais ces outils ouvrent une interface légère, pas strictement texte.

## ⚙️ 3. Afficher une animation à l’intérieur d’un PDF
⚠️ Aucune visionneuse CLI (ni Preview, ni mupdf, **ni zathura) ne lit les animations PDF**.
Seul **Adobe Acrobat Reader Desktop** (GUI) supporte les objets `animategraphics` ou `media9`.

Sur macOS, tu peux ouvrir avec :
```bash
open -a "Adobe Acrobat Reader" fichier.pdf
```
Si tu veux rester 100 % ligne de commande et voir l’animation, il faut **extraire les images et les lire avec `ffplay`** :
```bash
pdftoppm -png fichier.pdf frame
ffplay -framerate 12 frame-*.png
```

## 🔹 En résumé

| Objectif                     | Commande                                     |
| ---------------------------- | -------------------------------------------- |
| Ouvrir dans Aperçu           | `open fichier.pdf`                           |
| Ouvrir dans Chrome           | `open -a "Google Chrome" fichier.pdf`        |
| Extraire le texte            | `pdftotext fichier.pdf -`                    |
| Convertir pages → images     | `pdftoppm -png fichier.pdf page`             |
| Lire animation dans terminal | `ffplay -framerate 12 frame-*.png`           |
| Lire animation intégrée      | `open -a "Adobe Acrobat Reader" fichier.pdf` |

---

# Automatiser l’indentation du code LaTeX

Il n’existe pas de beautifier officiel LaTeX dans le terminal, mais tu peux utiliser :

## a) VS Code

1. Installe l’extension LaTeX Workshop.
2. Sélectionne ton code → `Format Document` (ou raccourci : `Shift + Alt + F`).
3. Cela réindentera automatiquement tes `\begin{}` / `\end{}` et les options.

## b) Texmaker / TeXstudio

Sélectionne tout le code → `Tools > Auto Indent`

Cela fonctionne très bien pour les environnements imbriqués (`frame`, `columns`, etc.)

## c) En ligne de commande

Si tu veux un outil CLI pour Linux/macOS :
```bash
brew install latexindent
latexindent -w monfichier.tex
```
- `-w` : remplace le fichier avec le code indenté automatiquement.
- `latexindent` supporte très bien `\begin{frame}`, `\begin{columns}`, etc.
- C’est le meilleur outil CLI pour réindentation automatique de LaTeX.

---
Si tu veux compiler plusieurs fichiers `.tex` dans deux dossiers différents, tu peux le faire soit en Bash, soit en Python. Je te propose les deux solutions.

## Solution Bash
Imaginons que tes fichiers `.tex` soient dans `./` et `./fichiers/` :
```bash 
#!/bin/bash

# Liste des dossiers
folders=("./" "./fichiers/")

# Boucle sur chaque dossier
for folder in "${folders[@]}"; do
    echo "Compilation des fichiers dans $folder"
    # Boucle sur chaque .tex
    for texfile in "$folder"/*.tex; do
        echo "  Compilation de $texfile"
        pdflatex -interaction=nonstopmode -output-directory="$folder" "$texfile"
    done
done
```
✅ Points importants :
- `interaction=nonstopmode` : continue même s’il y a des warnings ou erreurs.
- `output-directory="$folder"` : place le PDF et fichiers auxiliaires dans le même dossier que le `.tex`.

## Solution Python
Avec Python, tu peux faire la même chose avec `subprocess` :

```python
import subprocess
from pathlib import Path

folders = ["dossier1", "dossier2"]

for folder in folders:
    folder_path = Path(folder)
    tex_files = folder_path.glob("*.tex")
    for tex_file in tex_files:
        print(f"Compilation de {tex_file}")
        subprocess.run([
            "pdflatex",
            "-interaction=nonstopmode",
            f"-output-directory={folder_path}",
            str(tex_file)
        ])
```
✅ Points forts :
- Tu peux facilement ajouter un filtre pour ne compiler que certains fichiers.
- Python peut ensuite déplacer, renommer ou traiter les PDFs automatiquement après compilation.

# Presentation-These
