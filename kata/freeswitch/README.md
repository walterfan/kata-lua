# FreeSWITCH hello kata

`hello.lua` is a call script. Copy it into the FreeSWITCH scripts directory
and invoke it from the dialplan:

```xml
<extension name="lua-hello">
  <condition field="destination_number" expression="^9191$">
    <action application="lua" data="hello.lua"/>
  </condition>
</extension>
```

Reload the XML configuration and call `9191`. The example expects the standard
`ivr/ivr-welcome_to_freeswitch.wav` sound file.

Use `luac -p hello.lua` for a local syntax check. The script cannot be fully
run with the standalone Lua interpreter because `session` is supplied by
FreeSWITCH.
