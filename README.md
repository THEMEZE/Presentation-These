
---

## ⚙️ Git Mise à jour
```bash
git add .
git commit -m "Mise à jour"
git push
```
ou 
```bash
git init
git remote add origin https://github.com/THEMEZE/Presentation-These.git
git fetch origin
git branch -M main
git add .
git commit -m "Modifications depuis copie C"
git push -u origin main
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
    echo "🔹 Compilation des fichiers dans $folder"
    # Boucle sur chaque .tex
    for texfile in "$folder"/*.tex; do
        echo "🔹🔹  Compilation de $texfile"
        pdflatex -interaction=nonstopmode -output-directory="$folder" "$texfile"
    done
done
```
✅ Points importants :
- `interaction=nonstopmode` : continue même s’il y a des warnings ou erreurs.
- `output-directory="$folder"` : place le PDF et fichiers auxiliaires dans le même dossier que le `.tex`.

> Voici une version améliorée de ton script Bash :
- ✅ il parcourt tous les fichiers .tex récursivement,
- ✅ affiche des ✅ ou ⚠️ ou  ❌ selon le succès de la compilation,
    - `"Fatal error"` ou `"! LaTeX Error"` → ❌ erreur de compilation
    - `"warning"` → ⚠️ avertissement
    - Sinon → ✅ succès
- ✅Les compilations se font deux fois pour résoudre les références croisées.
- ✅ Les fichiers cachés et ._ sont toujours exclus.
- ✅ est propre et lisible, avec des couleurs et un résumé final.

> 🧠 Script amélioré : `compile_all_tex.sh`
```bach
#!/bin/bash

# Couleurs pour un affichage plus clair
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Compteurs
success_count=0
warning_count=0
fail_count=0

echo -e "${BLUE}🔹 Recherche et compilation de tous les fichiers .tex...${RESET}"
echo

# Trouve tous les fichiers .tex récursivement,
# en excluant les fichiers cachés et ceux commençant par ._,
# puis les trie pour que les plus profonds soient compilés en premier.
texfiles=$(find . -type f -name "*.tex" ! -name "._*" ! -path "*/.*/*" | awk '{ print length, $0 }' | sort -nr | cut -d" " -f2-)

# Vérifie si des fichiers ont été trouvés
if [ -z "$texfiles" ]; then
    echo -e "${RED}❌ Aucun fichier .tex trouvé.${RESET}"
    exit 1
fi

# Boucle sur chaque fichier trouvé (du plus profond au plus haut)
for texfile in $texfiles; do
    basename=$(basename "$texfile")

    # Ignore les fichiers cachés
    if [[ "$basename" == .* ]]; then
        continue
    fi

    folder=$(dirname "$texfile")
    echo -e "${BLUE}🔹 Compilation de${RESET} $texfile"

    # Compile deux fois pour bien générer les références
    log_file=$(mktemp)
    pdflatex -interaction=nonstopmode -output-directory="$folder" "$texfile" >"$log_file" 2>&1
    pdflatex -interaction=nonstopmode -output-directory="$folder" "$texfile" >>"$log_file" 2>&1

    # Analyse du log
    if grep -q "Fatal error" "$log_file" || grep -q "! LaTeX Error" "$log_file"; then
        echo -e "   ❌ ${RED}Erreur de compilation${RESET} : $basename"
        ((fail_count++))
    elif grep -qi "warning" "$log_file"; then
        echo -e "   ⚠️  ${YELLOW}Compilation avec avertissements${RESET} : $basename"
        ((warning_count++))
    else
        echo -e "   ✅ ${GREEN}Compilation réussie${RESET} : $basename"
        ((success_count++))
    fi

    rm -f "$log_file"
    echo
done

# Résumé final
echo -e "${BLUE}──────────── Résumé ────────────${RESET}"
echo -e "✅ ${GREEN}Réussies : $success_count${RESET}"
echo -e "⚠️  ${YELLOW}Avec avertissements : $warning_count${RESET}"
echo -e "❌ ${RED}Échouées : $fail_count${RESET}"
echo -e "${BLUE}────────────────────────────────${RESET}"
```

> 🔍 Explication des changements :
- `find . -type f -name "*.tex" ! -name "._*"` → exclut tous les fichiers commençant par ._.
- `if [[ "$basename" == .* ]]; then continue; fi` → saute aussi tout fichier dont le nom commence par `.` (comme `.temp.tex`).
- Ainsi, seuls les vrais fichiers `.tex` visibles seront compilés.

> 💡 — tu veux donc que le script commence par compiler les fichiers `.tex` les plus profonds dans l’arborescence, avant de remonter vers les fichiers plus haut.
C’est une excellente stratégie, notamment si certains .tex en haut dépendent de ceux dans les sous-dossiers (par exemple des inclusions `\input{...}`).

