# Directory submission

Submit through https://claude.ai/directory/manage using **Plugin bundle**.
This plugin launches a local server; it is not a remote MCP connector listing.
Official instructions: https://claude.com/docs/plugins/submit.

## Source and listing

| Field | Value |
|---|---|
| Repository | `Mixar-AI/claude-mixar` |
| Plugin path | Leave empty (repository root) |
| Branch | `main` |
| Name / display name | `mixar` / Mixar |
| Company | Adeveda Enterprises Private Limited |
| Website | https://www.mixar.app |
| Support / review contact | support@mixar.app |
| Privacy policy | https://www.mixar.app/legal/privacy-policy |
| Documentation | This repository's README and `skills/mixar/references/setup.md` |
| Icon | `assets/icon.png` |

Connect a GitHub account with write access, and allow the Claude GitHub App
to read this repository if the portal requires it. The repository is private:
Anthropic allows validation and review while private, but requires it public
before publication. Private-source scanning requires agreement in the portal.

Click **Validate**. Fix all blocking findings and validate again after each
push: validation applies to one commit. The launcher calls Mixar's installed
program, so a manual-review hold for scripts the validator cannot follow is
possible. Local CLI validation is not the portal/security scan.

## Data handling answers

Use these descriptions to answer the portal's exact questions; do not describe
the plugin as processing no personal data simply because the adapter stores none.

- **Personal data:** Mixar processes the tool inputs, relevant scene data and
  results under the user's signed-in account. Inputs may contain personal data.
  The adapter does not read Claude conversation history or Mixar login secrets.
- **Destinations:** the local launcher reaches Mixar over authenticated loopback.
  Mixar forwards calls to its own backend, `api.mixar.app`. User-requested AI 3D
  generation may send prompts and reference assets to the providers disclosed
  in the privacy policy. The README describes these flows.
- **Retention:** diagnostic tool-call records are retained for up to 30 days;
  isolated backup copies for up to 7 days from backup creation, subject to the
  privacy policy's lawful exceptions. Desktop usage analytics are retained for
  30 days and can be disabled in Mixar. Scene files and exports remain on the
  user's computer until the user removes them.
- **Children:** the service is intended for people who have reached the age of
  majority in their jurisdiction, as stated in the privacy policy.

## Review examples

1. "Check whether Mixar is connected and summarize the current scene without
   changing it."
2. "In a new scene tab, use scripts and simple materials to build a one-metre
   wooden shipping crate. Render a hero preview and correct visible problems.
   Do not use AI generation or paid materials."
3. "Export only the crate meshes as GLB for Godot to Downloads. Check the
   exported file and tell me whether verification passed."

Provide reviewers a dedicated standard Mixar account with sample data through
the portal's private reviewer channel when requested. Never put reviewer
credentials in this repository. Do not supply the shared QA account or dev-bypass
credentials. Record a supported installer version and download link below once
the planned release is published.

## Release and portal status

- Client PR #2078 and backend PR #2024 are merged into
  `feature/mixar-blastoff` for the next planned release, per the owner's choice.
- Client merge: `2fc0fef0781eb5fb45ab37317feb36ca1c0d6829`.
- Backend merge: `8f0f256e61bc12f89c6240faee7a16d167a6ce60`.
- Production deployment and a supported released installer are still pending.
  Released Mixar 4.4.3 does not carry the required capability.
- Minimum supported installer version / link: **pending the next release**.
- Portal validation, security scan and submission: **not performed**.
- Keep automatic publishing off until the released app/backend have been
  verified together. Review the contact, data handling and compliance answers
  before **Submit for review**. Passing checks is separate from **Publish**.

See `VERIFICATION.md` for the observed platform and workflow results. Cowork
and Linux plugin loading are not verified; don't claim them tested in the listing.
