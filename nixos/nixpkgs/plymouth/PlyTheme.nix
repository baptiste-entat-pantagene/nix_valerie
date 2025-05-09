{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "plymouthsmoothbrainkitty";
  version = "1.0";
  src = ./plymouthsmoothbrainkitty.tar.gz;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plymouth/themes/
    tar -xvf $src -C $out/share/plymouth/themes/
    substituteInPlace $out/share/plymouth/themes/plymouthsmoothbrainkitty/*.plymouth --replace '@ROOT@' "$out/share/plymouth/themes/plymouthsmoothbrainkitty/"

    runHook postInstall
  '';
}
