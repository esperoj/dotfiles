RCLONE_VERBOSE := 1
RCLONE_FLAGS   := --exclude="{tmp/**,.*,.*/**}"
BACKUP_FOLDER  ?= daily-backup

daily-backup: $(BACKUP_FOLDER)
.PHONY: daily-backup

$(BACKUP_FOLDER): sync-backup upload-backup backup-journal

sync-backup: backup-bitwarden backup-database backup-linkwarden backup-repos
	# TODO: rclone sync "backup-0:" "backup-1:"
	rclone sync "backup-0:" "koofr:backup"
.PHONY: sync-backup

upload-backup: backup-bitwarden backup-database backup-linkwarden backup-repos
	export TEMP_DIR="$$(mktemp -d)"
	cd "$$TEMP_DIR"

	cleanup() {
	  rm -rf "$${TEMP_DIR}"
	}
	trap cleanup EXIT
	rclone copy backup-0: ./backup/
	7z a -mx9 "-p$${ENCRYPTION_PASSPHRASE}" backup.7z ./backup/
	rclone move backup.7z public:
.PHONY: upload-backup

backup-journal: backup-database
	JOURNAL_FILE="$${BACKUP_FOLDER}/databases/journal.json"
	[[ -f $$JOURNAL_FILE && $$(stat -c%s $$JOURNAL_FILE) -gt 100000 ]] && rclone copy -v "$$JOURNAL_FILE" ia:xiaoqishi_riji --header-upload "x-archive-keep-old-version:32" --internetarchive-front-endpoint="https://archive.org"
.PHONY: backup-journal

daily-backup-init: start-services wait
	mkdir -p "$${BACKUP_FOLDER}"
.PHONY: daily-backup-init

backup-bitwarden: $(BACKUP_FOLDER)/bitwarden.json.7z
.PHONY: backup-bitwarden

$(BACKUP_FOLDER)/bitwarden.json.7z: daily-backup-init
	cd "$${BACKUP_FOLDER}"
	$(MAKE) -C ~/ports bitwarden_cli
	bw config server "$${BW_SERVER}"
	bw login --apikey
	export BW_SESSION="$$(bw unlock --passwordenv BW_PASSWORD --raw)"
	bw export --output bitwarden.json --format json
	bw logout
	7z a -mx9 "-p$${ENCRYPTION_PASSPHRASE}" bitwarden.json.7z bitwarden.json
	rclone copy bitwarden.json.7z backup-0:

backup-database: $(BACKUP_FOLDER)/databases/
.PHONY: backup-database

$(BACKUP_FOLDER)/databases/: daily-backup-init
	mkdir "$${BACKUP_FOLDER}/databases"
	cd "$${BACKUP_FOLDER}/databases"
	esperoj export_database primary
	rclone copy . backup-0:databases

backup-linkwarden: $(BACKUP_FOLDER)/linkwarden.json
.PHONY: backup-linkwarden

$(BACKUP_FOLDER)/linkwarden.json: daily-backup-init
	curl -fsSm 10 --retry 5 -H "Authorization: Bearer $${LINKWARDEN_ACCESS_TOKEN}" \
	"https://links.adminforge.de/api/v1/migration">"$${BACKUP_FOLDER}/linkwarden.json"
	rclone copy "$${BACKUP_FOLDER}/linkwarden.json" backup-0:

backup-repos: $(BACKUP_FOLDER)/repos/
.PHONY: backup-repos

$(BACKUP_FOLDER)/repos/: daily-backup-init
	mkdir "$${BACKUP_FOLDER}/repos"
	cd "$${BACKUP_FOLDER}/repos"
	parallel --keep-order -vj0 wget -qO {}.zip https://github.com/esperoj/{}/archive/refs/heads/main.zip ::: archive dotfiles esperoj notebook ports
	rclone copy . backup-0:repos
