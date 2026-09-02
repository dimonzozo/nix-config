{
  config,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.monitoring;
in
{
  options.${namespace}.monitoring = {
    enable = mkEnableOption "Monitoring stack";
    nodeExporter = {
      enable = mkEnableOption "Node exporter";
      port = mkOption {
        type = types.port;
        default = 9000;
      };
    };
    grafana = {
      enable = mkEnableOption "Grafana";
      port = mkOption {
        type = types.port;
        default = 3000;
      };
    };
    homeAssistant = {
      enable = mkEnableOption "Home Assistant monitoring";
      host = mkOption {
        type = types.str;
        default = "ha.home";
      };
      port = mkOption {
        type = types.port;
        default = 8123;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # sops.secrets.prometheus_ha_token = mkIf cfg.homeAssistant.enable {
      #   owner = "prometheus";
      # };

      services.prometheus = {
        enable = true;
        globalConfig = {
          scrape_interval = "10s";
        };

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "localhost:${toString cfg.nodeExporter.port}" ];
              }
            ];
          }
          {
            job_name = "file_targets";
            file_sd_configs = [
              {
                files = [ "/etc/prometheus/targets/*.json" ];
                refresh_interval = "5m";
              }
            ];
          }
        ]
        ++ lib.optionals cfg.homeAssistant.enable [
          {
            job_name = "hass";
            scrape_interval = "60s";
            metrics_path = "/api/prometheus";
            bearer_token_file = "${config.sops.secrets.prometheus_ha_token.path}";
            static_configs = [
              {
                targets = [ "${cfg.homeAssistant.host}:${toString cfg.homeAssistant.port}" ];
              }
            ];
          }
        ];
      };
    })

    (mkIf cfg.grafana.enable {
      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = cfg.grafana.port;
            domain = "grafana.home";
          };
        };
      };
    })

    (mkIf cfg.nodeExporter.enable {
      services.prometheus.exporters.node = {
        enable = true;
        port = cfg.nodeExporter.port;
        enabledCollectors = [ "systemd" ];
        extraFlags = [
          "--collector.ethtool"
          "--collector.softirqs"
          "--collector.tcpstat"
          "--collector.wifi"
        ];
      };
    })
  ];
}
