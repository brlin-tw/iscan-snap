#!/usr/bin/env bash
# Install non-free EPSON scanner plugins
# Copyright 2022 林博仁(Buo-ren, Lin) <Buo.Ren.Lin@gmail.com>
# SPDX-License-Identifier: MIT
set \
    -o \
    errexit \
    nounset \
    pipefail
shopt -s nullglob

SNAP_USER_COMMON="${SNAP_USER_COMMON:-"${HOME}/snap/iscan/common"}"
declare -A PLUGIN_PACKAGE_DOWNLOAD_URLS=(
    [cx4400]=https://download2.ebz.epson.net/iscan/plugin/cx4400/deb/x64/iscan-cx4400-bundle-2.30.4.x64.deb.tar.gz
    [ds-30]=https://download2.ebz.epson.net/iscan/plugin/ds-30/deb/x64/iscan-ds-30-bundle-2.30.4.x64.deb.tar.gz
    [gt-1500]=https://download2.ebz.epson.net/iscan/plugin/gt-1500/deb/x64/iscan-gt-1500-bundle-2.30.4.x64.deb.tar.gz
    [gt-f500]=http://download.ebz.epson.net/dsc/f/01/00/01/58/54/1899fd522665e4b1c80fe95252838994192d5207/iscan-plugin-gt-f500-1.0.0-1.c2.i386.rpm
    [gt-f670]=https://download2.ebz.epson.net/iscan/plugin/gt-f670/deb/x64/iscan-gt-f670-bundle-2.30.4.x64.deb.tar.gz
    [gt-f700]=https://download2.ebz.epson.net/iscan/plugin/gt-f700/deb/x64/iscan-gt-f700-bundle-2.30.4.x64.deb.tar.gz
    [gt-f720]=https://download2.ebz.epson.net/iscan/plugin/gt-f720/deb/x64/iscan-gt-f720-bundle-2.30.4.x64.deb.tar.gz
    [gt-s600]=https://download2.ebz.epson.net/iscan/plugin/gt-s600/deb/x64/iscan-gt-s600-bundle-2.30.4.x64.deb.tar.gz
    [gt-s650]=https://download2.ebz.epson.net/iscan/plugin/gt-s650/deb/x64/iscan-gt-s650-bundle-2.30.4.x64.deb.tar.gz
    [gt-s80]=https://download2.ebz.epson.net/iscan/plugin/gt-s80/deb/x64/iscan-gt-s80-bundle-2.30.4.x64.deb.tar.gz
    [gt-x750]=https://download2.ebz.epson.net/iscan/plugin/gt-x750/deb/x64/iscan-gt-x750-bundle-2.30.4.x64.deb.tar.gz
    [gt-x770]=https://download2.ebz.epson.net/iscan/plugin/gt-x770/deb/x64/iscan-gt-x770-bundle-2.30.4.x64.deb.tar.gz
    [gt-x820]=https://download2.ebz.epson.net/iscan/plugin/gt-x820/deb/x64/iscan-gt-x820-bundle-2.30.4.x64.deb.tar.gz
    [perfection-v330]=https://download2.ebz.epson.net/iscan/plugin/perfection-v330/deb/x64/iscan-perfection-v330-bundle-2.30.4.x64.deb.tar.gz
    [perfection-v370]=https://download2.ebz.epson.net/iscan/plugin/perfection-v370/deb/x64/iscan-perfection-v370-bundle-2.30.4.x64.deb.tar.gz
    [perfection-v550]=https://download2.ebz.epson.net/iscan/plugin/perfection-v550/deb/x64/iscan-perfection-v550-bundle-2.30.4.x64.deb.tar.gz
)

trap trap_exit EXIT
trap_exit(){
    if test -v temp_dir \
        && test -e "${temp_dir}"; then
        rm \
            -rf \
            "${temp_dir}"
    fi

    rm \
        -f \
        /tmp/install-non-free-plugins.log
}

trap_err(){
    zenity \
        --title 'Error' \
        --width 640 \
        --error \
        --text 'Install terminated prematurely with errors, if it appears to be a software bug please report it at &lt;https://github.com/brlin-tw/iscan-snap/issues&gt; with the log attached in the next dialog.'
    zenity \
        --title='Debug logs' \
        --width=640 \
        --height=360 \
        --text-info \
        --filename="/tmp/install-non-free-plugins.log" \
        --ok-label='Continue'
}
trap trap_err ERR

# Download plugin package from _plugin_package_download_url_, and place
# it in _download_dir_
download_plugin_package(){
    local plugin_package_download_url="${1}"; shift
    local download_dir="${1}"; shift

    local flag_download_failed=false
    pushd "${download_dir}" >/dev/null
        if ! curl \
            --fail \
            --location \
            --remote-header-name \
            --remote-name \
            --verbose \
            "${plugin_package_download_url}"; then
            printf \
                '%s: Error: Unable to download the plugin package from the "%s" URL.\n' \
                "${FUNCNAME[0]}" \
                "${plugin_package_download_url}" \
                1>&2
            flag_download_failed=true
        fi
    popd >/dev/null
    if test "${flag_download_failed}" == true; then
        return 1
    fi
}

