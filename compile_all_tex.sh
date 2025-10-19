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
