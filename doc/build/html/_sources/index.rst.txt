.. Lua 实战开发指南 documentation master file

Lua 实战开发指南
================

============= ==============================================================
**Abstract**  Lua 实战开发指南 - 专注于语言机制、易错点与生产实践 (FreeSWITCH/Redis/C API)
**Authors**   Walter Fan
**Category**  Learning Note & Practice
**Status**    WIP
**License**   CC-BY-NC-ND
============= ==============================================================

欢迎阅读 **Lua 实战开发指南**！本文档聚焦 Lua 语言在实际生产中（包括游戏、嵌入式系统、FreeSWITCH 话务脚本、Redis 高性能原子脚本及 C/Lua 混合编程）的 **核心机制**、**易错陷阱** 以及 **最佳实践**。

目标读者
--------

- 具备 C/C++/Go/Python 等任一语言基础，希望系统、高效掌握 Lua 的开发者
- 编写与维护 FreeSWITCH 呼叫路由与 IVR 脚本的音视频工程师
- 编写 Redis 复杂原子操作与流控脚本的后端工程师
- 进行 C/C++ 与 Lua 互操作、嵌入式脚本化引擎开发的系统工程师

文档特点
--------

- **机制深入**：深入剖析 Table 哈希与数组双重结构、Upvalue 闭包原理与协程调度
- **避坑导向**：重点阐述 1-based 下标、nil 洞 holes、变量作用域泄露等经典陷阱
- **工程落地**：提供完整的 C API 互调用、Redis 原子流控、FreeSWITCH 呼叫控制实战模式

.. toctree::
   :maxdepth: 2
   :caption: 目录
   :numbered:

   1.basic/index
   2.oop/index
   3.coroutine/index
   4.c_api/index
   5.performance/index
   6.testing/index
   7.ecosystem/index
   8.cheatsheet/index

快速导航
--------

.. grid:: 2
   :gutter: 3

   .. grid-item-card:: 基础语法与陷阱
      :link: 1.basic/index
      :link-type: doc

      变量作用域、Table 内存与陷阱、函数多返回值、闭包与 Upvalue。

   .. grid-item-card:: 元表与面向对象
      :link: 2.oop/index
      :link-type: doc

      Metatable 与 Metamethod、原型继承、多重继承与类模拟。

   .. grid-item-card:: 协程与协作调度
      :link: 3.coroutine/index
      :link-type: doc

      非对称协程、生产者-消费者管道、协作式微事件循环实现。

   .. grid-item-card:: C 与 Lua 互操作
      :link: 4.c_api/index
      :link-type: doc

      Lua 虚拟栈协议、C 调用 Lua、Lua 调用 C 扩展、LuaJIT FFI 实战。

   .. grid-item-card:: 性能调优与最佳实践
      :link: 5.performance/index
      :link-type: doc

      局部变量缓存加速、字符串拼接技巧、Table 预分配、LuaJIT JIT 友好性。

   .. grid-item-card:: 测试与工程规范
      :link: 6.testing/index
      :link-type: doc

      Busted 单元测试框架、Mock 隔离、Luacheck 静态检查与编码规范。

   .. grid-item-card:: 生态与场景实战
      :link: 7.ecosystem/index
      :link-type: doc

      FreeSWITCH 呼叫控制脚本、Redis 原子限流锁、OpenResty 网关。

   .. grid-item-card:: 速查手册
      :link: 8.cheatsheet/index
      :link-type: doc

      常用语法、字符串正则模式、C API 函数速查与常用调试库。
