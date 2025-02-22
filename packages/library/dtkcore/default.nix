{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkg-config
, cmake
, gsettings-qt
, wrapQtAppsHook
, lshw
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.6.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "a148240c0852939660780d367df2f118680631d6";
    sha256 = "sha256-EpZvqnqueSffNokzc7BldEUaF/6wSqoqz8ByXeylW4M=";
  };

  patches = [ ./0001-feat-add-foreignProductTypeName-func.patch ];

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    gsettings-qt
    lshw
    dtkcommon
  ];

  cmakeFlags = [
    "-DBUILD_DOCS=OFF"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
