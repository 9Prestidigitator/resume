# Resume

My resume, with sensitive data managed using `sops`.

## Encryption

- Run `just decrypt` to decrypt the sensitive data.
- Edit the resume, rebuild the PDF, and make any needed changes.
- When finished, run `just encrypt` to re-encrypt the data.

## Building

To build the PDF without leaving decrypted secrets in the repo, run `just build` (`latexmk`).

You also have the option to build the resume with nix.

```nix
nix run github:9Prestidigitator/resume
```

This will look for an age key at `$HOME/.config/sops/age/resume-keys.txt`. If the key is not provided then a redacted version of the resume will be generated.
