#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["msal[broker]==1.39.0"]
# ///
"""
Entra PIM group activation helper.

Auth: the platform broker (Company Portal's SSO extension on macOS, WAM on Windows) via MSAL,
using the Expana developer PIM CLI app registration. The tenant's token protection policy only
accepts broker-bound tokens. Nothing is cached by this script; the broker keeps its own store.
"""
import argparse
import base64
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import webbrowser

import msal

sys.stdout.reconfigure(line_buffering=True)
sys.stderr.reconfigure(line_buffering=True)

TENANT = "d7e07742-e8c1-46d4-be6e-c530bb6949c4"
CLIENT_ID = "641404e7-217d-44a6-b119-983cc76972a2"
SCOPES = [
    "PrivilegedEligibilitySchedule.Read.AzureADGroup",
    "PrivilegedAssignmentSchedule.ReadWrite.AzureADGroup",
    "RoleManagementPolicy.Read.AzureADGroup",
]
GRAPH_BASE = "https://graph.microsoft.com/v1.0"

ROLE_MAP = {
    "developer": "ROLE - AZ Resource Developer",
    "developer-admin": "ROLE - AZ Resource Developer Admin",
    "admin": "ROLE - AZ Resource Platform Administrator",
    "readonly": "ROLE - AZ Resource Infrastructure Read Only",
}

DEFAULT_JUSTIFICATION = "Daily developer workflow"
PIM_PORTAL_URL = "https://aka.ms/pim"


def open_pim_portal(role):
    display_name = resolve_role(role)
    print(f"Opening the PIM portal - activate '{display_name}' manually: {PIM_PORTAL_URL}")
    webbrowser.open(PIM_PORTAL_URL)


def remove_legacy_cache():
    base = os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state")
    legacy = os.path.join(base, "entra-pim")
    if os.path.isdir(legacy):
        shutil.rmtree(legacy)
        print(f"Deleted the old cached refresh token in {legacy}")


def b64url_decode(segment):
    segment += "=" * (-len(segment) % 4)
    return base64.urlsafe_b64decode(segment)


def decode_jwt_claims(token):
    payload = token.split(".")[1]
    return json.loads(b64url_decode(payload))


def get_token():
    remove_legacy_cache()
    app = msal.PublicClientApplication(
        CLIENT_ID,
        authority=f"https://login.microsoftonline.com/{TENANT}",
        enable_broker_on_mac=True,
        enable_broker_on_windows=True,
    )
    try:
        # NOTE: with SSO already established the broker returns without showing a dialog.
        result = app.acquire_token_interactive(
            SCOPES, parent_window_handle=app.CONSOLE_WINDOW_HANDLE, prompt=None
        )
    except Exception as e:
        print(f"Sign-in through the platform broker failed: {e}", file=sys.stderr)
        return None
    if "access_token" not in result:
        print(
            f"Sign-in through the platform broker failed: {result.get('error')}: "
            f"{result.get('error_description')}",
            file=sys.stderr,
        )
        print("On a Mac, sign in to Company Portal and try again.", file=sys.stderr)
        return None
    return result["access_token"]


def principal_id(access_token):
    return decode_jwt_claims(access_token)["oid"]


def graph(method, path, token, body=None):
    url = path if path.startswith("http") else f"{GRAPH_BASE}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    # NOTE: Graph's PIM API rejects a wildcard Accept-Language with CultureNotFoundException.
    req.add_header("Accept-Language", "en-US")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"Graph {method} {path} failed: {e.code} {e.read().decode()[:500]}")


def eligible_groups(token, me):
    filter_q = urllib.parse.quote(f"principalId eq '{me}'")
    path = (
        "/identityGovernance/privilegedAccess/group/eligibilityScheduleInstances"
        f"?$filter={filter_q}&$expand=group"
    )
    return graph("GET", path, token).get("value", [])


def active_groups(token, me):
    filter_q = urllib.parse.quote(f"principalId eq '{me}'")
    path = (
        "/identityGovernance/privilegedAccess/group/assignmentScheduleInstances"
        f"?$filter={filter_q}&$expand=group"
    )
    return graph("GET", path, token).get("value", [])


def policy_max_duration(token, group_id):
    filter_q = urllib.parse.quote(
        f"scopeId eq '{group_id}' and scopeType eq 'Group' and roleDefinitionId eq 'member'"
    )
    path = f"/policies/roleManagementPolicyAssignments?$filter={filter_q}&$expand=policy($expand=rules)"
    for assignment in graph("GET", path, token).get("value", []):
        for rule in assignment["policy"]["rules"]:
            if rule["id"] == "Expiration_EndUser_Assignment":
                return rule["maximumDuration"]
    raise RuntimeError(f"The PIM policy for group {group_id} has no maximum activation duration.")


def resolve_role(role):
    if role not in ROLE_MAP:
        valid = ", ".join(ROLE_MAP)
        print(f"Unknown role '{role}'. Valid roles: {valid}", file=sys.stderr)
        sys.exit(1)
    return ROLE_MAP[role]


def find_group_id(groups, display_name):
    for g in groups:
        if g.get("group", {}).get("displayName") == display_name:
            return g["groupId"], g.get("accessId", "member")
    return None, None


def is_currently_active(active, display_name):
    for g in active:
        if g.get("group", {}).get("displayName") == display_name:
            return True
    return False


