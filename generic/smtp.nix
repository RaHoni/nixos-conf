{ config, ... }:
{
  sops.secrets.smtp-password.sopsFile = ../secrets/smtp.yaml;
  sops.templates.postfix-sasl_passwd.content = "[smtp.web.de]:587 honermann.info@web.de:${config.sops.placeholder.smtp-password}";
  services.postfix = {
    enable = true;
    relayHost = "smtp.web.de";
    relayPort = 587;
    rootAlias = "raoul.honermann@web.de";
    enableHeaderChecks = true;
    canonical = ''
      /^(.*)<.*>$/     $1 <honermann.info@web.de>
      /^([^<>]+)$/     $1 <honermann.info@web.de>
    '';
    headerChecks = [
      {
        pattern = "/^From:(.*)<.*>/";
        action = "REPLACE From: $1 <honermann.info@web.de>";
      }
      {
        pattern = "/^From:([^<>@]+)/";
        action = "REPLACE From: $1 <honermann.info@web.de>";
      }
    ];
    config = {
      smtp_use_tls = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_security_options = "";
      smtp_sasl_password_maps = "texthash:${config.sops.templates."postfix-sasl_passwd".path}";
      sender_canonical_maps = "regexp:/var/lib/postfix/conf/canonical";
      # optional: Forward mails to root (e.g. from cron jobs, smartd)
      # to me privately and to my work email:
    };
  };
}
