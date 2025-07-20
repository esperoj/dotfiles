RCLONE_VERBOSE := 1
RCLONE_FLAGS   := --exclude="{tmp/**,.*,.*/**}"
BACKUP_FOLDER  ?= $(HOME)/backup
BACKUP_LIST    ?= backup-bitwarden backup-database backup-linkwarden backup-repos

sync-backup: $(BACKUP_LIST)
	parallel -vj0 --keep-order rclone sync "$$BACKUP_FOLDER" ::: "backup-0:" "backup-1:"
.PHONY: sync-backup

sync-workspace:
	rclone sync workspace-0: workspace-1:
.PHONY: sync-workspace

sync-archive:
	rclone sync archive-0: archive-1:
.PHONY: sync-archive

upload-backup: $(BACKUP_LIST)
	$(MAKE_TEMP_DIR)
	7z a -mx9 -mhe=on "-p$${ENCRYPTION_PASSPHRASE}" backup.7z "$${BACKUP_FOLDER}"
	rclone copy backup.7z public:
.PHONY: upload-backup

backup-init:
	rclone sync backup-0: "$${BACKUP_FOLDER}"
.PHONY: backup-init

backup-bitwarden: backup-init
	$(MAKE_TEMP_DIR)
	$(MAKE) -C ~/ports bitwarden_cli
	bw config server "$${BW_SERVER}"
	bw login --apikey
	export BW_SESSION="$$(bw unlock --passwordenv BW_PASSWORD --raw)"
	bw export --output bitwarden.json --format json
	bw logout
	7z a -mx9 -mhe=on "-p$${ENCRYPTION_PASSPHRASE}" bitwarden.json.7z bitwarden.json
	cp bitwarden.json.7z "$${BACKUP_FOLDER}"
.PHONY: backup-bitwarden

backup-database: backup-init
	$(MAKE_TEMP_DIR)
	esperoj export_database primary
	rm -r "$${BACKUP_FOLDER}"/databases
	cp -r . "$${BACKUP_FOLDER}"/databases
.PHONY: backup-database

backup-linkwarden: backup-init
	$(MAKE_TEMP_DIR)
	curl -fsSm 10 --retry 5 -H "Authorization: Bearer $${LINKWARDEN_ACCESS_TOKEN}" \
	"https://links.adminforge.de/api/v1/migration">"linkwarden.json"
	cp "linkwarden.json" "$${BACKUP_FOLDER}/linkwarden.json"
.PHONY: backup-linkwarden

backup-repos: backup-init
	$(MAKE_TEMP_DIR)
	parallel --keep-order -vj0 wget -qO {}.zip https://github.com/esperoj/{}/archive/refs/heads/main.zip ::: archive dotfiles esperoj notebook ports
	rm -r "$${BACKUP_FOLDER}"/repos
	cp -r . "$${BACKUP_FOLDER}"/repos
.PHONY: backup-repos
