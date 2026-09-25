#!/usr/bin/env sh
# Add ScriptGrain to Claude Code.
#
# OAuth (recommended): add the server, then run /mcp inside Claude Code and
# sign in with your ScriptGrain account.
claude mcp add --transport http scriptgrain https://mcp.scriptgrain.com/mcp

# Or with an API key from https://scriptgrain.com/settings?tab=api
# (read it from the environment so it never lands in shell history):
#   claude mcp add scriptgrain https://mcp.scriptgrain.com/mcp \
#     --transport http --header "Authorization: Bearer $SCRIPTGRAIN_API_KEY"
