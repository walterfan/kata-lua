# 07 FreeSWITCH Kata

FreeSWITCH telephony scripting practice using `mod_lua`.

## Files

- `hello.lua`: Minimal call script answering, streaming audio, and hanging up.
- `ivr_menu.lua`: Complete DTMF digit collection menu with input timeout and fallback logic.

## Dialplan Integration

Copy scripts to the FreeSWITCH scripts folder (e.g. `/usr/local/freeswitch/scripts` or `/etc/freeswitch/scripts`) and add the dialplan extension:

```xml
<extension name="kata-ivr">
  <condition field="destination_number" expression="^9192$">
    <action application="lua" data="07_freeswitch/ivr_menu.lua"/>
  </condition>
</extension>
```

## Syntax Check

Since `session` is provided at runtime by FreeSWITCH, check syntax with `luac`:

```bash
luac -p hello.lua
luac -p ivr_menu.lua
```
