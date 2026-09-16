#!/bin/sh
# mkfimgm.sh - make an empty, formatted disk image of a set size, or mount one
# (revision 10)
#
# For the Sipeed NanoKVM, which presents image files to the host PC as USB
# drives. Images up to 4g are formatted FAT32 (busybox mkdosfs), larger ones
# exFAT (mkfs.exfat from exfatprogs), and are named after their size and
# format, e.g. disc-4g-fat32.img. With -m an image is loop-mounted on the
# NanoKVM itself, so files can be copied onto it; running -m again unmounts
# it. The image the NanoKVM is presenting is never formatted or mounted, and
# an existing image is only overwritten once the user confirms.
#
# Needs busybox ash (for ${var/x/y}, EPOCHREALTIME and local) and these
# commands, all present on the NanoKVM: cat, df, du, awk, dirname, truncate,
# mkdosfs, mkfs.exfat, rm, sync, ls, mkdir, rmdir, mount, umount, mountpoint.
#
# Run with no options, or -h, for usage. Exits 0 on success, non-zero on
# any error.

set -e

STAMP=${EPOCHREALTIME/./}           # current time in microseconds (ash/bash)

# default label: the last 11 digits of STAMP, which keeps growing while the
# NanoKVM is on (a label holds 11 characters)
DLABEL=$STAMP
while [ ${#DLABEL} -gt 11 ]; do DLABEL=${DLABEL#?}; done

usage() {
    cat <<HELP
mkfimgm - make an empty, formatted disk image (FAT32 or exFAT), or mount one

Usage: ${0##*/} [-s SIZE] [-l LABEL] [-o NAME]   make an image
       ${0##*/} -m FILE                          mount or unmount one

  -s SIZE   image size, 33m to 8t                     (default: 4g)
            number with a m/g/t suffix, e.g. 700m, 2g, 10g.
            Up to 4g is formatted FAT32, anything larger exFAT.
            2k is subtracted from set size for compatibility.
  -l LABEL  volume label, truncated to 11 characters  (default: $DLABEL)
            ASCII characters only.
  -o NAME   output file name                          (default: $STAMP)
            saved as NAME-SIZE-FORMAT.img, with SIZE in its largest whole
            unit, so -s 4096m -o disc makes disc-4g-fat32.img.
            A NAME ending in .img is used as it is, with nothing added.
            If NAME is a folder, the image gets the default name in it.
  -m FILE   mount image FILE, extension included, on a new folder in the
            current directory named after it without that extension, so
            disc-2g-fat32.img mounts on ./disc-2g-fat32. Run -m on the same
            FILE to unmount it and remove the folder. Takes no other options.
  -h        show this help

The -o default is the current Unix time in microseconds, and the -l
default is its last 11 digits.
The output directory must have enough free space for the whole image,
counting the space of an existing image that is overwritten.
An existing image is only overwritten if you answer y when asked.
The image the NanoKVM is presenting to the computer is never formatted
or mounted here.

Example: ${0##*/} -s 2g -l BACKUP -o disc   (makes disc-2g-fat32.img)
         ${0##*/} -m disc-2g-fat32.img      (mounts it on ./disc-2g-fat32)
HELP
    exit 0
}

die() { echo "ERROR: $*" >&2; exit 1; }

# the image the NanoKVM is presenting to the host over USB
LUN=/sys/kernel/config/usb_gadget/g0/functions/mass_storage.disk0/lun.0/file

# true if sysfs file $1 ($LUN or a loop device's backing_file) names image $2
holds() { [ "$2" -ef "$(cat "$1" 2>/dev/null)" ]; }

# -m folder name for image $1: its file name without the extension
folder_name() { local n=${1##*/}; echo "${n%.*}"; }

# exit with an error if image $1 is in use: attached to a loop device (say
# where it is mounted and how to unmount it) or mounted by the NanoKVM
check_not_mounted() {
    local f loop where
    for f in /sys/block/loop*/loop/backing_file; do
        holds "$f" "$1" || continue
        loop=${f%/loop/backing_file}
        loop=/dev/${loop##*/}
        # its mount point; /proc/mounts writes a space as \040
        where=$(awk -v d="$loop" '$1 == d { gsub(/\\040/, " ", $2); print $2; exit }' /proc/mounts)
        [ -n "$where" ] || die "$1 is attached to $loop but not mounted, skipping"
        holds "$LUN" "$1" && echo "WARNING: $1 is also mounted by the NanoKVM" >&2
        # -m can only unmount it from the folder it mounted it in
        [ "${where##*/}" = "$(folder_name "$1")" ] &&
            die "$1 is mounted on $where, run -m from $(dirname "$where") to unmount it"
        die "$1 is mounted on $where, unmount it with: umount '$where'"
    done
    if holds "$LUN" "$1"; then
        die "$1 is currently mounted by the NanoKVM, skipping"
    fi
}

[ $# -gt 0 ] || usage

# ---- mount (-m) --------------------------------------------------------

if [ "$1" = -m ]; then
    [ $# -ge 2 ] || die "-m needs a value"
    [ $# -eq 2 ] || die "-m cannot be combined with other options"
    IMG=$2
    case "$IMG" in -*) IMG=./$IMG ;; esac   # so mount doesn't read it as an option
    [ -f "$IMG" ] || die "not a regular file: $IMG"
    name=$(folder_name "$IMG")
    case "$name" in ''|.|..) die "no folder name in $IMG" ;; esac
    MNT=${PWD%/}/$name                  # full path, so messages show where it is

    # mounted on $MNT by an earlier -m: unmount it and remove the folder,
    # even when the NanoKVM has it too (this ends the double mount)
    dev=$(mountpoint -d "$MNT" 2>/dev/null) || dev=
    if holds "/sys/dev/block/$dev/loop/backing_file" "$IMG"; then
        umount "$MNT"
        sync                            # on the SD card before reporting success
        rmdir "$MNT"
        echo "$IMG unmounted from $MNT"
        exit 0
    fi

    check_not_mounted "$IMG"
    [ -z "$dev" ] || die "$MNT has something else mounted on it"
    if [ -e "$MNT" ]; then
        [ -d "$MNT" ] && [ -z "$(ls -A "$MNT")" ] ||
            die "$MNT exists and is not an empty folder"
    else
        mkdir "$MNT"
        trap 'rmdir "$MNT"' EXIT        # remove the new folder again
        trap 'exit 1' HUP INT TERM      # if the mount fails or is interrupted
    fi

    # FAT32 needs utf8, or non-ASCII file names written here reach the host
    # garbled; anything else (exFAT is UTF-8 already) is auto-detected
    mount -t vfat -o loop,utf8 "$IMG" "$MNT" 2>/dev/null ||
        mount -o loop "$IMG" "$MNT"

    trap - EXIT
    echo "$IMG mounted on $MNT"
    exit 0
fi

# ---- options -----------------------------------------------------------

SIZE=4g
LABEL=$DLABEL
NAME=$STAMP
while [ $# -gt 0 ]; do
    case "$1" in
        -s) SIZE=$2 ;;
        -l) LABEL=$2 ;;
        -o) NAME=$2 ;;
        -m) die "-m cannot be combined with other options" ;;
        -h) usage ;;
        *)  die "unknown option '$1' (try -h)" ;;
    esac
    [ $# -ge 2 ] || die "$1 needs a value"
    shift 2
done
[ -n "$NAME" ] || die "-o needs a value"

# plain ASCII only (space to ~): hosts show other characters in a FAT32
# label garbled, and the cut below counts bytes, so it could split one
case "$LABEL" in
    *[!\ -~]*) die "invalid label '$LABEL', use ASCII characters only" ;;
esac
LABEL=$(printf %.11s "$LABEL")      # FAT32 and exFAT labels hold 11 characters

# ---- size --------------------------------------------------------------

MIN=$((33 << 20))                   # 33m: smallest valid FAT32 (65525+ clusters)
MAX=$((1 << 43))                    # 8t: sanity limit

case "$SIZE" in
    *[kK]) bits=10 ;;
    *[mM]) bits=20 ;;
    *[gG]) bits=30 ;;
    *[tT]) bits=40 ;;
    *)     bits=0 ;;
