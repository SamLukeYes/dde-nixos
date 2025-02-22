{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qtsvg
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-draw";
  version = "5.11.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-49RQQ52HR5aqzeVEjGm9vQpTOxhY7I0X724x/Bboo90=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-draw/commit/dac714fe603e1b77fc39952bfe6949852ee6c2d5.patch";
      sha256 = "sha256-zajxmKkZJT1lcyvPv/PRPMxcstF69PB1tC50gYKDlWA=";
    })
  ];

  fixServicePatch = ''
    substituteInPlace com.deepin.Draw.service \
      --replace "/usr/bin/deepin-draw" "$out/bin/deepin-draw"
  '';

  postPatch = fixServicePatch;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [ dtk  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  #separateDebugInfo = true;

  meta = with lib; {
    description = "Lightweight drawing tool for users to freely draw and simply edit images";
    homepage = "https://github.com/linuxdeepin/deepin-draw";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
