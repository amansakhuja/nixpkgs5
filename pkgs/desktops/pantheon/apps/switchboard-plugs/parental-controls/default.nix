{ lib
, stdenv
, fetchFromGitHub
, nix-update-script
, meson
, ninja
, pkg-config
, vala
, libgee
, granite
, gtk3
, switchboard
, polkit
, flatpak
, malcontent
, libhandy
, accountsservice
, systemd
, dbus
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-parental-controls";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = pname;
    rev = version;
    sha256 = "0cga4mncbw8qx5w7vf07vqxl04a7s4rs8q9123p6m1bgj6arj9jl";
  };

  passthru = {
    updateScript = nix-update-script {
      attrPath = "pantheon.${pname}";
    };
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    granite
    gtk3
    libgee
    switchboard
    polkit
    flatpak
    malcontent
    libhandy
    accountsservice
    systemd
    dbus
  ];

  # daemon needs writable directory, so GUI can edit config. file
  mesonFlags = [
    "-Dsysconfdir=/var/lib"
    "-Dsysconfdir_install=${placeholder "out"}/var/lib"
  ];

  # needed for install to succeed
  PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";

  meta = with lib; {
    description = "Switchboard Screen Time & Limits Plug";
    homepage = "https://github.com/elementary/switchboard-plug-parental-controls";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.pantheon.members;
  };
}
