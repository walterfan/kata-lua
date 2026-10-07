# 6.1 Lua 单元测试指南 (Busted 与 Mock 实战)

在 Lua 生态中，[Busted](http://lunarmodules.github.io/busted/) 是最主流的 BDD 风格单元测试框架。

## 1. 安装与运行

```bash
luarocks install busted
busted spec/
```

## 2. 隔离与 Mock 策略

在嵌入式环境（如 FreeSWITCH、OpenResty、Redis）中，测试 Lua 代码的关键是**解耦宿主全局变量**。
通过隔离与模拟全局对象（如 `_G.session`, `_G.redis`, `_G.ngx`），可以在本地纯 Lua 环境中以毫秒级速度执行所有业务分支验证。

```lua
-- 模拟 FreeSWITCH session 对象示例
local function create_mock_session()
    local vars = {}
    return {
        ready = function() return true end,
        answer = function() end,
        hangup = function() end,
        getVariable = function(self, k) return vars[k] end,
        setVariable = function(self, k, v) vars[k] = v end,
    }
end
```
