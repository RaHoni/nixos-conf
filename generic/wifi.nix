{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) map listToAttrs;
  mkWifiSecret = name: {
    file = config.sops.secrets."wifi/${name}".path;
    key = "psk";
    matchId = name;
    matchSetting = "802-11-wireless-security";
  };
  mkEduroamSecret = name: key: {
    file = config.sops.secrets."wifi/${name}".path;
    inherit key;
    matchId = "eduroam";
    matchSetting = "802-1x";
  };
  wifiSops =
    names:
    listToAttrs (
      map (name: {
        name = "wifi/${name}";
        value = {
          sopsFile = self + /secrets/wifi/password.yaml;
        };
      }) names
    );
in
{
  sops.secrets = wifiSops [
    "Commander DATA"
    "Commander DATA WPA2"
    "FP4-RH"
    "eduroam-identity"
    "eduroam-password"
    "eduroam-ca-cert"
  ];
  networking.networkmanager = {
    plugins = [ pkgs.networkmanager-openconnect ];
    ensureProfiles = {
      secrets.entries = [
        (mkWifiSecret "Commander DATA")
        (mkWifiSecret "Commander DATA WPA2")
        (mkWifiSecret "FP4-RH")
        (mkEduroamSecret "eduroam-identity" "identity")
        (mkEduroamSecret "eduroam-password" "password")
      ];
      profiles = {
        "Commander DATA" = {
          connection = {
            id = "Commander DATA";
            permissions = "";
            timestamp = "1750231976";
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            address1 = "fd00::1:1/128";
            address2 = "fd00::1:1/64";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "Commander DATA";
          };
          wifi-security = {
            key-mgmt = "sae";
          };
        };
        "Commander DATA WPA2" = {
          connection = {
            id = "Commander DATA WPA2";
            interface-name = "wlp1s0";
            permissions = "user:raoul:;";
            autoconnect-priority = -1;
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "Commander DATA WPA2";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            leap-password-flags = "1";
            wep-key-flags = "1";
          };
        };
        FP4-RH = {
          connection = {
            id = "FP4-RH";
            interface-name = "wlp1s0";
            permissions = "user:raoul:;";
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "FP4-RH";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "sae";
            leap-password-flags = "1";
            wep-key-flags = "1";
          };
        };
        Freifunk = {
          connection = {
            id = "Freifunk";
            interface-name = "wlp1s0";
            permissions = "";
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "Freifunk";
          };

        };
        FH-VPN = {
          connection = {
            id = "FH Netz";
            type = "vpn";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          vpn = {
            cookie-flags = "2";
            enable_csd_trojan = "no";
            gateway = "vpn.fh-muenster.de";
            gateway-flags = "2";
            gwcert-flags = "2";
            pem_passphrase_fsid = "no";
            prevent_invalid_cert = "no";
            protocol = "anyconnect";
            reported_os = "android";
            service-type = "org.freedesktop.NetworkManager.openconnect";
            stoken_source = "disabled";
            stoken_string-flags = "1";
          };
          vpn-secrets = {
            autoconnect = "yes";
            "form:main:username" = "rh792919";
            lasthost = "VPN Portal FH-Muenster";
            save_passwords = "no";
            save_plaintext_cookies = "no";
            xmlconfig = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjxBbnlDb25uZWN0UHJvZmlsZSB4bWxucz0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvZW5jb2RpbmcvIiB4bWxuczp4c2k9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hLWluc3RhbmNlIiB4c2k6c2NoZW1hTG9jYXRpb249Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL2VuY29kaW5nLyBBbnlDb25uZWN0UHJvZmlsZS54c2QiPg0KCTxDbGllbnRJbml0aWFsaXphdGlvbj4NCgkJPFVzZVN0YXJ0QmVmb3JlTG9nb24gVXNlckNvbnRyb2xsYWJsZT0idHJ1ZSI+ZmFsc2U8L1VzZVN0YXJ0QmVmb3JlTG9nb24+DQoJCTxBdXRvbWF0aWNDZXJ0U2VsZWN0aW9uIFVzZXJDb250cm9sbGFibGU9InRydWUiPmZhbHNlPC9BdXRvbWF0aWNDZXJ0U2VsZWN0aW9uPg0KCQk8U2hvd1ByZUNvbm5lY3RNZXNzYWdlPmZhbHNlPC9TaG93UHJlQ29ubmVjdE1lc3NhZ2U+DQoJCTxDZXJ0aWZpY2F0ZVN0b3JlPkFsbDwvQ2VydGlmaWNhdGVTdG9yZT4NCgkJPENlcnRpZmljYXRlU3RvcmVNYWM+QWxsPC9DZXJ0aWZpY2F0ZVN0b3JlTWFjPg0KCQk8Q2VydGlmaWNhdGVTdG9yZUxpbnV4PkFsbDwvQ2VydGlmaWNhdGVTdG9yZUxpbnV4Pg0KCQk8Q2VydGlmaWNhdGVTdG9yZU92ZXJyaWRlPmZhbHNlPC9DZXJ0aWZpY2F0ZVN0b3JlT3ZlcnJpZGU+DQoJCTxQcm94eVNldHRpbmdzPk5hdGl2ZTwvUHJveHlTZXR0aW5ncz4NCgkJPEFsbG93TG9jYWxQcm94eUNvbm5lY3Rpb25zPnRydWU8L0FsbG93TG9jYWxQcm94eUNvbm5lY3Rpb25zPg0KCQk8QXV0aGVudGljYXRpb25UaW1lb3V0PjMwPC9BdXRoZW50aWNhdGlvblRpbWVvdXQ+DQoJCTxBdXRvQ29ubmVjdE9uU3RhcnQgVXNlckNvbnRyb2xsYWJsZT0idHJ1ZSI+ZmFsc2U8L0F1dG9Db25uZWN0T25TdGFydD4NCgkJPE1pbmltaXplT25Db25uZWN0IFVzZXJDb250cm9sbGFibGU9InRydWUiPnRydWU8L01pbmltaXplT25Db25uZWN0Pg0KCQk8TG9jYWxMYW5BY2Nlc3MgVXNlckNvbnRyb2xsYWJsZT0idHJ1ZSI+dHJ1ZTwvTG9jYWxMYW5BY2Nlc3M+DQoJCTxEaXNhYmxlQ2FwdGl2ZVBvcnRhbERldGVjdGlvbiBVc2VyQ29udHJvbGxhYmxlPSJ0cnVlIj5mYWxzZTwvRGlzYWJsZUNhcHRpdmVQb3J0YWxEZXRlY3Rpb24+DQoJCTxDbGVhclNtYXJ0Y2FyZFBpbiBVc2VyQ29udHJvbGxhYmxlPSJ0cnVlIj50cnVlPC9DbGVhclNtYXJ0Y2FyZFBpbj4NCgkJPElQUHJvdG9jb2xTdXBwb3J0PklQdjQsSVB2NjwvSVBQcm90b2NvbFN1cHBvcnQ+DQoJCTxBdXRvUmVjb25uZWN0IFVzZXJDb250cm9sbGFibGU9ImZhbHNlIj50cnVlDQoJCQk8QXV0b1JlY29ubmVjdEJlaGF2aW9yIFVzZXJDb250cm9sbGFibGU9ImZhbHNlIj5SZWNvbm5lY3RBZnRlclJlc3VtZTwvQXV0b1JlY29ubmVjdEJlaGF2aW9yPg0KCQk8L0F1dG9SZWNvbm5lY3Q+DQoJCTxTdXNwZW5kT25Db25uZWN0ZWRTdGFuZGJ5PmZhbHNlPC9TdXNwZW5kT25Db25uZWN0ZWRTdGFuZGJ5Pg0KCQk8QXV0b1VwZGF0ZSBVc2VyQ29udHJvbGxhYmxlPSJmYWxzZSI+dHJ1ZTwvQXV0b1VwZGF0ZT4NCgkJPFJTQVNlY3VySURJbnRlZ3JhdGlvbiBVc2VyQ29udHJvbGxhYmxlPSJmYWxzZSI+QXV0b21hdGljPC9SU0FTZWN1cklESW50ZWdyYXRpb24+DQoJCTxXaW5kb3dzTG9nb25FbmZvcmNlbWVudD5TaW5nbGVMb2NhbExvZ29uPC9XaW5kb3dzTG9nb25FbmZvcmNlbWVudD4NCgkJPExpbnV4TG9nb25FbmZvcmNlbWVudD5TaW5nbGVMb2NhbExvZ29uPC9MaW51eExvZ29uRW5mb3JjZW1lbnQ+DQoJCTxXaW5kb3dzVlBORXN0YWJsaXNobWVudD5BbGxvd1JlbW90ZVVzZXJzPC9XaW5kb3dzVlBORXN0YWJsaXNobWVudD4NCgkJPExpbnV4VlBORXN0YWJsaXNobWVudD5Mb2NhbFVzZXJzT25seTwvTGludXhWUE5Fc3RhYmxpc2htZW50Pg0KCQk8QXV0b21hdGljVlBOUG9saWN5PmZhbHNlPC9BdXRvbWF0aWNWUE5Qb2xpY3k+DQoJCTxQUFBFeGNsdXNpb24gVXNlckNvbnRyb2xsYWJsZT0iZmFsc2UiPkRpc2FibGUNCgkJCTxQUFBFeGNsdXNpb25TZXJ2ZXJJUCBVc2VyQ29udHJvbGxhYmxlPSJmYWxzZSI+PC9QUFBFeGNsdXNpb25TZXJ2ZXJJUD4NCgkJPC9QUFBFeGNsdXNpb24+DQoJCTxFbmFibGVTY3JpcHRpbmcgVXNlckNvbnRyb2xsYWJsZT0iZmFsc2UiPmZhbHNlPC9FbmFibGVTY3JpcHRpbmc+DQoJCTxFbmFibGVBdXRvbWF0aWNTZXJ2ZXJTZWxlY3Rpb24gVXNlckNvbnRyb2xsYWJsZT0iZmFsc2UiPmZhbHNlDQoJCQk8QXV0b1NlcnZlclNlbGVjdGlvbkltcHJvdmVtZW50PjIwPC9BdXRvU2VydmVyU2VsZWN0aW9uSW1wcm92ZW1lbnQ+DQoJCQk8QXV0b1NlcnZlclNlbGVjdGlvblN1c3BlbmRUaW1lPjQ8L0F1dG9TZXJ2ZXJTZWxlY3Rpb25TdXNwZW5kVGltZT4NCgkJPC9FbmFibGVBdXRvbWF0aWNTZXJ2ZXJTZWxlY3Rpb24+DQoJCTxSZXRhaW5WcG5PbkxvZ29mZj5mYWxzZQ0KCQk8L1JldGFpblZwbk9uTG9nb2ZmPg0KCQk8Q2FwdGl2ZVBvcnRhbFJlbWVkaWF0aW9uQnJvd3NlckZhaWxvdmVyPmZhbHNlPC9DYXB0aXZlUG9ydGFsUmVtZWRpYXRpb25Ccm93c2VyRmFpbG92ZXI+DQoJCTxBbGxvd01hbnVhbEhvc3RJbnB1dD50cnVlPC9BbGxvd01hbnVhbEhvc3RJbnB1dD4NCgk8L0NsaWVudEluaXRpYWxpemF0aW9uPg0KCTxTZXJ2ZXJMaXN0Pg0KCQk8SG9zdEVudHJ5Pg0KCQkJPEhvc3ROYW1lPlZQTiBQb3J0YWwgRkgtTXVlbnN0ZXIgPC9Ib3N0TmFtZT4NCgkJCTxIb3N0QWRkcmVzcz52cG4uZmgtbXVlbnN0ZXIuZGU8L0hvc3RBZGRyZXNzPg0KCQkJPFByaW1hcnlQcm90b2NvbD5JUHNlYw0KCQkJCTxTdGFuZGFyZEF1dGhlbnRpY2F0aW9uT25seT5mYWxzZTwvU3RhbmRhcmRBdXRoZW50aWNhdGlvbk9ubHk+DQoJCQk8L1ByaW1hcnlQcm90b2NvbD4NCgkJPC9Ib3N0RW50cnk+DQoJPC9TZXJ2ZXJMaXN0Pg0KPC9BbnlDb25uZWN0UHJvZmlsZT4NCg==";
          };
        };
        eduroam = {
          "802-1x" = {
            ca-cert = config.sops.secrets."wifi/eduroam-ca-cert".path;
            eap = "peap;";
            phase2-auth = "mschapv2";
            identity = "rh792919@fh-muenster.de";
          };
          connection = {
            autoconnect-priority = "1";
            id = "eduroam";
            permissions = "user:raoul:;";
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
        };

      };
    };
  };
}
