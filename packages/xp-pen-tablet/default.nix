{ stdenv,
  lib,
  name,
  pkgSources,
  fetchurl,
  autoPatchelfHook,
  libsForQt5,
  libusb1,
  glibc,
  libGL,
  xorg,
  libX11,
  libXtst,
  libXi,
  libXrandr,
  libXinerama,
}:
let
  pkg_url = (with builtins; fromJSON (readFile ../../_sources/generated.json))."xp-pen-tablet".src.url;
  pkg_sha256 = (with builtins; fromJSON (readFile ../../_sources/generated.json))."xp-pen-tablet".src.sha256;
  mkDerivation = libsForQt5.callPackage ({ mkDerivation }: mkDerivation) {};
in
mkDerivation rec {
  inherit (pkgSources."${name}") pname version;
  src = fetchurl {
    url = pkg_url;
    sha256 = pkg_sha256;
    name = "xp-pen-tablet-${version}.x86_64.tar.gz";
  };

  nativeBuildInputs = [ autoPatchelfHook libsForQt5.wrapQtAppsHook ];

  buildInputs = [
      libusb1
      libX11
      libXtst
      libXi
      libXrandr
      libXinerama
      glibc
      libGL
      stdenv.cc.cc.lib
      libsForQt5.qtx11extras
    ];

  installPhase = ''
    mkdir -p $out/{etc,lib,share}

    cp -r App/etc/* $out/etc
    cp -r App/lib/* $out/lib
    cp -r App/usr/lib/* $out/lib
    cp -r App/usr/share/* $out/share

    chmod 644 $out/lib/udev/rules.d/10-xp-pen.rules

    #make those executable
    chmod 755 $out/lib/pentablet/pentablet.sh
    chmod 755 $out/lib/pentablet/pentablet

    #fix license permissions
    chmod 644 $out/lib/pentablet/LGPL

    #config is global so everyone needs write access
    chmod 666 $out/lib/pentablet/conf/xppen/config.xml

    #minimize GUI on autostart
    sed -re 's/(^Exec=\/.+)/\1 \/mini/gi' -i $out/etc/xdg/autostart/xppentablet.desktop
  '';

  meta = with lib; {
    inherit version;
    description = "XP-Pen (Official) Linux utility (New UI driver)";
    homepage = "https://www.xp-pen.com/download/index.html";
    license = licenses.lgpl3Only;
  };
}