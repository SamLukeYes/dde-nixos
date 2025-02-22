{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, pkg-config
, qttools
, wrapQtAppsHook
, kcodecs
, syntax-highlighting
, libchardet
, libuchardet
, libiconv
, gtest
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-editor";
  version = "5.10.35";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-X3tsmtqMUSpYQZqCmgtCLCSGwzSmCZagF7TUWQYJsqU=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-editor/commit/7f4314f386a3c8f5cdea3618591b8eb027d034c3.patch";
      sha256 = "sha256-/aSBa2nILc/YrFchUyhBHHs2c7Mv6N1juwD5Sdc39Uo=";
    })
  ];

  postPatch = ''
    substituteInPlace src/common/utils.h --replace "/usr/share" "$out/share"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    kcodecs
    syntax-highlighting
    libchardet
    libuchardet
    libiconv
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "A desktop text editor that supports common text editing features";
    homepage = "https://github.com/linuxdeepin/deepin-editor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
