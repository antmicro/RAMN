#!/bin/bash
# Clean-build all 4 ECUs in Debug and collect the ELF files.
# Requires stm32cubeide and headless-build.sh in PATH, or running inside the STM32CubeIDE container.
# Extra arguments are forwarded to _build_ecu.sh, e.g. for the watchdog builds:
#   NAME_SUFFIX=-watchdog bash scripts/build/BUILD_Clean_Debug_elf.sh -DWATCHDOG_ENABLE
# Set OUTPUT_FOLDER to change where the ELF files are copied (default: build/ in the repository root).

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
export WORKSPACE="$( cd "${SCRIPT_DIR}/../../" ; pwd )"
OUTPUT_FOLDER="${OUTPUT_FOLDER:-${WORKSPACE}/build}"
PROJECT_NAME=RAMNV1
ELF="${WORKSPACE}/firmware/${PROJECT_NAME}/Debug/${PROJECT_NAME}.elf"

set -e

mkdir -p "${OUTPUT_FOLDER}"
bash "${SCRIPT_DIR}/_build_ecu.sh" TARGET_ECUA Debug "$@"
cp -p "${ELF}" "${OUTPUT_FOLDER}/ECUA${NAME_SUFFIX}.elf"
bash "${SCRIPT_DIR}/_build_ecu.sh" TARGET_ECUB Debug --skip-import "$@"
cp -p "${ELF}" "${OUTPUT_FOLDER}/ECUB${NAME_SUFFIX}.elf"
bash "${SCRIPT_DIR}/_build_ecu.sh" TARGET_ECUC Debug --skip-import "$@"
cp -p "${ELF}" "${OUTPUT_FOLDER}/ECUC${NAME_SUFFIX}.elf"
bash "${SCRIPT_DIR}/_build_ecu.sh" TARGET_ECUD Debug --skip-import "$@"
cp -p "${ELF}" "${OUTPUT_FOLDER}/ECUD${NAME_SUFFIX}.elf"
