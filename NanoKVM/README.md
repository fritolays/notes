# mkfisom.sh: virtual USB sticks for the Sipeed NanoKVM

`mkfisom.sh` creates an empty, formatted disk image on a
[Sipeed NanoKVM](https://github.com/sipeed/NanoKVM). The image can then be
mounted on a folder to load files into it, all from the NanoKVM's terminal.

It was prompted by needing a means of mounting a FAT32 "iso/usb" to load a new
BIOS.

An image is just a blank drive of the size you set. Once the NanoKVM presents
it, the computer can repartition and reformat it like any USB stick, for
example to make it bootable or set it up for UEFI. Those setups are beyond the
scope of this script, which only makes plain FAT32 and exFAT images.

## Install

Copy `mkfisom.sh` to `/data` on the NanoKVM. Nothing else is needed: the
script only uses tools the NanoKVM already has (BusyBox `mkdosfs` for FAT32,
`mkfs.exfat` for exFAT). Run it with `sh`, so it doesn't have to be
executable.

## Example: a FAT32 stick for a BIOS update

In the NanoKVM's terminal:

```sh
cd /data
sh mkfisom.sh -s 1g -l BIOS -o bios     # make bios-1g-fat32.iso
sh mkfisom.sh -m bios-1g-fat32.iso      # mount it on /data/bios-1g-fat32
cp BIOSFILE.CAP bios-1g-fat32/          # copy your files onto it
sh mkfisom.sh -m bios-1g-fat32.iso      # unmount it and remove the folder
```

The script reports each step:

```
bios-1g-fat32.iso 'BIOS' (FAT32) 1073739776 bytes allocated
bios-1g-fat32.iso mounted on /data/bios-1g-fat32
bios-1g-fat32.iso unmounted from /data/bios-1g-fat32
```

Making an image writes all of it to the SD card, which can take a while: about
10 MB/s on the tested unit, so roughly 100 seconds for 1g.

Then mount `bios-1g-fat32.iso` from the NanoKVM's image menu using Mass Storage
mode. The computer sees a FAT32 USB drive labelled `BIOS`, and the BIOS flash
tool can read the files on it.

## Usage

```
sh mkfisom.sh [-s SIZE] [-l LABEL] [-o NAME]    make an image
sh mkfisom.sh -m FILE                           mount it, or unmount it
```

| Option | Meaning | Default |
|---|---|---|
| `-s SIZE` | Image size, 33m to 8t: a number with an m, g or t suffix, e.g. `700m`, `2g`, `10g`. Up to 4g is formatted FAT32, anything larger exFAT. 2k is subtracted from the set size for compatibility. | `4g` |
| `-l LABEL` | Volume label, ASCII characters only, truncated to 11 characters. | Last 11 digits of the time |
| `-o NAME` | Output file name, see below. | Current Unix time in microseconds |
| `-m FILE` | Mount an image on a folder in the current directory, named after FILE without its extension. Run it again with the same FILE to unmount it and remove the folder. Takes no other options. | |
| `-h` | Show the help. | |

Images are saved as `NAME-SIZE-FORMAT.iso`, with SIZE in its largest whole
unit:

| Command | Image |
|---|---|
| `sh mkfisom.sh -s 2g -o bios` | `bios-2g-fat32.iso` |
| `sh mkfisom.sh -s 4096m` | `<time>-4g-fat32.iso` |
| `sh mkfisom.sh -s 16g -o /data` | `/data/<time>-16g-exfat.iso` (a folder gets the default name) |
| `sh mkfisom.sh -s 2g -o bios.iso` | `bios.iso` (a name ending in `.iso` is used as it is) |

## Good to know

- **Unmount before you attach.** Run `-m` again before mounting an image from
  the NanoKVM's image menu, so the NanoKVM and the computer never write to it
  at the same time. The script won't format or mount an image the NanoKVM is
  presenting, and if one does end up in both places, `-m` still unmounts it.
- **Interrupted runs clean up after themselves.** If making an image fails or
  the terminal closes, the half-made image is removed, and so is a newly
  created mount folder.
- **`-m` mounts file system images only**, like the ones this script makes
  (ext2/3/4 work too). The NanoKVM's kernel has no ISO 9660 support, so it
  can't open real CD/DVD `.iso` files, though it still presents them to the
  computer as usual.

## Tested on

A Sipeed NanoKVM with BusyBox 1.36.1, Linux 5.10 (riscv64) and exfatprogs
1.2.2. The images work as USB drives in Windows and in the BIOS; macOS hasn't
been tried.
