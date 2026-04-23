{
  description = "Resume";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        apps.default = {
          type = "app";
          program = toString (pkgs.writeShellScript "build-resume" ''
            set -euo pipefail
            export PATH=${pkgs.lib.makeBinPath [
              pkgs.texliveFull
              pkgs.sops
              pkgs.just
              pkgs.coreutils
              pkgs.bash
            ]}:$PATH

            tmp="$(mktemp -d)"
            trap 'rm -rf "$tmp"' EXIT

            cp -R ${./.} "$tmp/src"
            chmod -R u+w "$tmp/src"
            cd "$tmp/src"

            export SOPS_AGE_KEY_FILE="''${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/resume-keys.txt}"
            just build
            cp build/main.pdf "$OLDPWD/resume.pdf"
          '');
        };
        devShells.default = pkgs.mkShell {
          shellHook = ''
            export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/resume-keys.txt"
          '';
          packages = with pkgs; [
            texliveFull
            texlab
            tex-fmt
            zathura
            zathuraPkgs.zathura_pdf_poppler

            sops
            just
            prettierd

            nixd
            alejandra
          ];
        };
      };
    };
}
