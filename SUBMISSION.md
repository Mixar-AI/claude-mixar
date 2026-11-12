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
| Icon | The bundled Mixar icon declared in the manifest |

Connect a GitHub account with write access, and allow the Claude GitHub App
to read this repository if the portal requires it. The repository is public
as of 2026-11-12, so no visibility change is needed before publication.

Click **Validate**. Fix all blocking findings and validate again after each
push: validation applies to one commit. The launcher calls Mixar's installed
program, so the portal holds it for manual review. Local CLI validation is not
the portal/security scan.

## Current portal findings

The repository error is resolved: the portal now reports name/publisher checks
passed and produces policy findings. A policy hold permits submission for review
but is not approval to publish.

- Image references: evidence images are displayed with Markdown image syntax;
  they are not executable and neither launcher references them. Re-validation
  must confirm whether this clears the three image findings.
- Scripts the validator could not follow: expected for the disclosed handoff to
  Mixar's installed launcher. Retained for review; removing it would remove the
  plugin's connection to Mixar.
- Verified organization: the portal identifies this organization as unverified.
  Its informational notices say local servers/scripts are not refused yet, but
  describe future Verified-only acceptance. Ask the reviewer to confirm the
  organization's eligibility and verification requirements before publication.
- Fixed environment setting: moved from the MCP configuration into both
  launcher scripts, as the portal recommends. It remains forced on.
- Explicit interpreter: the extensionless command is retained because it was
  tested on macOS and Windows, where Claude Code selects the CMD counterpart.
  Switching it to `sh` would change the tested Windows startup path.
- The icon field is intentional for the listing; the portal says no action is
  needed. Local-server availability and image-pass notices are informational.
- A separate directory-links finding was mentioned but its wording was not
  provided. Check it if it recurs; no listing URL has been invented.

Reviewer note:

> Mixar is an installed desktop 3D editor. This plugin's readable launchers start
> the MCP launcher installed by Mixar for the current user; they install no
> packages and download no code. They require Mixar's media-restriction capability
> and force that restriction on. The bundled images are documentation and branding
> only; no script executes them. Our portal currently marks the organization as
> unverified. Please confirm eligibility and the organization-verification steps
> required for this local MCP integration. Publication is also pending the planned
> Mixar release containing the required capability.

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
- Portal validation now completes with policy holds and informational notices
  described above. Select **Re-validate** on the Source step after fixes, using
  branch `main` and a blank plugin path. Security scan and completed submission
  remain unconfirmed.
- Keep automatic publishing off until the released app/backend have been
  verified together. Review the contact, data handling and compliance answers
  before **Submit for review**. Passing checks is separate from **Publish**.

See `VERIFICATION.md` for the observed platform and workflow results. Cowork
and Linux plugin loading are not verified; don't claim them tested in the listing.
