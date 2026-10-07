# 6.2 编码规范与静态检查

## 1. 核心编码规范

1. **默认 `local` 优先**：任何变量与函数必须声明为 `local`，杜绝隐式全局污染。
2. **错误处理规范**：
   - 预期可恢复错误：返回 `nil, "error message"`。
   - 不可恢复异常或程序员逻辑 Bug：使用 `error()` 或 `assert()`。
3. **安全使用 Channel 与上下文参数**：来自外部的所有入参均视为不可信，需做类型与空值判定。
4. **日志隐私保护**：严禁在日志中打印密码、Token 及用户敏感身份信息。

## 2. Luacheck 静态分析

[Luacheck](https://github.com/mpeterv/luacheck) 是 Lua 生态的标准 Lint 工具：

```bash
luarocks install luacheck
luacheck .
```

`.luacheckrc` 配置文件示例：

```lua
std = "lua54"
globals = { "session", "freeswitch", "redis" }
ignore = { "212" } -- 忽略未使用的参数 (unused argument)
```
