{ stdenv,
  lib,
  rustPlatform,
  name,
  pkgSources,
  git,
  cargo,
  rustc,
  rustfmt,
  libusb1,
  systemd,
  freetype,
  expat,
  fontconfig,
  pkg-config, 
  power-profiles-daemon
}:
let
  egui_ver = pkgSources."egui".version;
  egui_hash = (with builtins; fromJSON (readFile ../../_sources/generated.json))."egui".src.sha256;
in
rustPlatform.buildRustPackage rec {
  inherit (pkgSources."${name}") pname version src;

  buildInputs = [ git cargo rustc rustfmt systemd libusb1 freetype expat fontconfig ];
  nativeBuildInputs = [ pkg-config power-profiles-daemon ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "eframe-${egui_ver}" = egui_hash;
      "egui-${egui_ver}" = egui_hash;
      "egui-winit-${egui_ver}" = egui_hash;
      "egui_glow-${egui_ver}" = egui_hash;
      "emath-${egui_ver}" = egui_hash;
      "epaint-${egui_ver}" = egui_hash;
    };
  };
  doCheck = false;

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/tmp
    make DESTDIR=$out/tmp install
    mv $out/tmp/usr/* $out/
    mv $out/tmp/etc $out/
    rm -r $out/tmp
    rm -r $out/lib
  '';

  meta = with lib; {
    inherit version;
    description = "A control daemon, CLI tools, and a collection of crates for interacting with ASUS ROG laptops";
    homepage = "https://asus-linux.org/";
    license = licenses.mpl20;
  };
}
