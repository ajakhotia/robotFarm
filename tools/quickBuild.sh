#!/usr/bin/env bash
#
# robotFarm Quick Build Script
# This script downloads, builds and installs robotFarm libraries with minimal setup.
#
# Usage: curl -s https://example.com/quickBuild.sh | bash
#        or
#        bash quickBuild.sh [OPTIONS]
#
# Options:
#   -v, --version VERSION     robotFarm version/tag (default: main)
#   -l, --libraries LIST      Semicolon-separated list of libraries (default: all)
#   -p, --prefix PATH         Install prefix (default: /opt/robotFarm)
#   -t, --toolchain TOOLCHAIN Toolchain to use (default: linux-gnu-default)
#   -h, --help               Show this help
#
# Examples:
#   bash quickBuild.sh -v v1.0.0 -l "Eigen3ExternalProject;OpenCVExternalProject" -p ~/robotFarm
#   bash quickBuild.sh --toolchain linux-clang-19 --prefix /usr/local/robotFarm

set -euo pipefail

# Default configuration
ROBOTFARM_VERSION="main"
ROBOTFARM_LIBRARIES=""
INSTALL_PREFIX="/opt/robotFarm"
TOOLCHAIN="linux-gnu-default"
TEMP_DIR=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

get_temp_dir() {
    if command -v mktemp >/dev/null 2>&1; then
        mktemp -d
    elif [[ -n "${TMPDIR:-}" ]]; then
        local temp_base="$TMPDIR"
    elif [[ -n "${TMP:-}" ]]; then
        local temp_base="$TMP"
    elif [[ -d "/tmp" ]]; then
        local temp_base="/tmp"
    else
        local temp_base="."
    fi

    if [[ -z "${temp_base:-}" ]]; then
        temp_base="."
    fi

    local temp_dir="${temp_base}/robotFarm-install-$$-$(date +%s)"
    mkdir -p "$temp_dir"
    echo "$temp_dir"
}

get_available_toolchains() {
    local source_dir="$1"
    find "${source_dir}/cmake/toolchains" -name "*.cmake" -exec basename {} .cmake \; 2>/dev/null | sort || echo "linux-gnu-default"
}

get_available_libraries() {
    local source_dir="$1"
    find "${source_dir}/externalProjects" -name "*.cmake" -exec basename {} .cmake \; 2>/dev/null | sort || echo ""
}

