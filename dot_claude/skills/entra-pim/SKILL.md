---
name: entra-pim
description: Ensures the user is logged in to Azure CLI and has the correct MS Entra PIM group activated before running az commands or other Azure-gated tasks. Use before any az cli command, Azure resource work, or Azure Portal task. Escalate to the admin role for billing/cost management and LibreChat management tasks. Triggers on "activate PIM", "elevate my role", "az login", running az commands, billing/cost questions, and LibreChat administration.
---

# Entra PIM guard

Michael's Azure access is gated by PIM for Groups, not standing role assignments. This skill
wraps a Python script, run with `uv` (which installs its one dependency, `msal[broker]`, in an
isolated environment), that checks az cli login and activates the right PIM group via
Microsoft Graph.

Script: `~/.claude/skills/entra-pim/pim.py`

## Roles

| key | PIM group | when |
|---|---|---|
| `developer` | ROLE - AZ Resource Developer | default for daily dev work / any `az` command |
| `admin` | ROLE - AZ Resource Platform Administrator | billing/cost management, LibreChat management |
| `developer-admin` | ROLE - AZ Resource Developer Admin | only if explicitly requested |
| `readonly` | ROLE - AZ Resource Infrastructure Read Only | only if explicitly requested |

## Usage

**Before any `az` command**, run:

```bash
uv run --script ~/.claude/skills/entra-pim/pim.py ensure developer
```

**Before billing/cost or LibreChat management tasks**, run:

```bash
uv run --script ~/.claude/skills/entra-pim/pim.py ensure admin
```

`ensure` checks `az account show`, running `az login` if needed, then checks whether the PIM
group is already active and activates it (for the group's PIM policy maximum, e.g. 12h for
developer and 4h for admin; justification "Daily developer workflow") only if it isn't.
It's a no-op message if already active — safe to call before every `az` command.

Other subcommands: `status` (list eligible + currently active groups), `list` (eligible groups
only), `login` (force a fresh interactive login), `activate <role>` (activate without the az
login check).

## Auth

Sign-in goes through the platform broker (Company Portal's SSO extension on macOS, WAM on
Windows) with the "Expana developer PIM CLI" app registration, the same one `pnpm run cli` in
expana-app uses. The tenant's token protection policy only accepts broker-bound tokens, so
there is no browser or device-code fallback. On an enrolled Mac already signed in to Company
Portal, sign-in is silent.

The script stores nothing; the broker keeps its own token store. On first run it deletes the
old `$XDG_STATE_HOME/entra-pim/` refresh-token cache from the previous browser flow.

If the broker fails (Company Portal not signed in, device not registered), `ensure` and
`activate` print the reason and open `https://aka.ms/pim` so the role can be activated by hand.

## Propagation note

PIM group activation changes Azure AD group membership; an already-issued `az` token won't
reflect it until refreshed. `ensure` runs `az account get-access-token` after a fresh
activation to warm a new token. If an `az` command still 403s right after activating, wait
~30-60s for propagation and retry, or run `az login` again.
