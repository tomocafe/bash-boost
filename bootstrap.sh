#!/bin/bash

# This is a script intended to be downloaded from the Internet
# to fetch the latest release and install it to a user-specified location.
# Do not use this if you cloned the repository with git.

error () {
    echo "error: $1" 1>&2
    exit "${2:-1}"
}

# check version
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    error "bash version too old: requires 4.2 or newer, have ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
elif [[ ${BASH_VERSINFO[0]} -eq 4 ]]; then
    if [[ ${BASH_VERSINFO[1]} -lt 2 ]]; then
        error "bash version too old: requires 4.2 or newer, have ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
    fi
fi

# must have interactive shell
if ! [[ -t 0 ]]; then
    error "not an interactive shell - this script requires user input"
fi

for cmd in curl mktemp; do
    command -v $cmd &>/dev/null || error "missing required tool: $cmd"
done

# process arguments
while [[ $# -gt 0 ]]; do
    tag="$1"
    shift
done

# find existing installation
if [[ -d "$BB_ROOT" ]]; then
    existing_install="${BB_ROOT%/*}"
else
    for prefix in /usr/{local/,}lib{,64} /opt/lib{,64}; do
        [[ -d "$prefix/bash-boost" ]] && { existing_install="$prefix/bash-boost"; break; }
    done
fi

# find recommended locations
for prefix in /usr/{local/,}lib{,64} /opt/lib{,64}; do
    [[ -d "$prefix" ]] && { default_system_location="$prefix/bash-boost"; break; }
done
[[ "$default_system_location" == "$existing_install" ]] && unset default_system_location
default_home_location="$HOME/.local/lib/bash-boost"
[[ "$default_home_location" == "$existing_install" ]] && unset default_home_location

# present options
options=()
if [[ -d "$existing_install" ]]; then
    echo "Found existing installation in $existing_install"
    options+=("$existing_install")
fi
[[ -n "$default_home_location" ]] && options+=("$default_home_location")
[[ -n "$default_system_location" ]] && options+=("$default_system_location")

if [[ "$PWD" != "$existing_install" ]] && [[ "$PWD" != "$default_home_location" ]] && [[ "$PWD" != "$default_system_location" ]]; then
    options+=("$PWD")
fi

if [[ ${#options[@]} -gt 0 ]]; then
    echo "Choose a destination to install:"
    i=1
    for opt in "${options[@]}"; do
        echo "$i: $opt"
        let i++
    done
    echo "Enter a number to select from the above destinations or type a path manually"
else
    echo "Enter destination directory to install:"
fi
printf '> '
read -r resp

dest_dir="$resp"
if [[ $resp =~ [0-9]+ ]]; then
    if [[ $resp -gt 0 ]] && [[ $resp -le "${#options[@]}" ]]; then
        let resp--
        dest_dir="${options[$resp]}"
    else
        error "choice out of range"
    fi
fi

# prepare temp space
temp="$(mktemp -d)"
cleanup () { rm -f "$temp" &>/dev/null; }
trap cleanup EXIT

# get the latest tag
base_url="https://github.com/tomocafe/bash-boost"
if [[ -z "$tag" ]]; then
    redirect="$(curl -ILs -o /dev/null -w %{url_effective} $base_url/releases/latest)"
    [[ $? -eq 0 ]] || error "failed to fetch latest version on the Internet"
    tag="${redirect##*/}"
    echo "Downloading latest version ($tag) ..."
else
    echo "Downloading $tag ..."
fi

# download tarball
tarball="bash-boost-${tag#v}.tar.gz"
cd "$temp"
curl -sL $base_url/releases/download/$tag/$tarball | tar xz
[[ $? -eq 0 ]] || error "failed to download and extract latest release from the Internet"

# prepare destination dir
[[ -d "$dest_dir" ]] || mkdir -p "$dest_dir" || error "could not create $dest_dir"
[[ -w "$dest_dir" ]] || error "cannot write to $dest_dir"

# move to destination dir
install_dir_name="${tarball%.tar.gz}"
if [[ -d "$dest_dir/$install_dir_name" ]]; then
    echo "$tag is already installed to $dest_dir/$install_dir_name"
    read -r -n1 -p "Do you want to overwrite the existing installation? (Yy) > " resp
    echo
    [[ $resp =~ ^[Yy]$ ]] || exit 0
    rm -rf "$dest_dir/$install_dir_name"
fi
mv "$temp/$install_dir_name" "$dest_dir"

# update latest link
read -r -n1 -p "Update the latest link to point to $tag? (Yy) > " resp
echo
if [[ $resp =~ ^[Yy]$ ]]; then
    rm -f "$dest_dir/latest" &>/dev/null
    ln -s "$dest_dir/$install_dir_name" "$dest_dir/latest"
fi

echo "Installation complete."
