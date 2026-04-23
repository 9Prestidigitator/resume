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
              pkgs.coreutils
              pkgs.bash
            ]}:$PATH

            tmp="$(mktemp -d)"
            trap 'rm -rf "$tmp"' EXIT

            cp -R ${./.} "$tmp/src"
            chmod -R u+w "$tmp/src"
            cd "$tmp/src"

            home_dir="$HOME"
            key_file="''${SOPS_AGE_KEY_FILE:-$home_dir/.config/sops/age/resume-keys.txt}"

            echo "Using key file: $key_file"
            ls -l data || true

            if [ -f "$key_file" ]; then
              if SOPS_AGE_KEY_FILE="$key_file" sops --decrypt data/personal.tex.age > data/personal.tex; then
                echo "Building private resume"
              else
                echo "Decryption failed"
                rm -f data/personal.tex
                exit 1
              fi
            else
              echo "Key file not found: $key_file"
              rm -f data/personal.tex
              echo "Building redacted resume"
            fi

            latexmk -pdf main.tex
            cp build/main.pdf "$OLDPWD/resume.pdf"
          '');
        };
        devShells.default = pkgs.mkShell {
          env.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/resume-keys.txt";
          packages = with pkgs; [
            texliveFull
            texlab
            tex-fmt
            zathura
            zathuraPkgs.zathura_pdf_poppler

            sops
            just

            nixd
            alejandra
          ];
        };
      };
    };
}