usage() {
    local temp_for_help
    temp_for_help=$(get_temp_dir)

    # Try to download and get actual lists, fallback to examples if that fails
    local toolchains_list="linux-gnu-default, linux-gnu-14, linux-clang-19"
    local libraries_list="Eigen3ExternalProject, BoostExternalProject, OpenCVExternalProject, ..."

    if curl -fsSL "https://github.com/ajakhotia/robotFarm/archive/${ROBOTFARM_VERSION}.tar.gz" -o "${temp_for_help}/robotFarm.tar.gz" 2>/dev/null; then
        if tar -xzf "${temp_for_help}/robotFarm.tar.gz" -C "$temp_for_help" --strip-components=1 2>/dev/null; then
            local actual_toolchains
            actual_toolchains=$(get_available_toolchains "$temp_for_help")
            if [[ -n "$actual_toolchains" ]]; then
                toolchains_list=$(echo "$actual_toolchains" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
            fi

            local actual_libraries
            actual_libraries=$(get_available_libraries "$temp_for_help")
            if [[ -n "$actual_libraries" ]]; then
                libraries_list=$(echo "$actual_libraries" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
            fi
        fi
    fi

    rm -rf "$temp_for_help" 2>/dev/null || true

    cat <<EOF
robotFarm Quick Build Script

This script downloads, builds and installs robotFarm libraries with minimal setup.

Usage: quickBuild.sh [OPTIONS]

Options:
  -v, --version VERSION     robotFarm version/tag (default: main)
  -l, --libraries LIST      Semicolon-separated list of libraries (default: all)
  -p, --prefix PATH         Install prefix (default: /opt/robotFarm)
  -t, --toolchain TOOLCHAIN Toolchain to use (default: linux-gnu-default)
  -h, --help               Show this help

Available toolchains:
  ${toolchains_list}

Examples:
  # Install latest with default settings
  bash quickBuild.sh

  # Install specific version with selected libraries
  bash quickBuild.sh -v v1.0.0 -l "Eigen3ExternalProject;OpenCVExternalProject"

  # Use Clang toolchain with custom prefix
  bash quickBuild.sh --toolchain linux-clang-19 --prefix ~/robotFarm

Available libraries:
  ${libraries_list}

EOF
}

cleanup() {
    if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
        log_info "Cleaning up temporary directory: ${TEMP_DIR}"
        rm -rf "${TEMP_DIR}" || log_warn "Failed to clean up ${TEMP_DIR}"
    fi
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

check_requirements() {
    log_info "Checking system requirements..."

    local missing_tools=()
    for tool in curl git jq cmake ninja; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Installing basic requirements..."
        install_basic_requirements
    fi
}

detect_os() {
    if [[ ! -r /etc/os-release ]]; then
        log_error "Cannot detect OS (missing /etc/os-release)"
        exit 1
    fi

    # shellcheck disable=SC1091
    . /etc/os-release

    OS_ID="${ID:-}"
    OS_VERSION="${VERSION_ID:-}"
    OS_CODENAME="${VERSION_CODENAME:-}"

    if [[ -z "$OS_ID" || -z "$OS_VERSION" ]]; then
        log_error "Unable to determine OS ID or version"
        exit 1
    fi

    log_info "Detected OS: $OS_ID $OS_VERSION ($OS_CODENAME)"

    case "$OS_ID" in
        ubuntu|debian) ;;
        *)
            log_error "Unsupported OS: $OS_ID"
            log_error "This script only supports Ubuntu and Debian"
            exit 1
            ;;
    esac
}

install_basic_requirements() {
    log_info "Installing basic system requirements..."

    if [[ $EUID -ne 0 ]]; then
        log_info "Need root privileges to install packages. Using sudo..."
        SUDO="sudo"
    else
        SUDO=""
    fi

    $SUDO apt-get update -y
    $SUDO apt-get install -y --no-install-recommends \
        ca-certificates curl git gnupg grep lsb-release \
        ninja-build pkg-config sed software-properties-common \
        unzip wget jq python3-dev python-is-python3
}

install_cmake() {
    log_info "Installing CMake..."

    # Download and run the CMake installer script from robotFarm
    local cmake_script_url="https://raw.githubusercontent.com/ajakhotia/robotFarm/${ROBOTFARM_VERSION}/tools/installCMake.sh"
    local cmake_script="${TEMP_DIR}/installCMake.sh"

    curl -fsSL "$cmake_script_url" -o "$cmake_script"
    chmod +x "$cmake_script"

    if [[ $EUID -ne 0 ]]; then
        sudo bash "$cmake_script"
    else
        bash "$cmake_script"
    fi
}

setup_compiler_repositories() {
    local toolchain_needs_repos=false

    case "$TOOLCHAIN" in
        linux-gnu-12|linux-gnu-14)
            toolchain_needs_repos=true
            log_info "Setting up GNU compiler repositories for $TOOLCHAIN..."
            ;;
        linux-clang-19)
            toolchain_needs_repos=true
            log_info "Setting up LLVM/Clang repositories for $TOOLCHAIN..."
            ;;
        linux-gnu-default)
            log_info "Using system default GNU toolchain"
            ;;
        *)
            log_warn "Unknown or custom toolchain: $TOOLCHAIN"
            log_info "Assuming no additional repositories needed"
            ;;
    esac

    if [[ "$toolchain_needs_repos" == "true" ]]; then
        local repos_base_url="https://raw.githubusercontent.com/ajakhotia/robotFarm/${ROBOTFARM_VERSION}/tools/apt"

        case "$TOOLCHAIN" in
            linux-gnu-*)
                log_info "Adding GNU toolchain repositories..."
                curl -fsSL "$repos_base_url/addGNUSources.sh" | sudo bash -s -- -y
                ;;
            linux-clang-*)
                log_info "Adding LLVM repositories..."
                curl -fsSL "$repos_base_url/addLLVMSources.sh" | sudo bash -s -- -y
                log_info "Adding NVIDIA CUDA repositories..."
                curl -fsSL "$repos_base_url/addNvidiaSources.sh" | sudo bash -s -- -y
                ;;
        esac
    fi
}

