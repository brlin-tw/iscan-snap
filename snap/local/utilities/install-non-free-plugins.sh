#!/usr/bin/env bash
# Install non-free EPSON scanner plugins
# Copyright 2022 林博仁(Buo-ren, Lin) <Buo.Ren.Lin@gmail.com>
# SPDX-License-Identifier: MIT
set -eux
shopt -s nullglob

SNAP_USER_COMMON="${SNAP_USER_COMMON:-"${HOME}/snap/iscan/common"}"
declare -A PLUGIN_PACKAGE_DOWNLOAD_URLS=(
    [gt-f670]=https://download2.ebz.epson.net/iscan/plugin/gt-f670/deb/x64/iscan-gt-f670-bundle-2.30.4.x64.deb.tar.gz
    [gt-f700]=https://download2.ebz.epson.net/iscan/plugin/gt-f700/deb/x64/iscan-gt-f700-bundle-2.30.4.x64.deb.tar.gz
    [gt-f720]=https://download2.ebz.epson.net/iscan/plugin/gt-f720/deb/x64/iscan-gt-f720-bundle-2.30.4.x64.deb.tar.gz
    [gt-s600]=https://download2.ebz.epson.net/iscan/plugin/gt-s600/deb/x64/iscan-gt-s600-bundle-2.30.4.x64.deb.tar.gz
    [gt-s650]=https://download2.ebz.epson.net/iscan/plugin/gt-s650/deb/x64/iscan-gt-s650-bundle-2.30.4.x64.deb.tar.gz
)

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
        FALSE gt-f670 'Perfection Photo V200' GT-F670 \
        FALSE gt-f700 'Perfection V350 Photo' GT-F700 \
        FALSE gt-f720 'Perfection V30/V300 Photo' GT-S620/GT-F720 \
        FALSE gt-s600 'Perfection V10/V100 Photo' GT-S600/GT-F650 \
        FALSE gt-s650 'Perfection V19/V39' GT-S650
)"

trap trap_exit EXIT
trap_exit(){
    if test -v temp_dir \
        && test -e "${temp_dir}"; then
        rm \
            -rf \
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

# Download plugin package from _plugin_package_download_url_, and place
# it in _download_dir_
download_plugin_package(){
    local plugin_package_download_url="${1}"; shift
    local download_dir="${1}"; shift

    pushd "${download_dir}" >/dev/null
        curl \
            --location \
            --remote-header-name \
            --remote-name \
            --verbose \
            --fail \
            "${plugin_package_download_url}"
    popd >/dev/null
}

# Detect plugin package type(deb_bundle/rpm) from _package_filename_
detect_plugin_package_type(){
    local package_filename="${1}"; shift

    case "${package_filename}" in
        iscan-*-bundle-*.*.deb.tar.gz)
            printf deb_bundle
        ;;
        *.rpm)
            printf rpm
        ;;
        *)
            printf unknown
        ;;
    esac
}

# Unpack _bundle_package_ that contains the plugin package to the
# _bundle_unpack_dir_
unpack_deb_bundle_package(){
    local bundle_package="${1}"; shift
    local bundle_unpack_dir="${1}"; shift

    pushd "${bundle_unpack_dir}" >/dev/null
        tar \
            --extract \
            --verbose \
            --file "${bundle_package}"
    popd >/dev/null
}

# Unpack _plugin_package_(which should be a FHS-like file system tree)
# with _package_type_ to _extract_dir_
unpack_plugin_package(){
    local plugin_package="${1}"; shift
    local package_type="${1}"; shift
    local extract_dir="${1}"; shift

    case "${package_type}" in
        deb_bundle)
            dpkg-deb \
                --vextract \
                "${plugin_package}" \
                "${extract_dir}"
        ;;
        rpm)
            printf 'FATAL: Not implemented yet.\n' 1>&2
            exit 99
        ;;
        *)
            printf 'FATAL: Design error, report bug.\n' 1>&2
            exit 99
        ;;
    esac
}

