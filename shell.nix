{ pkgs ? import <nixpkgs> {} }:

let
  base = pkgs.appimageTools.defaultFhsEnvArgs;
in
(pkgs.buildFHSEnv (base // {
  name = "esa-snap-env";

  targetPkgs = pkgs:
    (base.targetPkgs pkgs) ++
    (with pkgs; [
      bash
      coreutils
      findutils
      gnugrep
      gnused
      which

      jdk17
      gtk3
      glib
      freetype
      fontconfig
      zlib

      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXtst
      xorg.libXi
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXfixes
      xorg.libXinerama

      libGL
      libGLU
      mesa
      alsa-lib
      cups
      dbus
      nspr
      nss
    ]);

  runScript = "bash";
})).env