esac
num=${SIZE%[kKmMgGtT]}
case "$num" in ''|0*|*[!0-9]*) die "invalid size '$SIZE' (try -h)" ;; esac
[ ${#num} -le 13 ] && [ "$num" -le $((MAX >> bits)) ] && [ $((num << bits)) -ge $MIN ] ||
    die "size '$SIZE' is outside 33m to 8t"

SIZE=$(( (num << bits) - 2048 ))    # 2k less, so 4g fits on FAT32
# FAT32 up to 4g, exFAT above it; fmt is the format part of the file name
if [ "$SIZE" -lt 4294967296 ]; then
    fs=FAT32 fmt=fat32
else
    fs=exFAT fmt=exfat
fi

# ---- output file -------------------------------------------------------

# NAME-SIZE-FORMAT.img with SIZE in its largest whole unit (4096m is 4g); a
# folder gets the default name in it, and a NAME ending in .img is used as is
n=$((num << bits)) unit=
for u in k m g t; do
    [ $((n % 1024)) -eq 0 ] || break
    n=$((n >> 10)) unit=$u
done
if [ -d "$NAME" ]; then
    OUT=${NAME%/}/$STAMP-$n$unit-$fmt.img
else
    case "$NAME" in
        *.[iI][mM][gG]) OUT=$NAME ;;
        *)              OUT=$NAME-$n$unit-$fmt.img ;;
    esac
fi
case "$OUT" in -*) OUT=./$OUT ;; esac   # so no tool reads the name as an option

dir=$(dirname "$OUT")
[ -d "$dir" ] || die "no such directory: $dir"
[ ! -e "$OUT" ] || [ -f "$OUT" ] || die "not a regular file: $OUT"
check_not_mounted "$OUT"

# free space, counting what an existing image frees when it is overwritten
avail=$(df -Pk "$dir" | awk 'NR == 2 { print $4 }')
freed=0
[ ! -f "$OUT" ] || freed=$(du -k "$OUT" | awk '{ print $1 }')
avail=$((${avail:-0} + ${freed:-0}))
[ "$avail" -ge $((SIZE / 1024)) ] ||
    die "not enough free space in $dir: need $((SIZE / 1024))k, have ${avail}k"

# an existing image is only overwritten once the user answers y
if [ -e "$OUT" ]; then
    printf '%s already exists, overwrite it? [y/N] ' "$OUT" >&2
    read -r answer || echo >&2          # no answer (end of input): end the line
    case "$answer" in
        [yY]|[yY][eE][sS]) ;;
        *) die "$OUT not overwritten" ;;
    esac
fi

# ---- create and format -------------------------------------------------

: > "$OUT"                          # start empty, so unwritten parts read as zeros
trap 'rm -f "$OUT"' EXIT            # from here on, remove the half-made image
trap 'exit 1' HUP INT TERM          # on any error or interruption
truncate -s "$SIZE" "$OUT"
if [ "$fs" = FAT32 ]; then
    mkdosfs -n "$LABEL" "$OUT"
else
    mkfs.exfat -q -L "$LABEL" "$OUT"
fi
sync                                # on the SD card before reporting success

trap - EXIT
echo "$OUT '$LABEL' ($fs) $SIZE bytes allocated"