>> ⚙️ Détails de la ligne clé :
```bash
texfiles=$(find . -type f -name "*.tex" ! -name "._*" ! -path "*/.*/*" | awk '{ print length, $0 }' | sort -nr | cut -d" " -f2-)
```

Explication :
- `find . -type f -name "*.tex"` → cherche tous les .tex
- `! -name "._*"` → exclut les fichiers macOS temporaires
- `! -path "*/.*/*"` → exclut les fichiers cachés dans des dossiers cachés
- `awk '{ print length, $0 }' | sort -nr` → trie par longueur du chemin, donc du plus profond au plus haut
- `cut -d" " -f2-` → retire la colonne de longueur pour ne garder que le chemin

```bash
chmod +x compile_all_tex.sh
./compile_all_tex.sh
```

qui contient 

```bash
#!/bin/bash

# Couleurs pour un affichage plus clair
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Compteurs
success_count=0
fail_count=0

echo -e "${BLUE}🔹 Recherche et compilation de tous les fichiers .tex...${RESET}"
echo

# Trouve tous les fichiers .tex récursivement,
# en excluant les fichiers cachés et ceux commençant par ._,
# puis les trie pour que les plus profonds soient compilés en premier.
texfiles=$(find . -type f -name "*.tex" ! -name "._*" ! -path "*/.*/*" | awk '{ print length, $0 }' | sort -nr | cut -d" " -f2-)

# Vérifie si des fichiers ont été trouvés
if [ -z "$texfiles" ]; then
    echo -e "${RED}❌ Aucun fichier .tex trouvé.${RESET}"
    exit 1
fi

# Boucle sur chaque fichier trouvé (du plus profond au plus haut)
for texfile in $texfiles; do
    basename=$(basename "$texfile")

    # Ignore les fichiers cachés
    if [[ "$basename" == .* ]]; then
        continue
    fi

    folder=$(dirname "$texfile")
    echo -e "${BLUE}🔹 Compilation de${RESET} $texfile"

    # Compile silencieusement
    pdflatex -interaction=nonstopmode -output-directory="$folder" "$texfile" >/dev/null 2>&1
    
    # deuximeme foix 
    pdflatex -interaction=nonstopmode -output-directory="$folder" "$texfile" >/dev/null 2>&1

    # Vérifie le code de retour
    if [ $? -eq 0 ]; then
        echo -e "   ✅ ${GREEN}Compilation réussie${RESET} : $basename"
        ((success_count++))
    else
        echo -e "   ❌ ${RED}Erreur de compilation${RESET} : $basename"
        ((fail_count++))
    fi
    echo
done

# Résumé final
echo -e "${BLUE}──────────── Résumé ────────────${RESET}"
echo -e "✅ ${GREEN}Réussies : $success_count${RESET}"
echo -e "❌ ${RED}Échouées : $fail_count${RESET}"
echo -e "${BLUE}────────────────────────────────${RESET}"
```
✅ Points forts :
- Tu peux facilement ajouter un filtre pour ne compiler que certains fichiers.
- Python peut ensuite déplacer, renommer ou traiter les PDFs automatiquement après compilation.

# Presentation-These

## 🔹 Les quatre principales méthodes pour geler les degrés de liberté transverses

### 1. Confinement harmonique anisotrope — *Piège “cigare”*
> **Principe :**  
> Un faisceau dipolaire ou un champ magnétique crée un piège **fortement anisotrope**, avec une fréquence de confinement transverse  \( \omega_\perp \gg \omega_\parallel \).  Lorsque \( \hbar \omega_\perp \gg k_B T, \mu \), les excitations transverses sont gelées : les atomes occupent uniquement **l’état fondamental transverse** → régime *quasi-1D*.

> **Utilisation typique :**  
> Premières études sur des condensats allongés.  → *Gerbier et al., PRA 70, 013607 (2004)*  

**Avantages :**
- Mise en œuvre simple (pièges magnétiques ou dipolaires).  
- Bon contrôle de la transition 3D → 1D.

---

### 2. Réseaux optiques 2D — *Tubes unidimensionnels*
> **Principe :**  
> Deux ondes stationnaires orthogonales forment un **réseau optique bidimensionnel profond**, découpant le nuage en une matrice de **tubes 1D indépendants**.  Le confinement transverse est garanti par la profondeur du réseau  \( V_0 \gg E_R \),  tandis que la dynamique reste libre le long de l’axe longitudinal.

**Expériences emblématiques :**
- *B. Paredes et al., Nature 429, 277 (2004)*  
- *T. Kinoshita et al., Science 305, 1125 (2004)*  
→ Première observation du **gaz de Tonks–Girardeau**.

**Avantages :**
- Contrôle homogène du confinement.  
- Reproductibilité élevée.  

