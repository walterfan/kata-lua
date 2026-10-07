# kata-lua

Kata should be called "routine" in Chinese. The secret of practicing martial arts is to master various routines.

First, you must learn from the strengths of hundreds of schools and be familiar with the routines of various schools in the world. Only then can you integrate them and achieve the state of no moves being better than moves.

Dave Thomas - the author of "The Pragmatic Programmer", proposed the idea of Code Kata. Dave also collected small practice projects on his website (http://codekata.com/).

As a professional programmer, I practice routines often used in production—such as embedded telephony scripting (FreeSWITCH), in-memory distributed atomic scripts (Redis), high-concurrency gateways (OpenResty), and C/C++ engine interoperability. This repository organizes and collects these routines for fast, systematic, and effective Lua mastery.

## Structure

```text
kata-lua/
├── doc/                        # Lua 实战开发指南 (Sphinx + MyST 文档体系)
│   ├── source/
│   │   ├── 1.basic/            # 基础语法、Table 陷阱与闭包
│   │   ├── 2.oop/              # 元表与面向对象原型继承
│   │   ├── 3.coroutine/        # 协程与协作式微调度器
│   │   ├── 4.c_api/            # 虚拟栈协议、嵌入与 C 模块
│   │   ├── 5.performance/      # 局部变量缓存与性能调优
│   │   ├── 6.testing/          # 单元测试与 Mock 隔离
│   │   ├── 7.ecosystem/        # FreeSWITCH / Redis / OpenResty
│   │   └── 8.cheatsheet/       # 语法与 C API 速查
│   ├── Makefile
│   └── requirements.txt
├── kata/                       # 可运行的渐进式练习 (Katas)
│   ├── 01_basics/              # 基础类型、闭包备忘与正则模式匹配
│   ├── 02_metatables_oop/      # 向量运算符重载与类单继承
│   ├── 03_coroutines/          # 管道生成器与协作微任务调度器
│   ├── 04_c_interop/           # C 语言嵌入 Lua 与暴露 C 函数
│   ├── 05_testing/             # 纯 Lua 零依赖 BDD 测试与 IVR Mock
│   ├── 06_redis_scripts/       # 生产级 Redis 令牌桶限流与分布式锁
│   ├── 07_freeswitch/          # FreeSWITCH 呼叫会话与 IVR 菜单
│   ├── basics/                 # 早期入门练习 (排序、函数、原型)
│   ├── c_call_lua/             # 基础 C 调用 Lua 演示
│   ├── lua_call_c/             # 基础 Lua 调用 C 函数演示
│   └── freeswitch/             # 原始 FreeSWITCH 示例
├── lua-cheat-sheet.md          # 核心语法与常用函数速查
├── Makefile                    # 统一构建与测试入口
└── README.md
```

## Kata 练习目录

1. [01_basics](kata/01_basics/): 基础语法与核心机制（数值/字符串真假值、闭包与 `memoize` 缓存、模式匹配与 URL 解析）。
2. [02_metatables_oop](kata/02_metatables_oop/): 元表与面向对象（`Vector2D` 运算符重载、原型继承与多态）。
3. [03_coroutines](kata/03_coroutines/): 协程与协作调度（生产者-消费者管道、协作式微事件循环 `micro_scheduler`）。
4. [04_c_interop](kata/04_c_interop/): C 与 Lua 互操作（C 嵌入式调用 Lua 函数、向 Lua 注册 C 宿主函数）。
5. [05_testing](kata/05_testing/): 测试与 Mock 隔离（轻量 BDD 测试运行器、解耦宿主 `session` 验证 IVR 业务）。
6. [06_redis_scripts](kata/06_redis_scripts/): Redis 高性能原子脚本（令牌桶平滑限流、分布式锁安全释放校验）。
7. [07_freeswitch](kata/07_freeswitch/): FreeSWITCH 呼叫脚本实践（通道变量提取、按需应答、DTMF 按键菜单与路由转接）。

---

## Lua 实战开发指南

本项目包含一份结构完整的开发指南，专注于语言核心机制、易错陷阱及工程落地：

### 1. 基础语法与陷阱
- [Lua 核心设计与执行机制](doc/source/1.basic/overview.md)
- [Table 内部机制与边界陷阱](doc/source/1.basic/tables_and_traps.md)
- [函数、多返回值与闭包机制](doc/source/1.basic/functions_and_closures.md)
- [Lua 常见编程陷阱速查](doc/source/1.basic/pitfalls.md)

### 2. 元表与面向对象
- [Metatables 与核心元方法](doc/source/2.oop/metatables.md)
- [Lua 面向对象惯用模式](doc/source/2.oop/oop_patterns.md)

### 3. 协程与并发
- [协程机制与状态流转](doc/source/3.coroutine/concepts.md)
- [协作式微调度器实操](doc/source/3.coroutine/scheduler.md)

### 4. C 与 Lua 互操作 (C API)
- [Lua 虚拟栈协议](doc/source/4.c_api/stack_protocol.md)
- [C 程序嵌入 Lua 脚本](doc/source/4.c_api/embedding_lua.md)
- [编写 C 扩展模块供 Lua 调用](doc/source/4.c_api/c_modules.md)

### 5. 性能调优
- [Lua 核心性能优化法则](doc/source/5.performance/optimization.md)

### 6. 测试与工程规范
- [Lua 单元测试指南与 Mock 隔离](doc/source/6.testing/unit_test_guide.md)
- [编码规范与静态检查](doc/source/6.testing/standards.md)

### 7. 生态与场景实战
- [FreeSWITCH Lua 脚本实践](doc/source/7.ecosystem/freeswitch.md)
- [Redis Lua 原子脚本实践](doc/source/7.ecosystem/redis.md)
- [OpenResty 高性能网关](doc/source/7.ecosystem/openresty.md)

### 8. 速查手册
- [Lua 核心语法速查](doc/source/8.cheatsheet/syntax.md)
- [Lua C API 函数速查](doc/source/8.cheatsheet/c_api_quickref.md)

---

## 常用工具与命令

### 语法校验与运行

```bash
# 语法检查所有 Lua 源码
make check

# 运行所有本地 Kata 自动化测试
make test

# 运行基础示例
make run
```

### C 互操作编译与运行

```bash
# 编译 C 调用 Lua 演示
make c-demo
./build/call_lua_demo

# 编译 Lua 调用 C 演示
make lua-state-demo
./build/lua_state_demo
```

### 构建与查看文档

```bash
# 构建 Sphinx 静态 HTML
make doc-html

# 本地启动文档预览服务器 (http://localhost:8000)
make doc-serve
```

---

## VS Code 调试配置

在 `.vscode/launch.json` 中配置支持调试 Lua 文件（配合 Local Lua Debugger 插件）：

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Current Lua File",
      "type": "lua-local",
      "request": "launch",
      "program": {
        "command": "lua"
      },
      "args": ["${file}"]
    }
  ]
}
```

---

## 参考资源

- [Lua 官方文档](https://www.lua.org/docs.html)
- [Programming in Lua (PIL)](https://www.lua.org/pil/)
- [FreeSWITCH Lua API Guide](https://developer.signalwire.com/freeswitch/)
- [Redis Lua Scripting Documentation](https://redis.io/docs/interact/programmability/eval-intro/)
- [OpenResty 最佳实践](https://moonbingbing.gitbooks.io/openresty-best-practices/content/)
