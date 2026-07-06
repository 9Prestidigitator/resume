{
  description = "Resume";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

            home_dir="$HOME"

            ls -l data || true
            if sops --decrypt data/personal.tex.age > data/personal.tex; then
              echo "Building private resume"
            else
              echo "Decryption failed, building redacted resume..."
              rm -f data/personal.tex
            fi
            latexmk -pdf main.tex
            cp build/main.pdf "$OLDPWD/resume.pdf"
          '');
        };
        devShells.default = pkgs.mkShell {
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
