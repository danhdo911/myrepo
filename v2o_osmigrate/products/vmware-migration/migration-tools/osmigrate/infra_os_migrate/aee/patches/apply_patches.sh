#!/usr/bin/env bash
set -euo pipefail

PATCH_DIR="/tmp/patches"

CUSTOM_PATCHES="${CUSTOM_PATCHES:-true}"
OS_MIGRATE_VERSION="${OS_MIGRATE_VERSION:?OS_MIGRATE_VERSION is required}"

COLLECTION_REPO="https://github.com/os-migrate/vmware-migration-kit.git"
COLLECTION_PATH="/usr/share/ansible/collections"
COLLECTION_DIR="${COLLECTION_PATH}/ansible_collections/os_migrate/vmware_migration_kit"

# Notes:
# By default, the collection build excludes the 'plugins/modules/src' directory,
# as defined in the 'build_ignore' section of galaxy.yml:
# https://github.com/os-migrate/vmware-migration-kit
#
# Therefore, we need to add the Go source files back to the installed collection
# to apply our custom Go patches.

add_go_source() {
    local build_dir
    build_dir="$(mktemp -d)"

    git clone \
        --depth 1 \
        --branch "v${OS_MIGRATE_VERSION}" \
        "${COLLECTION_REPO}" \
        "${build_dir}/source"

    local source="${build_dir}/source/plugins/modules/src"
    local destination="${COLLECTION_DIR}/plugins/modules/src"

    [[ -d "${source}" ]] || {
        echo "ERROR: Go source directory missing: ${source}" >&2
        return 1
    }

    mkdir -p "${destination}"
    cp -a "${source}/." "${destination}/"

    rm -rf "${build_dir}"
}

apply_file_patch() {
    local patch_name="$1"
    local source="${PATCH_DIR}/${patch_name}"
    local file relative destination

    [[ -d "${source}" ]] || {
        echo "ERROR: Patch directory not found: ${source}" >&2
        return 1
    }

    # Validate destination files before overwriting
    while IFS= read -r -d '' file; do
        relative="${file#"${source}/"}"
        destination="${COLLECTION_DIR}/${relative}"

        [[ -f "${destination}" ]] || {
            echo "ERROR: Destination file does not exist: ${destination}" >&2
            return 1
        }
    done < <(find "${source}" -type f -print0)

    # Replace existing files
    while IFS= read -r -d '' file; do
        relative="${file#"${source}/"}"
        destination="${COLLECTION_DIR}/${relative}"

        cp -av -- "${file}" "${destination}"
    done < <(find "${source}" -type f -print0)

    echo "File patch applied: ${patch_name}"
}

apply_code_patch() {
    local patch_name="$1"
    local patch_script="${PATCH_DIR}/${patch_name}/patch.py"

    [[ -f "${patch_script}" ]] || {
        echo "ERROR: Patch script not found: ${patch_script}" >&2
        return 1
    }

    echo "Applying code patch: ${patch_name}"

    python3.12 "${patch_script}" "${COLLECTION_DIR}"
}

build_go_binaries() {
    echo "Preparing Go build dependencies..."

    dnf install -y dnf-plugins-core
    dnf config-manager --set-enabled crb
    dnf install -y golang gcc libnbd-devel

    echo "Building patched Go modules..."

    cd "${COLLECTION_DIR}"

    local folder module_name pkg_name

    for folder in plugins/modules/src/*; do
        [[ -d "${folder}" ]] || continue

        module_name="$(basename "${folder}")"
        pkg_name="$(cd "${folder}" && go list -f '{{.Name}}' .)"

        if [[ "${pkg_name}" == "main" ]]; then
            echo "Building ${module_name}..."

            (
                cd "${folder}"
                go build -trimpath \
                    -ldflags="-s -w -buildid=" \
                    -o "${COLLECTION_DIR}/plugins/modules/${module_name}"
            )
        else
            echo "Creating symlink: ${module_name} -> module_dispatcher"
            ln -sf module_dispatcher \
                "${COLLECTION_DIR}/plugins/modules/${module_name}"
        fi
    done

    echo "Go binaries built successfully."
}

case "${CUSTOM_PATCHES}" in
    none)
        echo "Using original collection."
        ;;

    true)
        add_go_source
        apply_file_patch "migration_enhancements"
        apply_code_patch "workload_converted"
        build_go_binaries
        ;;

    *)
        echo "ERROR: Invalid CUSTOM_PATCHES value: ${CUSTOM_PATCHES}" >&2
        echo "Supported values: none, default, true" >&2
        exit 1
        ;;
esac