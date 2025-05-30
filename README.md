# 📁 Script Bash per Spostamento File da/verso Hard Disk

Questo script Bash permette di spostare in modo sicuro ed efficiente i file da un hard disk esterno alla memoria locale (e viceversa), con gestione di errori, confronto tra file, barra di progresso tramite `pv`, supporto ai nomi con spazi e pulizia delle cartelle vuote.

---

## 🛠 Funzionalità principali

- ✅ Ricostruisce la struttura delle cartelle durante lo spostamento.
- 🧠 Confronta i file (evita la copia se già esistono e sono identici).
- 🚫 Esclude automaticamente file > 4GB quando si copia su dischi FAT32.
- 🔐 Tenta copie elevate a `sudo` in caso di errori di permessi.
- 📦 Supporta file con spazi nel nome.
- 📊 Usa `pv` per mostrare una barra di progresso.
- 🧹 Rimuove automaticamente le cartelle vuote con `--clean-empty-dirs`.
- 📝 Logga gli errori su file.

---

## 📦 Requisiti

Assicurati di avere installato:

```bash
sudo apt install pv
🚀 Utilizzo
1. Sposta file dall'hard disk esterno alla memoria locale
bash
Copia
Modifica
bash sposta_file.sh --to-local
2. Sposta file dalla memoria locale all'hard disk esterno (esclude file > 4GB)
bash
Copia
Modifica
bash sposta_file.sh --to-disk
3. Pulisce tutte le cartelle vuote da una directory specifica
bash
Copia
Modifica
bash sposta_file.sh --clean-empty-dirs /percorso/della/cartella
📂 Percorsi predefiniti
Modifica questi valori all'inizio dello script secondo le tue esigenze:

bash
Copia
Modifica
HD_PATH="/media/daniele/TOSHIBA"
LOCAL_PATH="/home/daniele/Documenti/mady"
ERROR_LOG="/home/daniele/Documenti/errore_spostamento.log"
📌 Note importanti
Lo script non sovrascrive file identici, ma elimina l'originale.

Se un file esiste con contenuto diverso, viene copiato con un nuovo nome.

I file troppo grandi per il filesystem FAT32 (oltre 4GB) vengono ignorati durante la copia verso l’hard disk.

Gli errori di permessi vengono gestiti tentando l'uso di sudo.

🧪 Suggerimenti
Esegui una simulazione preventiva con:

bash
Copia
Modifica
find /origine -type f
Verifica il log in:

bash
Copia
Modifica
/home/daniele/Documenti/errore_spostamento.log
📃 Licenza
Distribuito con licenza MIT.

✍️ Autore
Daniele – GitHub
