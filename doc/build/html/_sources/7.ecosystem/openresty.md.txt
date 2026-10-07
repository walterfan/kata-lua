# 7.3 OpenResty 高性能网关

OpenResty 将 LuaJIT 嵌入到 Nginx 事件循环中，提供了基于 Cosocket 的非阻塞 I/O 编程体验。

## 核心阶段（Phases）

- `init_by_lua*`: 进程启动初始化、加载预热模块。
- `set_by_lua*`: 设置 Nginx 变量。
- `rewrite_by_lua*`: URL 重写、内部重定向。
- `access_by_lua*`: 权限鉴权、IP 黑白名单过滤、限流。
- `content_by_lua*`: 生成响应内容、代理后端。
- `header_filter_by_lua*`: 响应头过滤与改写。
- `body_filter_by_lua*`: 响应体流式加工。
- `log_by_lua*`: 请求日志记录、监控打点。

## Cosocket 原理

利用 Lua 协程机制，当发起网络 I/O 时（如 Redis/MySQL/HTTP 查询），自动 `yield` 协程并向 Nginx epoll 注册读写事件；当数据到达后，由 epoll 回调 `resume` 唤醒协程。开发者书写同步代码，底层享受全异步非阻塞性能。
