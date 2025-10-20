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

#texfiles="./figures/Figures.tex"  "./main.tex" 
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