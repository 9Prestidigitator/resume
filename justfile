set shell := ["bash", "-euo", "pipefail", "-c"]

secret_enc := "data/personal.tex.age"
secret_plain := "data/personal.tex"

default:
    just --list

decrypt:
    sops --decrypt {{ secret_enc }} > {{ secret_plain }}
    chmod 600 {{ secret_plain }}

encrypt:
    test -f {{ secret_plain }}
    sops --encrypt {{ secret_plain }} > {{ secret_enc }}
    rm -f {{ secret_plain }}

build:
    #!/usr/bin/env bash
    set -euo pipefail

    cleanup() {
        rm -f {{ secret_plain }}
    }
    trap cleanup EXIT

    if sops --decrypt {{ secret_enc }} > {{ secret_plain }} 2>/dev/null; then
        chmod 600 {{ secret_plain }}
        echo "Using decrypted personal data"
    else
        cp data/personal.redacted.tex {{ secret_plain }}
        echo "No age key available; building with redactions"
    fi

    latexmk -pdf main.tex
