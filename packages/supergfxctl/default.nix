{ stdenv,
  lib,
  rustPlatform,
  name,
  pkgSources,
  git,
  cargo,
  rustc,
  rustfmt,
  gcc,
  makeWrapper,
  kmod
}:

rustPlatform.buildRustPackage rec {
  inherit (pkgSources."${name}") pname version src;

  buildInputs = [ git cargo rustc rustfmt gcc makeWrapper ];
  nativeBuildInputs = [ kmod ];

  doCheck = false;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

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
  rm -r $out/tmp
  '';

  postFixup = ''
    wrapProgram $out/bin/supergfxd \
      --prefix PATH : ${lib.makeBinPath [ kmod ]}
  '';

  meta = with lib; {
    inherit version;
    description = "A utility for Linux graphics switching on Intel/AMD iGPU + nVidia dGPU laptops";
    homepage = "https://gitlab.com/asus-linux/supergfxctl";
    license = licenses.mpl20;
  };
}
