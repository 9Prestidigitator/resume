set shell := ["bash", "-euo", "pipefail", "-c"]

secret_enc := "data/personal.tex.age"
secret_plain := "data/personal.tex"

default:
    just --list

decrypt:
    rm -f {{ secret_plain }}
    if [ -n "${SOPS_AGE_KEY_FILE:-}" ] && sops --decrypt {{ secret_enc }} > {{ secret_plain }} 2>/dev/null; then
        chmod 600 {{ secret_plain }}
        echo "Decrypted personal data"
    else
        rm -f {{ secret_plain }}
        echo "Failed to decrypt personal data"
    fi

encrypt:
    test -f {{ secret_plain }}
    sops --encrypt {{ secret_plain }} > {{ secret_enc }}
    rm -f {{ secret_plain }}
    echo "Encrypted personal data"

build:
    trap 'rm -f {{ secret_plain }}' EXIT
    just decrypt
    latexmk -C >/dev/null 2>&1 || true
    rm -rf build
    latexmk -pdf main.tex