# Detect plugin package type(deb_bundle/rpm) from _package_filename_
detect_plugin_package_type(){
    local package_filename="${1}"; shift

    case "${package_filename}" in
        iscan-*-bundle-*.*.deb.tar*)
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
            pushd "${extract_dir}" >/dev/null
                RPMRC=/dev/null \
                    rpm2cpio "${plugin_package}" \
                    | cpio \
                        -i \
                        --make-directories
            popd >/dev/null
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

    for plugin_file in \
        "${extract_dir}/usr/lib/iscan/"*.so* \
        "${extract_dir}/usr/lib/esci/"*.so*; do
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
    if test -e "${SNAP_USER_COMMON}/state/interpreter"; then
        sed \
            --in-place \
            --expression "/${plugin}/d" \
            "${SNAP_USER_COMMON}/state/interpreter"
    fi

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
            # Some plugins don't include plugin registration scripts,
            # implement them here
            case "${plugin}" in
                gt-f500)
                    iscan-registry \
                        --add interpreter usb 0x04b8 0x0121 \
                        "${SNAP_USER_COMMON}/plugins/libesint41" \
                        /usr/share/iscan/esfw41.bin
                ;;
                *)
                    printf 'FATAL: Not implemented yet.\n' 1>&2
                    exit 199
                ;;
            esac
        ;;
        *)
            printf 'FATAL: Design error, report bug.\n' 1>&2
            exit 99
        ;;
    esac
}

# Enable Logging #
# https://stackoverflow.com/questions/18460186/writing-outputs-to-log-file-and-console
exec 1> >(tee /tmp/install-non-free-plugins.log) 2>&1

script_filename="${BASH_SOURCE##*/}"
script_name="${script_filename%%.*}"
zenity_list_data=(
    FALSE cx4400 'Stylus CX4300/CX4400/CX5500/CX5600/DX4400' 'N/A'
    FALSE ds-30 'WorkForce DS-30' DS-30
    FALSE gt-1500 GT-1500 GT-D1000
    FALSE gt-f500 'Perfection 2480/2580 Photo' GT-F500/GT-F550
    FALSE gt-f670 'Perfection Photo V200' GT-F670
    FALSE gt-f700 'Perfection V350 Photo' GT-F700
    FALSE gt-f720 'Perfection V30/V300 Photo' GT-S620/GT-F720
    FALSE gt-s600 'Perfection V10/V100 Photo' GT-S600/GT-F650
    FALSE gt-s650 'Perfection V19/V39' GT-S650
    FALSE gt-s80 'GT-S50/GT-S55/GT-S80/GT-S85' ES-D200/ES-D350/ES-D400
    FALSE gt-x750 'Perfection 4490 Photo' GT-X750
    FALSE gt-x770 'Perfection V500 Photo' GT-X770
    FALSE gt-x820 'Perfection V600 photo' GT-X820
    FALSE perfection-v330 'Perfection V33/V330 Photo' GT-F730/GT-S630
    FALSE perfection-v370 'Perfection V37/V370' GT-F740/GT-S640
    FALSE perfection-v550 "Perfection V550 Photo" N/A
)
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
        "${zenity_list_data[@]}" \
        || true
)"
if test -z "${plugins}"; then
    exit 0
fi

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

    if ! download_plugin_package \
        "${plugin_package_download_url}" \
        "${package_dir}"; then
        printf \
            'Error: Unable to download the plugin package for the "%s" plugin.\n' \
            "${plugin}" \
            1>&2
        continue
    fi

    package_type="$(detect_plugin_package_type "${package_filename}")"
    case "${package_type}" in
        deb_bundle)
            if ! unpack_deb_bundle_package \
                "${downloaded_plugin_package}" \
                "${bundle_unpack_dir}"; then
                printf 'Error: Unable to unpack the Debian bundle package for the "%s" plugin.\n' \
                    "${plugin}" \
                    1>&2
                continue
            fi
            flag_plugin_package_found=false
            for possible_plugin_package in \
                "${bundle_unpack_dir}/iscan-"*"-bundle-"*".deb/plugins/iscan-plugin-"*".deb" \
                "${bundle_unpack_dir}/iscan-"*"-bundle-"*".deb/plugins/esci-interpreter-"*".deb"; do
                flag_plugin_package_found=true
                plugin_package="${possible_plugin_package}"
            done
            if test "${flag_plugin_package_found}" == false; then
                printf 'Error: Unable to locate the plugin package in the bundle package for the "%s" plugin.\n' \
                    "${plugin}" \
                    1>&2
                continue
            fi
        ;;
        rpm)
            plugin_package="${downloaded_plugin_package}"
        ;;
        unknown)
            printf 'Error: Plugin package type cannot be determined for the "%s" plugin.\n' \
                "${plugin}" \
                1>&2
            continue
        ;;
        *)
            printf 'FATAL: Design error, report bug.\n' 1>&2
            exit 99
        ;;
    esac

    if ! unpack_plugin_package \
        "${plugin_package}" \
        "${package_type}" \
        "${extract_dir}"; then
        printf 'Error: Unable to unpack the plugin package for the "%s" plugin.\n' \
            "${plugin}" \
            1>&2
        continue
    fi

    if ! install_plugin_files \
        "${extract_dir}"; then
        printf 'Error: Unable to install the plugin files for the "%s" plugin.\n' \
            "${plugin}" \
            1>&2
        continue
    fi

    if ! register_iscan_plugin \
        "${plugin}" \
        "${plugin_package}" \
        "${package_type}" \
        "${temp_dir}"; then
        printf 'Error: Unable to register the "%s" plugin.\n' \
            "${plugin}" \
            1>&2
        continue
    fi

    rm -rf \
        "${temp_dir}"
done
zenity \
    --title 'Info' \
    --width 640 \
    --info \
    --text 'Install completed without errors.'