def cmd_login(args):
    if get_token() is None:
        sys.exit(1)
    print("Signed in through the platform broker.")


def cmd_list(args):
    token = get_token()
    if token is None:
        print(f"Could not sign in to Graph. Check your roles directly: {PIM_PORTAL_URL}", file=sys.stderr)
        sys.exit(1)
    try:
        me = principal_id(token)
        groups = eligible_groups(token, me)
    except Exception as e:
        print(str(e), file=sys.stderr)
        print(f"Check your roles directly: {PIM_PORTAL_URL}", file=sys.stderr)
        sys.exit(1)
    if not groups:
        print("No eligible PIM groups found.")
        return
    print("Eligible groups:")
    for g in groups:
        print(f"  - {g.get('group', {}).get('displayName')}")


def cmd_status(args):
    token = get_token()
    if token is None:
        print(f"Could not sign in to Graph. Check your roles directly: {PIM_PORTAL_URL}", file=sys.stderr)
        sys.exit(1)
    try:
        me = principal_id(token)
        elig = eligible_groups(token, me)
        act = active_groups(token, me)
    except Exception as e:
        print(str(e), file=sys.stderr)
        print(f"Check your roles directly: {PIM_PORTAL_URL}", file=sys.stderr)
        sys.exit(1)
    active_names = {g.get("group", {}).get("displayName") for g in act}
    print("Eligible groups (* = currently active):")
    for g in elig:
        name = g.get("group", {}).get("displayName")
        marker = "*" if name in active_names else " "
        print(f"  [{marker}] {name}")


def graph_activate(token, role, duration, justification):
    """Returns 'already_active', 'activated', or 'ineligible'."""
    me = principal_id(token)
    display_name = resolve_role(role)

    active = active_groups(token, me)
    if is_currently_active(active, display_name):
        print(f"'{display_name}' is already active.")
        return "already_active"

    elig = eligible_groups(token, me)
    group_id, access_id = find_group_id(elig, display_name)
    if not group_id:
        print(f"You are not eligible for '{display_name}'.", file=sys.stderr)
        return "ineligible"

    duration = duration or policy_max_duration(token, group_id)
    body = {
        "accessId": access_id or "member",
        "principalId": me,
        "groupId": group_id,
        "action": "selfActivate",
        "scheduleInfo": {
            "startDateTime": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "expiration": {"type": "afterDuration", "duration": duration},
        },
        "justification": justification,
    }
    graph("POST", "/identityGovernance/privilegedAccess/group/assignmentScheduleRequests", token, body)
    print(f"Activated '{display_name}' for {duration}.")
    return "activated"


def cmd_activate(args):
    token = get_token()
    if token is None:
        open_pim_portal(args.role)
        return
    try:
        status = graph_activate(token, args.role, args.duration, args.justification)
    except Exception as e:
        print(str(e), file=sys.stderr)
        open_pim_portal(args.role)
        return
    if status == "ineligible":
        sys.exit(1)


def az_logged_in():
    result = subprocess.run(["az", "account", "show"], capture_output=True)
    return result.returncode == 0


def az_login():
    print("Not logged in to az cli; running 'az login'...")
    subprocess.run(["az", "login"], check=True)


def az_refresh_token():
    subprocess.run(["az", "account", "get-access-token", "--output", "none"], capture_output=True)


def cmd_ensure(args):
    if not az_logged_in():
        az_login()
    else:
        print("az cli: logged in.")

    token = get_token()
    if token is None:
        open_pim_portal(args.role)
        return

    try:
        status = graph_activate(token, args.role, args.duration, args.justification)
    except Exception as e:
        print(str(e), file=sys.stderr)
        open_pim_portal(args.role)
        return
    if status == "ineligible":
        sys.exit(1)
    if status == "activated":
        print("Refreshing az token to pick up new group membership...")
        az_refresh_token()
        print("Note: group membership can take a minute or two to propagate. If az commands "
              "still 403, wait briefly and retry, or run 'az login' again.")


def build_parser():
    p = argparse.ArgumentParser(description="Entra PIM group activation helper")
    sub = p.add_subparsers(dest="command", required=True)

    sp = sub.add_parser("ensure", help="ensure az login + PIM role active (main entry point)")
    sp.add_argument("role", choices=ROLE_MAP.keys())
    sp.add_argument("--duration", help="ISO 8601 duration; defaults to the group's PIM policy maximum")
    sp.add_argument("--justification", default=DEFAULT_JUSTIFICATION)
    sp.set_defaults(func=cmd_ensure)

    sp = sub.add_parser("activate", help="activate a PIM role (no az login check)")
    sp.add_argument("role", choices=ROLE_MAP.keys())
    sp.add_argument("--duration", help="ISO 8601 duration; defaults to the group's PIM policy maximum")
    sp.add_argument("--justification", default=DEFAULT_JUSTIFICATION)
    sp.set_defaults(func=cmd_activate)

    sp = sub.add_parser("status", help="show eligible + active PIM groups")
    sp.set_defaults(func=cmd_status)

    sp = sub.add_parser("list", help="list eligible PIM groups")
    sp.set_defaults(func=cmd_list)

    sp = sub.add_parser("login", help="sign in through the platform broker")
    sp.set_defaults(func=cmd_login)

    return p


def main():
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
