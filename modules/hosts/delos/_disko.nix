{pkgs}: let
  secretDir = "/run/disko-delos-luks";
in {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-eui.5cdfb80651409c82";
      # Disko's destroy stage runs before this hook. Decrypt before partition creation.
      # The disk subshell removes plaintext on exit, including failures.
      preCreateHook = ''
        if [[ "$(${pkgs.lib.getExe' pkgs.util-linux "findmnt"} -n -o FSTYPE -T /run)" != tmpfs ]]; then
          echo "The installer requires /run on tmpfs for the LUKS passphrase." >&2
          exit 1
        fi
        umask 077
        mkdir -m 0700 ${secretDir}
        trap 'rm -rf -- ${secretDir}' EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM
        PATH=${pkgs.lib.makeBinPath [pkgs.age-plugin-fido2-hmac]}:"$PATH" \
          ${pkgs.age}/bin/age --decrypt \
          -i ${../../../keys/physical/desk.pub} \
          -o ${secretDir}/raw ${../../../secrets/luks.age}
        ${pkgs.python3}/bin/python3 - ${secretDir}/raw ${secretDir}/passphrase <<'PY'
        import os
        from pathlib import Path
        import sys

        data = Path(sys.argv[1]).read_bytes()
        if data.endswith(b"\r\n"):
            data = data[:-2]
        elif data.endswith(b"\n"):
            data = data[:-1]
        if not data or any(byte in data for byte in (b"\n", b"\r", b"\0")):
            sys.exit("The LUKS passphrase must contain one nonempty line without NUL bytes.")

        fd = os.open(sys.argv[2], os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "wb") as output:
            output.write(data)
        PY
        rm -- ${secretDir}/raw
      '';
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          encrypted = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypt";
              extraFormatArgs = ["--type" "luks2"];
              enrollRecovery = false;
              passwordFile = "${secretDir}/passphrase";
              settings.allowDiscards = true;
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/nix";
                mountOptions = ["defaults" "x-systemd.device-timeout=5min"];
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      device = "none";
      mountOptions = ["defaults" "size=4G" "mode=755"];
    };
  };
}
