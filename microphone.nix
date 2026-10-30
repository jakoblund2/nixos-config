{ config, pkgs-stable, ... }:

{
  #services.pipewire.wireplumber.extraConfig.no-ucm.monitor.alsa.properties.alsa.use-ucm = false;

  # Built-in mic: keep the codec's "Internal Mic Boost" at 0 dB (it adds hiss and clips),
  # so the volume slider (and Discord's auto gain) only drives the clean Capture gain.
  systemd.user.services.wireplumber.environment.ACP_PATHS_DIR = "${
    pkgs-stable.runCommand "acp-paths-no-mic-boost" { } ''
      cp -rL ${config.services.pipewire.package}/share/alsa-card-profile/mixer/paths $out
      chmod -R u+w $out
      sed -i '/^\[Element Internal Mic Boost\]/,/^\[/ s/^volume = merge/volume = zero/' $out/analog-input-internal-mic*.conf
    ''
  }";

  # RNNoise noise suppression: adds a "(Noise Suppressed)" virtual mic for each real mic
  services.pipewire.extraConfig.pipewire."99-noise-suppression"."context.modules" =
    map
      ({ name, description, target }: {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "${description} (Noise Suppressed)";
          "media.name" = "${description} (Noise Suppressed)";
          "filter.graph".nodes = [{
            type = "ladspa";
            name = "rnnoise";
            plugin = "${pkgs-stable.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
            label = "noise_suppressor_mono";
            control = {
              "VAD Threshold (%)" = 50.0;
              "VAD Grace Period (ms)" = 200;
              "Retroactive VAD Grace (ms)" = 0;
            };
          }];
          "capture.props" = {
            "node.name" = "capture.rnnoise_${name}";
            "node.passive" = true;
            "audio.rate" = 48000;
            "target.object" = target;
          };
          "playback.props" = {
            "node.name" = "rnnoise_${name}";
            "media.class" = "Audio/Source";
            "audio.rate" = 48000;
          };
        };
      })
      [
        { name = "internal"; description = "Built-in Mic"; target = "alsa_input.pci-0000_c1_00.6.analog-stereo"; }
        { name = "yeti"; description = "Yeti"; target = "alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo"; }
      ];
}