**Limites :**
- Mesures souvent moyennées sur un grand nombre de tubes.

---

### 3. Guides magnétiques et pièges sur puce atomique — *Micro-fils et RF-dressing*
> **Principe :**  
> Des micro-conducteurs sur une **puce atomique** génèrent des champs magnétiques qui confinent les atomes de manière tubulaire.  Le confinement transverse peut être **renforcé par des potentiels radio-fréquences “dressed”**, atteignant des fréquences de plusieurs dizaines de kHz — suffisantes pour **geler les degrés de liberté transverses**.

**Avantages :**
- Accès à un **tube unique** à géométrie bien définie.  
- Grande **stabilité mécanique et optique**.  
- Possibilité de **mesures locales et résolues spatialement**.

**Références clés :**
- *A. van Amerongen et al., PRL 100, 090402 (2008)*  
- *T. Jacqmin et al., PRL 106, 230405 (2011)*  
→ Observation directe des fluctuations sub-Poissoniennes dans un gaz 1D sur puce.

---

### 4. Résonances de confinement induit (CIR)
> **Principe :**  
> En géométrie confinée, la diffusion atomique est modifiée :  le couplage effectif 1D \( g_{1D} \) dépend du confinement transverse \( a_\perp \).  Pour certains rapports \( a_\perp / a_s \), une **résonance de confinement** apparaît, permettant de **moduler l’interaction sans exciter les modes transverses**.

**Intérêt :**
- Permet d’explorer les régimes **fortement corrélés** (Tonks–Girardeau, super-Tonks).  
- Complémentaire aux autres méthodes, contrôlant finement le couplage.

**Références :**
- *M. Olshanii, PRL 81, 938 (1998)* — théorie fondatrice.  
- *E. Haller et al., PRL 104, 153203 (2010)* — observation expérimentale.

---

### 🔹 Tableau récapitulatif

| Méthode | Support expérimental | Type de confinement | Références clés |
|----------|----------------------|----------------------|-----------------|
| (1) Confinement harmonique anisotrope | Pièges optiques ou magnétiques | Confinement transversal fort, anisotrope | Gerbier (2004) |
| (2) Réseaux optiques 2D | Lattice optique croisé | Ensemble de tubes 1D indépendants | Paredes (2004), Kinoshita (2004) |
| (3) Pièges sur puce atomique | Fils micro-fabriqués, RF-dressing | Tube unique fortement confiné | van Amerongen (2008), Jacqmin (2011) |
| (4) Résonance de confinement (CIR) | Toute géométrie confinée | Modification du couplage \( g_{1D} \) | Olshanii (1998), Haller (2010) |

---

### 🔹 Formulation possible pour ta présentation orale

> “Plusieurs approches expérimentales permettent aujourd’hui de réaliser des gaz d’atomes réellement unidimensionnels, en gelant les degrés de liberté transverses.  
> Ces méthodes incluent le confinement harmonique anisotrope, les réseaux optiques bidimensionnels formant des tubes 1D, les guides magnétiques sur puce atomique, et les résonances de confinement induit.  
> Dans notre expérience, la **géométrie sur puce** offre un **contrôle local précis du confinement** et permet **une observation directe des fluctuations dans un tube unique**.”

---

**Auteur :** Guillaume Théméze  
**Laboratoire :** Institut d’Optique Graduate School  
**Projet de thèse :** Étude des gaz de Bose unidimensionnels sur puce atomique  
**Date :** Octobre 2025

---
## 🎬 Contexte : les overlays dans Beamer

| Commande       | Avant apparition | Après apparition | Espace réservé ?  | Commentaire                 | Usage |
| -------------- | ---------------- | ---------------- | ----------------- | --------------------------- | ------------------------------------------------|
| 🧩 `\only`        | supprimé         | visible          | ❌ non             | pas d’espace avant          | ```\only<2->{Texte visible à partir de la 2e diapo}``` |
| 💨 `\onslide`     | caché            | visible          | ✅ oui             | même effet que `\uncover`   | ```\onslide<2->{Texte visible à partir de la 2e diapo}``` |
| 🫥 `\uncover`     | invisible        | visible          | ✅ oui             | garde la mise en page       | ```\uncover<2->{Texte caché au début, mais espace conservé}```|
| 👀 `\visible`     | supprimé         | visible          | ❌ non             | ne garde pas d’espace       | ```\visible<2->{Texte}```|
| 🔁 `\alt<>{A}{B}` | B avant          | A après          | dépend du contenu | utile pour alterner         | ```\alt<2>{Version 1}{Version 2}```|
| 🚫 `\invisible`   | caché            | jamais visible   | selon cas         | souvent pour forcer un état | ```\invisible<1>{Texte}```|

