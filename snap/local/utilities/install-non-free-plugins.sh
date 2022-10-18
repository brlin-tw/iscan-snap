#!/usr/bin/env bash
# Install non-free EPSON scanner plugins
# Copyright 2022 林博仁(Buo-ren, Lin) <Buo.Ren.Lin@gmail.com>
# SPDX-License-Identifier: MIT
set -eux
shopt -s nullglob

SNAP_USER_COMMON="${SNAP_USER_COMMON:-"${HOME}/snap/iscan/common"}"
script_filename="${BASH_SOURCE##*/}"
script_name="${script_filename%%.*}"
plugins="$(
    zenity \
        --title 'Install non-free EPSON scanner plugins' \
        --width=640 \
        --height=360 \
        --list \
        --column='Install?' --column 'Plugin code' --column 'Overseas model name' --column 'Japan model name' \
        --checklist \
        --separator=' ' \
        --print-column=2 \
        FALSE gt-f700 'Perfection V350 Photo' GT-F700 \
        FALSE gt-f720 'Perfection V30/V300 Photo' GT-S620/GT-F720 \
        FALSE gt-s600 'Perfection V10/V100 Photo' GT-S600/GT-F650 \
        FALSE gt-s650 'Perfection V19/V39' GT-S650
)"
temp_dir="$(
    mktemp \
        --directory \
        --tmpdir \
        "${script_name}.XXX"
)"
trap trap_exit EXIT
trap_exit(){
    if test -e "${temp_dir}"; then
        rm \
            -r \
            "${temp_dir}"
    fi
}

trap trap_err ERR
trap_err(){
    zenity \
        --title 'Error' \
        --width 640 \
        --error \
        --text 'Install terminated prematurely with errors, please report.'
}

pushd "${temp_dir}" >/dev/null
for plugin in ${plugins}; do
    curl \
        --location \
        --remote-name \
        --verbose \
        --fail \
        "https://download2.ebz.epson.net/iscan/plugin/${plugin}/deb/x64/iscan-${plugin}-bundle-2.30.4.x64.deb.tar.gz"
    tar \
        --extract \
        --verbose \
        --file "${temp_dir}/iscan-${plugin}-bundle-2.30.4.x64.deb.tar.gz"
    for possible_plugin_package in \
        "iscan-${plugin}-bundle-2.30.4.x64.deb/plugins/iscan-plugin-${plugin}_"*"_amd64.deb" \
        "iscan-${plugin}-bundle-2.30.4.x64.deb/plugins/esci-interpreter-${plugin}_"*"_amd64.deb"; do
        dpkg-deb \
            --vextract \
            "${possible_plugin_package}" \
            extract
    done
    for plugin_file in extract/usr/lib/iscan/*.so*; do
    mv \
        --verbose \
        "${plugin_file}" \
        "${SNAP_USER_COMMON}/plugins/"
    done
    for firmware_file in \
        extract/usr/share/iscan/*.bin \
        extract/usr/share/esci/*.bin; do
    mv \
        --verbose \
        "${firmware_file}" \
        "${SNAP_USER_COMMON}/firmware/"
    done
    for device_file in extract/usr/share/iscan-data/device/*.xml; do
        mv \
            --verbose \
            "${device_file}" \
            "${SNAP_USER_COMMON}/device/"
    done
    for possible_plugin_package in \
        "iscan-${plugin}-bundle-2.30.4.x64.deb/plugins/iscan-plugin-${plugin}_"*"_amd64.deb" \
        "iscan-${plugin}-bundle-2.30.4.x64.deb/plugins/esci-interpreter-${plugin}_"*"_amd64.deb"; do
        dpkg-deb \
            --ctrl-tarfile \
            "${possible_plugin_package}" \
            | tar \
                --extract \
                ./postinst
    done

    # Remove duplicate entries
    sed \
        --in-place \
        --expression "/${plugin}/d" \
        "${SNAP_USER_COMMON}/state/interpreter"

    sed \
        --in-place \
        --expression "s@/usr/lib/iscan@${SNAP_USER_COMMON}/plugins@g" \
        --expression "s@/usr/lib/esci@${SNAP_USER_COMMON}/plugins@g" \
        postinst
    ./postinst
done
zenity \
    --title 'Info' \
    --width 640 \
    --info \
    --text 'Install completed without errors.'
