# 7.2 Redis Lua 原子脚本实践

Redis 保证内置执行的 Lua 脚本具备**绝对原子性**（单线程执行期间不插入其他命令），避免竞态条件。

## 1. 规则与约束

- 所有的键名必须通过 `KEYS[i]` 传入，所有的额外参数通过 `ARGV[i]` 传入（便于 Redis Cluster 路由与键校验）。
- 脚本必须保持轻量与极快响应，避免长时间运行阻塞 Redis 主线程。

## 2. 分布式锁安全释放脚本

```lua
-- KEYS[1]: 锁的 key
-- ARGV[1]: 客户端唯一标识 requestId
if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
else
    return 0
end
```

## 3. 滑动窗口限流脚本

利用 Redis ZSET 结构实现精准滑动时间窗口流控：

```lua
-- KEYS[1]: 限制对象的 key (如 rate:user_123)
-- ARGV[1]: 当前时间戳 (毫秒)
-- ARGV[2]: 窗口时间大小 (毫秒)
-- ARGV[3]: 窗口内允许最大请求次数
local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local limit = tonumber(ARGV[3])

local clear_before = now - window
redis.call('zremrangebyscore', key, '-inf', clear_before)

local current_requests = redis.call('zcard', key)
if current_requests < limit then
    redis.call('zadd', key, now, now)
    redis.call('pexpire', key, window)
    return 1 -- 允许通过
else
    return 0 -- 限流拦截
end
```
