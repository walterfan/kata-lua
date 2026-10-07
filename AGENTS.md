# AGENTS.md — kata-lua

Lua learning katas and FreeSWITCH Lua script practice. Read this before
editing; use [README.md](README.md) for the human overview and
[doc/README.md](doc/README.md) for learning notes.

## Context map

- `kata/basics/` contains standalone Lua exercises runnable locally.
- `kata/freeswitch/` contains scripts that require FreeSWITCH APIs.
- `lua-cheat-sheet.md` is the concise language reference; do not duplicate it
  here.
- Each substantial kata belongs in `kata/<topic>/` with a local README.

## Commands

There is no package manager, CI configuration, or lint tool. Use the root
Makefile for all runnable checks and document builds.

```bash
make run      # run the basic kata
make test     # run executable kata checks
make check    # syntax-check every Lua file
make docs     # build build/kata-lua-docs.html
make all      # syntax-check Lua and build documentation
```

The standalone Lua interpreter cannot execute FreeSWITCH call scripts; syntax
checks are the local verification for those scripts.

## Harness rules

- Inspect existing katas and documentation before adding a pattern; do not
  fabricate FreeSWITCH APIs, commands, or test results.
- Ask when a change depends on the target FreeSWITCH version, installed modules,
  dialplan, or call flow; these choices change runtime behavior.
- Keep changes small and dependency-free unless the kata explicitly teaches a
  dependency.
- Change only files needed by the request; preserve unrelated exercises and
  formatting.
- Run the focused Lua exercise and syntax-check every changed `.lua` file before
  reporting completion.

## Project rules

- Declare Lua variables and functions `local` unless FreeSWITCH requires a
  global entry point.
- Keep reusable logic independent of `session` and `freeswitch` globals so it
  can run locally.
- Treat channel variables, caller input, and script arguments as untrusted;
  validate them before use.
- Do not log secrets, credentials, or unnecessary caller-identifying data.
- Call scripts may use `session` only when invoked by the dialplan `lua`
  application. `luarun` is for background scripts and has no call session.
- Document FreeSWITCH prerequisites, invocation, and manual call-flow checks in
  each FreeSWITCH kata's README.

## AI tooling

Primary tools: Codex and Claude Code.

- `AGENTS.md` is the canonical instruction file.
- `CLAUDE.md` is a compatibility symlink to `AGENTS.md`.

## Keeping current

Update this file when the layout, commands, FreeSWITCH support baseline, or
agent tooling changes. Turn confirmed project-specific corrections into one
concise rule, and remove rules made obsolete by later changes.
