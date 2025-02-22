{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, buildGoPackage
, pkg-config
, go-dbus-factory
, go-gir-generator
, go-lib
, gettext
, dde-api
, libgnome-keyring
, gtk3
, alsa-lib
, libgudev
, libsecret
, jq
, glib
, wrapGAppsHook
, runtimeShell
, dde-daemon
, dde-polkit-agent
, dde-kwin
, gnome
, pciutils
}:
let
  patchList = {
    "session.go" = [
      [ "/usr/share/applications/dde-lock.desktop" "/run/current-system/sw/share/applications/dde-lock.desktop" ]
    ];
    "misc/lightdm.conf" = [
      # "/usr/sbin/deepin-fix-xauthority-perm" 
    ];
    "misc/Xsession.d/00deepin-dde-env" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
    ];
    "launch_group.go" = [
      # "/usr/share/startdde/auto_launch.json" 
    ];
    "memchecker/config.go" = [
      # /usr/share/startdde/memchecker.json 
    ];
  };
in
buildGoPackage rec {
  pname = "startdde";
  version = "5.10.1";

  goPackagePath = "github.com/linuxdeepin/startdde";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-dbTcYS7dEvT0eP45jKE8WiG9Pm4LU6jvR8hjMQv/yxU=";
  };

  postPatch = replaceAll "/bin/bash" "${runtimeShell}"
    + replaceAll "/bin/sh" "${runtimeShell}"
    + replaceAll "/usr/bin/kwin_no_scale" "${dde-kwin}/bin/kwin_no_scale"
    + replaceAll "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"
    + replaceAll "/usr/lib/polkit-1-dde/dde-polkit-agent" "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent"
    + replaceAll "/usr/bin/gnome-keyring-daemon" "${gnome.gnome-keyring}/bin/gnome-keyring-daemon"
    + replaceAll "/usr/bin/startdde" "$out/bin/startdde"
    + replaceAll "/usr/bin/dde-shutdown" "dde-shutdown"
    + replaceAll "/usr/bin/dde-file-manager" "dde-file-manager"
    + replaceAll "/usr/bin/dde-lock" "dde-lock"
    + replaceAll "/usr/bin/dde-dock" "dde-dock"
    + replaceAll "/usr/bin/dde-desktop" "dde-desktop"
    + replaceAll "/usr/bin/dde-hints-dialog" "dde-hints-dialog" 
    + replaceAll "/usr/bin/dde_wloutput" "dde_wloutput"
    + replaceAll "\"lspci\"" "\"${pciutils}/bin/lspci\"" 
    + getUsrPatchFrom patchList + ''
      substituteInPlace "startmanager.go"\
        --replace "/usr/share/startdde/app_startup.conf" "$out/share/startdde/app_startup.conf"
      substituteInPlace misc/xsessions/deepin.desktop.in --subst-var-by PREFIX $out
    '';

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    gettext
    pkg-config
    jq
    wrapGAppsHook
    glib
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    dde-api
    libgnome-keyring
    gtk3
    alsa-lib
    libgudev
    libsecret
  ];

  buildPhase = ''
    runHook preBuild
    GOPATH="$GOPATH:${go-dbus-factory}/share/gocode"
    GOPATH="$GOPATH:${go-gir-generator}/share/gocode"
    GOPATH="$GOPATH:${go-lib}/share/gocode"
    GOPATH="$GOPATH:${dde-api}/share/gocode"
    make -C go/src/${goPackagePath}
    runHook postBuild
  '';

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/" -C go/src/${goPackagePath}
  '';

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  passthru.providedSessions = [ "deepin" ];

  meta = with lib; {
    description = "starter of deepin desktop environment";
    longDescription = "Startdde is used for launching DDE components and invoking user's custom applications which compliant with xdg autostart specification";
    homepage = "https://github.com/linuxdeepin/startdde";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
