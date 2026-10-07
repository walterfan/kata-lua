# FreeSWITCH Lua

FreeSWITCH loads Lua through `mod_lua`. A script can run in two different
contexts:

- A call script invoked by the dialplan receives the global `session` object.
- A background script invoked with `luarun` has no call session.

Keep telephony orchestration in the entry script and ordinary Lua logic in
separate modules that can be tested with the local interpreter.

## Call script checklist

1. Confirm the session is ready before operating on the call.
2. Answer only when the call flow requires it.
3. Validate channel variables and external input before using them.
4. Log useful context without credentials or sensitive caller data.
5. Let FreeSWITCH own call state; avoid busy loops and unnecessary sleeps.

See [the FreeSWITCH hello kata](../kata/freeswitch/README.md).