# Install _plugin_files_ from _extract_dir_
install_plugin_files(){
    local extract_dir="${1}"; shift

    for plugin_file in extract/usr/lib/iscan/*.so*; do
    mv \
        --verbose \
        "${plugin_file}" \
        "${SNAP_USER_COMMON}/plugins/"
    done
    for firmware_file in \
        "${extract_dir}/usr/share/iscan/"*.bin \
        "${extract_dir}/usr/share/esci/"*.bin; do
        mv \
            --verbose \
            "${firmware_file}" \
            "${SNAP_USER_COMMON}/firmware/"
    done
    for device_file in "${extract_dir}/usr/share/iscan-data/device/"*.xml; do
        mv \
            --verbose \
            "${device_file}" \
            "${SNAP_USER_COMMON}/device/"
    done
}

# Register plugin to iscan, for debian bundle package we can rely on
# its post-installation script
register_iscan_plugin(){
    local plugin="${1}"; shift
    local plugin_package="${1}"; shift
    local package_type="${1}"; shift
    local temp_dir="${1}"; shift

    # Remove duplicate entries
    sed \
        --in-place \
        --expression "/${plugin}/d" \
        "${SNAP_USER_COMMON}/state/interpreter"

    case "${package_type}" in
        deb_bundle)
            pushd "${temp_dir}" >/dev/null
                dpkg-deb \
                    --ctrl-tarfile \
                    "${plugin_package}" \
                    | tar \
                        --extract \
                        ./postinst

                sed \
                    --in-place \
                    --expression "s@/usr/lib/iscan@${SNAP_USER_COMMON}/plugins@g" \
                    --expression "s@/usr/lib/esci@${SNAP_USER_COMMON}/plugins@g" \
                    postinst
                ./postinst
            popd >/dev/null
        ;;
        rpm)
            printf 'FATAL: Not implemented yet.\n' 1>&2
            exit 99
        ;;
        *)
            printf 'FATAL: Design error, report bug.\n' 1>&2
            exit 99
        ;;
    esac

}

for plugin in ${plugins}; do
    temp_dir="$(
        mktemp \
            --directory \
            --tmpdir \
            "${script_name}.${plugin}.XXX"
    )"
    package_dir="${temp_dir}/package"
    bundle_unpack_dir="${temp_dir}/bundle-unpack"
    extract_dir="${temp_dir}/extract"
    mkdir \
        "${package_dir}" \
        "${bundle_unpack_dir}" \
        "${extract_dir}"

    plugin_package_download_url="${PLUGIN_PACKAGE_DOWNLOAD_URLS["${plugin}"]}"
    package_filename="${plugin_package_download_url##*/}"
    downloaded_plugin_package="${package_dir}/${package_filename}"

    download_plugin_package \
        "${plugin_package_download_url}" \
        "${package_dir}"

    package_type="$(detect_plugin_package_type "${package_filename}")"
    case "${package_type}" in
        deb_bundle)
            unpack_deb_bundle_package \
                "${downloaded_plugin_package}" \
                "${bundle_unpack_dir}"
            flag_plugin_package_found=false
            for possible_plugin_package in \
                "${bundle_unpack_dir}/iscan-"*"-bundle-"*".deb/plugins/iscan-plugin-"*".deb" \
                "${bundle_unpack_dir}/iscan-"*"-bundle-"*".deb/plugins/esci-interpreter-"*".deb"; do
                flag_plugin_package_found=true
                plugin_package="${possible_plugin_package}"
            done
            if test "${flag_plugin_package_found}" == false; then
                printf 'Error: Unable to locate the plugin package in the bundle package.\n' 1>&2
                exit 1
            fi
        ;;
        rpm)
            plugin_package="${downloaded_plugin_package}"
        ;;
        unknown)
            printf 'Error: Plugin package type cannot be determined.\n' 1>&2
            exit 1
        ;;
        *)
            printf 'FATAL: Design error, report bug.\n' 1>&2
            exit 99
        ;;
    esac

    unpack_plugin_package \
        "${plugin_package}" \
        "${package_type}" \
        "${extract_dir}"

    install_plugin_files \
        "${extract_dir}"

    register_iscan_plugin \
        "${plugin}" \
        "${plugin_package}" \
        "${package_type}" \
        "${temp_dir}"

    rm -rf \
        "${temp_dir}"
done
zenity \
    --title 'Info' \
    --width 640 \
    --info \
    --text 'Install completed without errors.'
