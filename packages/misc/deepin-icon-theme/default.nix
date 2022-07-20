{ stdenv
, lib
, fetchFromDeepin
, readVersion
, gtk3
, xcursorgen
}:

stdenv.mkDerivation rec {
  pname = "deepin-icon-theme";
  version = readVersion pname;

  src = fetchFromDeepin {
    inherit pname;
    sha256 = "sha256-UC3PbqolcCbVrIEDqMovfJ4oeofMUGJag1A6u7X3Ml8=";
  };

  nativeBuildInputs = [ gtk3 xcursorgen ];

  postPatch = ''
    substituteInPlace Makefile --replace "PREFIX = /usr" "PREFIX = $out"
  '';

  meta = with lib; {
    description = "deepin icon theme";
    homepage = "https://github.com/linuxdeepin/deepin-icon-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
