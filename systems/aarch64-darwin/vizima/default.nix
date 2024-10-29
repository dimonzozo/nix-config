{
  ...
}:
{
  internal = {
    suites = {
      common.enable = true;
      development.enable = true;
    };

    user = {
      name = "dmyaskovskiy";
      fullName = "Dmitrii Miaskovskii";
      email = "dmitry@enapter.com";
      uid = 501;
    };

    system = {
      apps = {
        msOffice = true;
        desktopTeams = true;
        desktopMiro = true;
        extra = [
          "exodus"
          "prosys-opc-ua-browser"
          "roon"
          "steam"
          "vlc"
          "vscodium"
          "wireshark"
        ];
      };
    };
  };

  system.stateVersion = 4;
}
