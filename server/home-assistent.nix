{...}:
{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "zha"
      "default_config"
      "met"
      "esphome"
    ];
    config = {
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "192.168.3.0/23"
        ];
      };
      homeassistant = {
      unit_system = "metric";
      longitude = 7.7;
      latitude = 52.0;
      name = "home";
    };
    automation = [
    {
      alias = "Salz An";
        description= "";
        trigger = [
          {
            platform = "sun";
            event = "sunset";
            offset = 0;
          }
          {
            platform = "time";
            at= "6:30:00";
          }
        ];
        action = {
            type = "turn_on";
            device_id= "a0d32ecbcbdbdeec6ebcc689b2c0d860";
            entity_id= "0dc3ba1296a2c418839628ae898f9b6a";
            domain= "switch";
          };
      }
    {
      alias = "Salz Aus";
        description= "";
        trigger = [
          {
            platform = "sun";
            event = "sunrise";
            offset = 0;
          }
          {
            platform = "time";
            at= "00:00:00";
          }
        ];
        action = {
            type = "turn_off";
            device_id= "a0d32ecbcbdbdeec6ebcc689b2c0d860";
            entity_id= "0dc3ba1296a2c418839628ae898f9b6a";
            domain= "switch";
          };
      }


    ];
    };
  };
}
