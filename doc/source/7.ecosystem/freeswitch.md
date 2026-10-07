# 7.1 FreeSWITCH Lua 脚本实践

FreeSWITCH 通过 `mod_lua` 提供了极其强大的话务控制能力。

## 1. 运行上下文差异

- **呼叫控制脚本（Call Script）**：由 Dialplan 的 `lua` application 触发，提供隐式全局 `session` 对象。
- **后台运维脚本（Background Script）**：由控制台或 CLI 执行 `luarun script.lua` 触发，**没有** `session` 对象，仅有 `freeswitch` 宿主 API。

## 2. 关键流程规范

1. **会话可用性校验**：进入脚本后，执行核心操作前务必校验 `session:ready()`。
2. **按需应答**：不要过早执行 `session:answer()`，直到确实需要与主叫建立媒体连接或播放语音。
3. **输入参数过滤**：使用 `session:getVariable()` 获取的通道变量严格判空与过滤。
4. **资源清理**：FreeSWITCH 拥有通道状态机主权，脚本中严禁无休止轮询或 `os.execute("sleep ...")` 阻塞 worker 线程。
