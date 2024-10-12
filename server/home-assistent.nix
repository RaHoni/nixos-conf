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
            device_id= "b50219e4da1445c6808f3bda6a5fd394";
            entity_id= "51d2db670767d555e38c84e91fab7f1e";
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
            device_id= "b50219e4da1445c6808f3bda6a5fd394";
            entity_id= "51d2db670767d555e38c84e91fab7f1e";
            domain= "switch";
          };
      }


    ];
    };
  };
}