install_compiler_dependencies() {
    if [[ "$TOOLCHAIN" != "linux-gnu-default" ]]; then
        log_info "Installing compiler packages for $TOOLCHAIN..."

        # Extract and install compiler dependencies from systemDependencies.json
        local deps_url="https://raw.githubusercontent.com/ajakhotia/robotFarm/${ROBOTFARM_VERSION}/systemDependencies.json"
        local extract_script_url="https://raw.githubusercontent.com/ajakhotia/robotFarm/${ROBOTFARM_VERSION}/tools/extractDependencies.sh"

        local deps_file="${TEMP_DIR}/systemDependencies.json"
        local extract_script="${TEMP_DIR}/extractDependencies.sh"

        curl -fsSL "$deps_url" -o "$deps_file"
        curl -fsSL "$extract_script_url" -o "$extract_script"
        chmod +x "$extract_script"

        local compiler_deps
        compiler_deps=$("$extract_script" "Compilers" "$deps_file")

        if [[ -n "$compiler_deps" ]]; then
            if [[ $EUID -ne 0 ]]; then
                sudo apt-get update -y
                # shellcheck disable=SC2086
                sudo apt-get install -y --no-install-recommends $compiler_deps
            else
                apt-get update -y
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends $compiler_deps
            fi
        fi
    fi
}

download_robotFarm() {
    log_info "Downloading robotFarm $ROBOTFARM_VERSION..."

    TEMP_DIR=$(get_temp_dir)
    local archive_url="https://github.com/ajakhotia/robotFarm/archive/${ROBOTFARM_VERSION}.tar.gz"
    local archive_file="${TEMP_DIR}/robotFarm.tar.gz"

    curl -fsSL "$archive_url" -o "$archive_file"

    log_info "Extracting robotFarm sources..."
    tar -xzf "$archive_file" -C "$TEMP_DIR" --strip-components=1

    rm -f "$archive_file"

    log_success "robotFarm sources downloaded to $TEMP_DIR"
}

validate_toolchain_and_libraries() {
    log_info "Validating toolchain and library selections..."

    # Validate toolchain
    local available_toolchains
    available_toolchains=$(get_available_toolchains "$TEMP_DIR")

    if ! echo "$available_toolchains" | grep -q "^${TOOLCHAIN}$"; then
        log_error "Invalid toolchain: $TOOLCHAIN"
        log_error "Available toolchains:"
        echo "$available_toolchains" | sed 's/^/  - /'
        exit 1
    fi

    # Validate libraries if specified
    if [[ -n "$ROBOTFARM_LIBRARIES" ]]; then
        local available_libraries
        available_libraries=$(get_available_libraries "$TEMP_DIR")

        IFS=';' read -ra LIBRARY_ARRAY <<< "$ROBOTFARM_LIBRARIES"
        for library in "${LIBRARY_ARRAY[@]}"; do
            library=$(echo "$library" | xargs) # trim whitespace
            if ! echo "$available_libraries" | grep -q "^${library}$"; then
                log_error "Invalid library: $library"
                log_error "Available libraries:"
                echo "$available_libraries" | sed 's/^/  - /'
                exit 1
            fi
        done
    fi
}

install_system_dependencies() {
    log_info "Installing system dependencies..."

    local extract_script="${TEMP_DIR}/tools/extractDependencies.sh"
    local deps_file="${TEMP_DIR}/systemDependencies.json"

    # Install basic dependencies
    local basic_deps
    basic_deps=$("$extract_script" "Basics" "$deps_file")

    if [[ -n "$basic_deps" ]]; then
        if [[ $EUID -ne 0 ]]; then
            sudo apt-get update -y
            # shellcheck disable=SC2086
            sudo apt-get install -y --no-install-recommends $basic_deps
        else
            apt-get update -y
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends $basic_deps
        fi
    fi
}

