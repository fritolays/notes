# mkfimgm.sh: formatted disk images created on the Sipeed NanoKVM

`mkfimgm.sh` creates an empty, formatted disk image on a
[Sipeed NanoKVM](https://github.com/sipeed/NanoKVM). The image can then be
mounted on a folder to load files into it, all from the NanoKVM's terminal.

It was prompted by needing a means of mounting a FAT32 "img/usb" to load a new
BIOS.

An image is just a blank drive of the size you set. Once the NanoKVM presents
it, the computer can repartition and reformat it like any USB stick, for
example to make it bootable or set it up for UEFI. Those setups are beyond the
scope of this script, which only makes plain FAT32 and exFAT images.

## Install

Copy `mkfimgm.sh` to `/data` on the NanoKVM. Nothing else is needed: the
script only uses tools the NanoKVM already has (BusyBox `mkdosfs` for FAT32,
`mkfs.exfat` for exFAT). Run it with `sh`, so it doesn't have to be
executable.

## Usage

`sh mkfimgm.sh -h` prints:

```
mkfimgm - make an empty, formatted disk image (FAT32 or exFAT), or mount one

Usage: mkfimgm.sh [-s SIZE] [-l LABEL] [-o NAME]   make an image
       mkfimgm.sh -m FILE                          mount or unmount one

  -s SIZE   image size, 33m to 8t                     (default: 4g)
            number with a m/g/t suffix, e.g. 700m, 2g, 10g.
            Up to 4g is formatted FAT32, anything larger exFAT.
            2k is subtracted from set size for compatibility.
  -l LABEL  volume label, truncated to 11 characters  (default: 76549114736)
            ASCII characters only.
  -o NAME   output file name                          (default: 476549114736)
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

Example: mkfimgm.sh -s 2g -l BACKUP -o disc   (makes disc-2g-fat32.img)
         mkfimgm.sh -m disc-2g-fat32.img      (mounts it on ./disc-2g-fat32)
```

- **Unmount before you attach.** Run `-m` again before mounting an image from
  the NanoKVM's image menu, so the NanoKVM and the computer never write to it
  at the same time. The script won't format or mount an image the NanoKVM is
  presenting, and if one does end up in both places, `-m` still unmounts it.
- **Interrupted runs clean up after themselves.** If making an image fails or
  the terminal closes, the half-made image is removed, and so is a newly
  created mount folder.

## Example: a FAT32 stick for a BIOS update

In the NanoKVM's terminal:

```sh
cd /data
sh mkfimgm.sh -s 1g -l BIOS -o bios     # make bios-1g-fat32.img
sh mkfimgm.sh -m bios-1g-fat32.img      # mount it on /data/bios-1g-fat32
cp BIOSFILE.CAP bios-1g-fat32/          # copy your files onto it
sh mkfimgm.sh -m bios-1g-fat32.img      # unmount it and remove the folder
```

The script reports each step:

```
bios-1g-fat32.img 'BIOS' (FAT32) 1073739776 bytes allocated
bios-1g-fat32.img mounted on /data/bios-1g-fat32
bios-1g-fat32.img unmounted from /data/bios-1g-fat32
```

Making an image writes all of it to the SD card, which can take a while: about
10 MB/s on the tested unit, so roughly 100 seconds for 1g.

Then mount `bios-1g-fat32.img` from the NanoKVM's image menu using Mass Storage
mode. The computer sees a FAT32 USB drive labelled `BIOS`, and the BIOS flash
tool can read the files on it.

## Tested on

A Sipeed NanoKVM with BusyBox 1.36.1, Linux 5.10 (riscv64) and exfatprogs
1.2.2. The images work as USB drives in Windows and in the BIOS; macOS hasn't
been tried.
