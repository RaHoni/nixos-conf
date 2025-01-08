{ config, ... }:
{
  sops.secrets.smtp-password.sopsFile = ../secrets/smtp.yaml;
  sops.templates.postfix-sasl_passwd.content = "[mail.honermann.info]:587 server@honermann.info:${config.sops.placeholder.smtp-password}";
  services.postfix = {
    enable = true;
    relayHost = "mail.honermann.info";
    relayPort = 587;
    rootAlias = "raoul@honermann.info";
    config = {
      smtp_use_tls = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_security_options = "";
      smtp_sasl_password_maps = "texthash:${config.sops.templates."postfix-sasl_passwd".path}";
      # optional: Forward mails to root (e.g. from cron jobs, smartd)
      # to me privately and to my work email:
    };
  };
}