build_and_install() {
    log_info "Configuring robotFarm build..."

    local build_dir="${TEMP_DIR}/build"
    local toolchain_file="${TEMP_DIR}/cmake/toolchains/${TOOLCHAIN}.cmake"

    if [[ ! -f "$toolchain_file" ]]; then
        log_error "Toolchain file not found: $toolchain_file"
        log_error "Available toolchains:"
        get_available_toolchains "$TEMP_DIR" | sed 's/^/  - /'
        exit 1
    fi

    # Configure CMake
    local cmake_args=(
        -G Ninja
        -S "$TEMP_DIR"
        -B "$build_dir"
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
        -DCMAKE_TOOLCHAIN_FILE="$toolchain_file"
    )

    if [[ -n "$ROBOTFARM_LIBRARIES" ]]; then
        cmake_args+=(-DROBOT_FARM_REQUESTED_BUILD_LIST="$ROBOTFARM_LIBRARIES")
        log_info "Building selected libraries: $ROBOTFARM_LIBRARIES"
    else
        log_info "Building all available libraries"
    fi

    cmake "${cmake_args[@]}"

    # Install additional system dependencies discovered during configuration
    if [[ -f "${build_dir}/systemDependencies.txt" ]]; then
        log_info "Installing additional system dependencies..."
        local additional_deps
        additional_deps=$(cat "${build_dir}/systemDependencies.txt")

        if [[ -n "$additional_deps" ]]; then
            if [[ $EUID -ne 0 ]]; then
                sudo apt-get update -y
                # shellcheck disable=SC2086
                sudo apt-get install -y --no-install-recommends $additional_deps
            else
                apt-get update -y
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends $additional_deps
            fi
        fi
    fi

    log_info "Building robotFarm libraries..."
    cmake --build "$build_dir"

    log_success "robotFarm build completed successfully!"
}

create_install_directory() {
    if [[ ! -d "$INSTALL_PREFIX" ]]; then
        log_info "Creating install directory: $INSTALL_PREFIX"
        if [[ $EUID -ne 0 && "$INSTALL_PREFIX" == /opt/* ]]; then
            sudo mkdir -p "$INSTALL_PREFIX"
            sudo chown "$USER:$USER" "$INSTALL_PREFIX"
        else
            mkdir -p "$INSTALL_PREFIX"
        fi
    fi
}

print_summary() {
    log_success "robotFarm installation completed!"
    echo
    log_info "Installation summary:"
    echo "  • Version: $ROBOTFARM_VERSION"
    echo "  • Toolchain: $TOOLCHAIN"
    echo "  • Install prefix: $INSTALL_PREFIX"
    if [[ -n "$ROBOTFARM_LIBRARIES" ]]; then
        echo "  • Libraries: $ROBOTFARM_LIBRARIES"
    else
        echo "  • Libraries: All available"
    fi
    echo
    log_info "To use robotFarm in your projects:"
    echo "  export CMAKE_PREFIX_PATH=\"$INSTALL_PREFIX:\$CMAKE_PREFIX_PATH\""
    echo
    log_info "Or add to your CMakeLists.txt:"
    echo "  list(APPEND CMAKE_PREFIX_PATH \"$INSTALL_PREFIX\")"
    echo
}

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                ROBOTFARM_VERSION="$2"
                shift 2
                ;;
            -l|--libraries)
                ROBOTFARM_LIBRARIES="$2"
                shift 2
                ;;
            -p|--prefix)
                INSTALL_PREFIX="$2"
                shift 2
                ;;
            -t|--toolchain)
                TOOLCHAIN="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    log_info "Starting robotFarm installation..."
    log_info "Version: $ROBOTFARM_VERSION"
    log_info "Toolchain: $TOOLCHAIN"
    log_info "Install prefix: $INSTALL_PREFIX"

    detect_os
    check_requirements
    create_install_directory
    setup_compiler_repositories
    install_compiler_dependencies
    install_cmake
    download_robotFarm
    validate_toolchain_and_libraries
    install_system_dependencies
    build_and_install
    print_summary
}

main "$@"
