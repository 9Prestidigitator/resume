# Resume

My resume, with sensitive data managed using `sops`.

- Run `just decrypt` to decrypt the sensitive data.
- Edit the resume, rebuild the PDF, and make any needed changes.
- When finished, run `just encrypt` to re-encrypt the data.
- To build the PDF without leaving decrypted secrets in the repo, run `just build`.
