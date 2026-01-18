{
  pkgs,
  ...
}:
let
  folder = "default";
in
{
  programs.librewolf = {
    enable = true;

    profiles = {
      default = {
        isDefault = true;
        path = "${folder}";
        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";
          engines = {
            "youtube" = {
              urls = [
                {
                  template = "https://www.youtube.com/results?search_query={searchTerms}";
                }
              ];
              icon = "https://www.youtube.com/favicon.ico";
              definedAliases = [ "!yt" ];
            };
            "Github" = {
              urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
              icon = "https://github.githubassets.com/favicons/favicon-dark.png";
              definedAliases = [ "!gh" ];
            };
            "NixOS Package" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages?channel=25.11&from=0&size=50&sort=relevance&type=packages&query={searchTerms}";
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "!np" ];
            };
          };
        };
        id = 0;

        # about:config
        settings = {
          "privacy.clearOnShutdown.cache" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

          "browser.startup.page" = 3;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.uiCustomization.state" = builtins.readFile ./toolbar.json;
          "extensions.activeThemeID" = "{21c3f603-d43d-4a58-bf53-5190e4352324}";

          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # sidebar
          "sidebar.verticalTabs" = true;
        };
      };
    };

    policies = {
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };

        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };

        # Chameleon
        "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/chameleon-ext/latest.xpi";
          installation_mode = "force_installed";
        };

        # ClearURLs
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
          installation_mode = "force_installed";
        };

        # Skip Redirect
        "skipredirect@sblask" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/skip-redirect/latest.xpi";
          installation_mode = "force_installed";
        };

        # Firefox Multi-Account Containers
        "@testpilot-containers" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
          installation_mode = "force_installed";
        };

        # Temporary Containers
        "{c607c8df-14a7-4f28-894f-29e8722976af}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/temporary-containers/latest.xpi";
          installation_mode = "force_installed";
        };

        # SponsorBlock
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };

        # nightTab
        "{47bf427e-c83d-457d-9b3d-3db4118574bd}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/nighttab/latest.xpi";
          installation_mode = "force_installed";
        };

        # Stylus
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
          installation_mode = "force_installed";
        };

        # Lostsand
        "{21c3f603-d43d-4a58-bf53-5190e4352324}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/lostsand/latest.xpi";
          installation_mode = "force_installed";
        };

        # Hide Youtube Shorts
        "{88ebde3a-4581-4c6b-8019-2a05a9e3e938}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/hide-youtube-shorts/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
