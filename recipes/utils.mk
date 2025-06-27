define MAKE_TEMP_DIR
	TEMP_DIR="$$(mktemp -d)"

	cleanup_temp_dir() {
	  rm -rf "$${TEMP_DIR}"
	}

	trap cleanup_temp_dir EXIT
	cd "$${TEMP_DIR}"
endef
