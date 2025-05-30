#!/bin/bash

# CONFIGURA QUI
HD_PATH="/media/<nome>/TOSHIBA"
LOCAL_PATH="/home/<nome>/Documenti"
ERROR_LOG="/home/<nome>/Documenti/errore_spostamento.log"
MAX_SIZE=4294967295  # 4GB - 1 byte (FAT32 limit)

# Funzione di confronto file
files_are_equal() {
    cmp -s "$1" "$2"
}

# Copia con barra di avanzamento
copy_with_progress() {
    local src="$1"
    local dst="$2"
    local temp_dst="${dst}.tmp"
    local filesize

    filesize=$(stat -c %s "$src" 2>/dev/null) || return 1

    if [[ "$EXCLUDE_LARGE" == true && "$filesize" -gt "$MAX_SIZE" ]]; then
        echo "⛔ File troppo grande per FAT32: $src ($filesize bytes)" >> "$ERROR_LOG"
        return 1
    fi

    if pv -s "$filesize" "$src" > "$temp_dst"; then
        mv "$temp_dst" "$dst"
        return 0
    else
        rm -f "$temp_dst"
        return 1
    fi
}

# Pulizia cartelle vuote
clean_empty_dirs() {
    local base_dir="$1"
    if [ ! -d "$base_dir" ]; then
        echo "❌ Cartella inesistente: $base_dir"
        exit 1
    fi

    echo "🧹 Pulizia delle cartelle vuote sotto: $base_dir"
    find "$base_dir" -type d -empty -not -path "$base_dir" -print -delete
    echo "✅ Pulizia completata."
    exit 0
}

# Se richiesto: pulizia cartelle vuote
if [[ "$1" == "--clean-empty-dirs" && -n "$2" ]]; then
    clean_empty_dirs "$2"
fi

# Inizializza log errori
> "$ERROR_LOG"

# Gestione parametri
if [[ "$1" == "--to-local" ]]; then
    SRC_BASE="$HD_PATH"
    DST_BASE="$LOCAL_PATH"
    EXCLUDE_LARGE=false
elif [[ "$1" == "--to-disk" ]]; then
    SRC_BASE="$LOCAL_PATH"
    DST_BASE="$HD_PATH"
    EXCLUDE_LARGE=true
else
    echo "❗ Uso:"
    echo "   $0 --to-local              # da HD esterno a locale"
    echo "   $0 --to-disk               # da locale a HD esterno (esclude > 4GB)"
    echo "   $0 --clean-empty-dirs DIR  # elimina cartelle vuote in DIR"
    exit 1
fi

echo "📁 Origine: $SRC_BASE"
echo "📂 Destinazione: $DST_BASE"
echo "📝 Log errori: $ERROR_LOG"
echo

# Controllo file esistenti
NUM_FILES=$(find "$SRC_BASE" -type f | wc -l)
if [[ "$NUM_FILES" -eq 0 ]]; then
    echo "❌ Nessun file trovato in $SRC_BASE. Verifica il percorso o i permessi."
    exit 1
fi

# Ciclo su tutti i file
find "$SRC_BASE" -type f -print0 | while IFS= read -r -d '' SRC_FILE; do
    REL_PATH="${SRC_FILE#$SRC_BASE/}"
    DEST_FILE="$DST_BASE/$REL_PATH"
    DEST_DIR=$(dirname "$DEST_FILE")
    mkdir -p "$DEST_DIR"

    echo -e "\n➡️ Spostando: $REL_PATH"

    if [ -f "$DEST_FILE" ]; then
        if files_are_equal "$SRC_FILE" "$DEST_FILE"; then
            echo "✅ Identico, elimino origine"
            rm -f "$SRC_FILE" 2>>"$ERROR_LOG" || sudo rm -f "$SRC_FILE" 2>>"$ERROR_LOG"
        else
            ALT_NAME="$DEST_DIR/$(basename "$REL_PATH")_copy_$(date +%s)"
            echo "⚠️ File diverso, rinomino in: $(basename "$ALT_NAME")"
            if copy_with_progress "$SRC_FILE" "$ALT_NAME"; then
                rm -f "$SRC_FILE"
            else
                sudo cp "$SRC_FILE" "$ALT_NAME" 2>>"$ERROR_LOG" && sudo rm -f "$SRC_FILE" 2>>"$ERROR_LOG"
            fi
        fi
    else
        if copy_with_progress "$SRC_FILE" "$DEST_FILE"; then
            rm -f "$SRC_FILE"
        else
            sudo cp "$SRC_FILE" "$DEST_FILE" 2>>"$ERROR_LOG" && sudo rm -f "$SRC_FILE" 2>>"$ERROR_LOG"
        fi
    fi
done

echo -e "\n✅ Operazione completata. Controlla \"$ERROR_LOG\" per eventuali errori."

