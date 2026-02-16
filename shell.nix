{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  name = "libvirt-qemu-research-env";
  buildInputs = [
    bash
    cdrkit cloud-utils coreutils curl
    findutils
    gawk git gnugrep gnumake
    jq
    procps
    unzip
  ];
}
