
# DNS 降级缓存的高效测试与验证方案

## 一、测试分层策略

```
┌─────────────────────────────────────────────┐
│  第 1 层：纯 Lua 单元测试（秒级反馈）         │
│  验证：缓存读写、TTL 计算、次数限制、IP 变更检测 │
├─────────────────────────────────────────────┤
│  第 2 层：OpenResty 集成测试（分钟级反馈）     │
│  验证：cosocket → 降级 → 重连 的完整链路       │
├─────────────────────────────────────────────┤
│  第 3 层：Docker Compose 端到端测试（分钟级）   │
│  验证：真实 DNS 故障、蓝绿切换场景             │
├─────────────────────────────────────────────┤
│  第 4 层：灰度环境验证（小时级）               │
│  验证：生产流量下的行为、监控告警              │
└─────────────────────────────────────────────┘
```

每一层都能独立运行，越靠上反馈越快、运行频率越高。

---

## 二、第 1 层：纯 Lua 单元测试

这一层不需要启动 OpenResty，直接用 `busted`（Lua 测试框架）+ mock 运行，**几秒内完成**。

### 2.1 环境搭建

```bash
# 安装 busted（Lua 测试框架）
luarocks install busted

# 项目结构
├── lib/
│   ├── dns_fallback_cache.lua
│   └── http_with_fallback.lua
├── t/
│   ├── unit/
│   │   ├── test_fallback_cache.lua
│   │   └── test_dns_error_detect.lua
│   └── helpers/
│       └── mock_ngx.lua
└── Makefile
```

### 2.2 Mock ngx.shared.DICT

单元测试的关键是 mock 掉 `ngx.shared.DICT`，让代码能在纯 Lua 环境下运行：

```lua
-- t/helpers/mock_ngx.lua
local _M = {}

-- 模拟 lua_shared_dict
function _M.new_shared_dict()
    local store = {}
    local expiry = {}

    return {
        get = function(self, key)
            -- 检查是否过期
            if expiry[key] and expiry[key] < os.time() then
                store[key] = nil
                expiry[key] = nil
                return nil
            end
            return store[key]
        end,

        set = function(self, key, val, ttl)
            store[key] = val
            if ttl and ttl > 0 then
                expiry[key] = os.time() + ttl
            end
            return true, nil, false  -- ok, err, forcible
        end,

        incr = function(self, key, value, init, init_ttl)
            local current = store[key]
            if not current then
                current = init or 0
                if init_ttl and init_ttl > 0 then
                    expiry[key] = os.time() + init_ttl
                end
            end
            store[key] = current + value
            return store[key]
        end,

        delete = function(self, key)
            store[key] = nil
            expiry[key] = nil
        end,

        flush_all = function(self)
            store = {}
            expiry = {}
        end,

        -- 测试辅助：直接查看内部状态
        _store = function(self) return store end,
        _set_time = function(self, key, t) expiry[key] = t end,
    }
end

-- 模拟 ngx 全局对象
function _M.setup()
    _G.ngx = _G.ngx or {}
    ngx.shared = ngx.shared or {}
    ngx.shared.dns_fallback = _M.new_shared_dict()
    ngx.now = function() return os.time() end
    ngx.log = function(level, ...) end  -- 静默
    ngx.NOTICE = 6
    ngx.WARN = 5
    ngx.ERR = 4
    ngx.http_time = function(t)
        return os.date("%a, %d %b %Y %H:%M:%S GMT", t)
    end
end

return _M
```

### 2.3 核心测试用例

```lua
-- t/unit/test_fallback_cache.lua
local mock = require "t.helpers.mock_ngx"
mock.setup()

local dns_fb = require "lib.dns_fallback_cache"

describe("dns_fallback_cache", function()

    before_each(function()
        dns_fb.init("dns_fallback")
        dns_fb.flush_all()
    end)

    -- ========== 基本读写 ==========

    it("正常解析成功后应写入缓存", function()
        dns_fb.record_success("api.example.com",
            "10.0.0.1", {"10.0.0.1"}, 443, 30)
        local ip = dns_fb.get_fallback("api.example.com")
        assert.equals("10.0.0.1", ip)
    end)

    it("未缓存的域名应返回 nil", function()
        local ip, err = dns_fb.get_fallback("unknown.com")
        assert.is_nil(ip)
        assert.equals("no fallback record", err)
    end)

    -- ========== DNS 错误识别 ==========

    it("应识别 DNS 解析错误", function()
        assert.is_true(dns_fb.is_dns_resolution_error(
            'api.example.com could not be resolved'
            .. ' (110: Operation timed out)'))
        assert.is_true(dns_fb.is_dns_resolution_error(
            'no resolver defined to resolve "api.example.com"'))
    end)

    it("不应将 TCP 错误误判为 DNS 错误", function()
        assert.is_false(dns_fb.is_dns_resolution_error(
            "connection refused"))
        assert.is_false(dns_fb.is_dns_resolution_error(
            "connection timed out"))
        assert.is_false(dns_fb.is_dns_resolution_error(
            "broken pipe"))
        assert.is_false(dns_fb.is_dns_resolution_error(nil))
    end)

    -- ========== 使用次数限制 ==========

    it("使用次数达到上限后应拒绝降级", function()
        dns_fb.record_success("api.example.com",
            "10.0.0.1", {"10.0.0.1"}, 443, 30)

        -- 消耗所有降级次数
        for i = 1, dns_fb.MAX_FALLBACK_USES do
            local ip = dns_fb.get_fallback("api.example.com")
            assert.equals("10.0.0.1", ip)
        end

        -- 第 11 次应被拒绝
        local ip, err = dns_fb.get_fallback("api.example.com")
        assert.is_nil(ip)
        assert.equals("fallback uses exhausted", err)
    end)

    -- ========== IP 变更检测（蓝绿保护） ==========

    it("IP 变更时应更新缓存并重置计数", function()
        -- 旧 IP
        dns_fb.record_success("api.example.com",
            "10.0.0.1", {"10.0.0.1"}, 443, 30)

        -- 消耗 5 次
        for i = 1, 5 do
            dns_fb.get_fallback("api.example.com")
        end

        -- IP 变更（蓝绿切换）
        dns_fb.record_success("api.example.com",
            "10.0.0.2", {"10.0.0.2"}, 443, 30)

        -- 应返回新 IP，且计数已重置
        local ip, _, meta = dns_fb.get_fallback("api.example.com")
        assert.equals("10.0.0.2", ip)
        assert.equals(1, meta.uses)  -- 重置后第 1 次
    end)

    -- ========== TTL 计算 ==========

    it("fallback TTL 应为 dns_ttl * K，但不超过上限", function()
        -- dns_ttl=30, K=3 → fallback_ttl=90
        dns_fb.record_success("a.com",
            "1.1.1.1", {"1.1.1.1"}, 80, 30)
        local status = dns_fb.get_status("a.com")
        assert.equals(90, status.fallback_ttl)

        -- dns_ttl=3600, K=3 → 应触顶 300
        dns_fb.record_success("b.com",
            "2.2.2.2", {"2.2.2.2"}, 80, 3600)
        status = dns_fb.get_status("b.com")
        assert.equals(300, status.fallback_ttl)

        -- dns_ttl=2, K=3=6 → 应至少 10s
        dns_fb.record_success("c.com",
            "3.3.3.3", {"3.3.3.3"}, 80, 2)
        status = dns_fb.get_status("c.com")
        assert.equals(10, status.fallback_ttl)
    end)

    -- ========== 手动清除 ==========

    it("clear 应删除指定域名的缓存和计数", function()
        dns_fb.record_success("api.example.com",
            "10.0.0.1", {"10.0.0.1"}, 443, 30)
        dns_fb.get_fallback("api.example.com")  -- uses=1

        dns_fb.clear("api.example.com")

        local ip, err = dns_fb.get_fallback("api.example.com")
        assert.is_nil(ip)
        assert.equals("no fallback record", err)
    end)

end)
```

### 2.4 运行

```bash
busted t/unit/    # 几秒内完成
```

---

## 三、第 2 层：OpenResty 集成测试

这一层在真实的 OpenResty 环境中运行，使用 `Test::Nginx`（OpenResty 官方测试框架）或直接用 `resty` CLI 脚本。核心是**模拟 DNS 故障**。

### 3.1 方案 A：用 Test::Nginx（推荐，与 OpenResty 社区一致）

```perl
# t/integration/001-fallback-basic.t
use Test::Nginx::Socket 'no_plan';

our $HttpConfig = <<'_EOC_';
    lua_shared_dict dns_fallback 2m;
    resolver 127.0.0.88;  # 故意指向不存在的 DNS
    resolver_timeout 2s;

    init_worker_by_lua_block {
        local dns_fb = require "dns_fallback_cache"
        dns_fb.init("dns_fallback")

        -- 预写入一条降级缓存（模拟之前成功解析过）
        dns_fb.record_success(
            "api.example.com", "127.0.0.1",
            {"127.0.0.1"}, $TEST_NGINX_SERVER_PORT, 30)
    }
_EOC_

run_tests();

__DATA__

=== TEST 1: DNS 失败时使用降级缓存
--- http_config eval: $::HttpConfig
--- config
    location /test {
        content_by_lua_block {
            local http_fb = require "http_with_fallback"
            local res, err = http_fb.request_uri(
                "http://api.example.com:" ..
                ngx.var.server_port .. "/backend")
            if res then
                ngx.say("status: ", res.status)
                ngx.say("fallback: ",
                    res.headers["X-DNS-Fallback"] or "no")
            else
                ngx.say("error: ", err)
            end
        }
    }
    location /backend {
        content_by_lua_block {
            ngx.say("OK from backend")
        }
    }
--- request
GET /test
--- response_body
status: 200
fallback: true
--- error_log
[dns-fallback] DEGRADED:
```

### 3.2 方案 B：用 resty CLI 快速验证（更轻量）

```bash
#!/bin/bash
# t/integration/quick_test.sh

# 启动一个临时 OpenResty 实例
# nginx.conf 中 resolver 指向一个不可达的地址

cat > /tmp/test_nginx.conf << 'EOF'
worker_processes 1;
events { worker_connections 64; }
http {
    lua_shared_dict dns_fallback 2m;
    resolver 192.0.2.1;  # RFC 5737 TEST-NET，必不可达
    resolver_timeout 2s;

    lua_package_path "/opt/app/lib/?.lua;;";

    init_worker_by_lua_block {
        local dns_fb = require "dns_fallback_cache"
        dns_fb.init("dns_fallback")
    }

    server {
        listen 18080;

        # 预热降级缓存
        location /seed {
            content_by_lua_block {
                local dns_fb = require "dns_fallback_cache"
                dns_fb.record_success(
                    "test.example.com", "127.0.0.1",
                    {"127.0.0.1"}, 18080, 30)
                ngx.say("seeded")
            }
        }

        # 测试降级
        location /test-fallback {
            content_by_lua_block {
                local http_fb = require "http_with_fallback"
                local res, err = http_fb.request_uri(
                    "http://test.example.com:18080/backend")
                if res then
                    ngx.say("OK, fallback=",
                        res.headers["X-DNS-Fallback"] or "no")
                else
                    ngx.say("FAIL: ", err)
                end
            }
        }

        location /backend {
            content_by_lua_block {
                ngx.say("hello from backend")
            }
        }
    }
}
EOF

# 启动
openresty -c /tmp/test_nginx.conf

# 测试
curl http://127.0.0.1:18080/seed
curl http://127.0.0.1:18080/test-fallback
# 预期输出: OK, fallback=true

# 清理
openresty -s stop
```

---

## 四、第 3 层：Docker Compose 端到端测试

这一层用 Docker Compose 编排完整的测试环境，**可以真实地控制 DNS 服务器的启停和记录变更**。

### 4.1 测试环境架构

```
┌───────────────────────────────────┐
│        docker-compose             │
│                                   │
│  ┌─────────┐   ┌──────────────┐  │
│  │  coredns │   │  openresty   │  │
│  │ :53      │◄──│  resolver    │  │
│  └─────────┘   │  coredns:53  │  │
│                 └──────┬───────┘  │
│                        │          │
│  ┌─────────┐           │          │
│  │ backend  │◄──────────┘          │
│  │ :8080    │                     │
│  └─────────┘                      │
│                                   │
│  ┌──────────────────────────┐     │
│  │  test-runner (curl/lua)  │     │
│  └──────────────────────────┘     │
└───────────────────────────────────┘
```

### 4.2 docker-compose.yml

```yaml
version: "3.8"
services:

  coredns:
    image: coredns/coredns:1.11.1
    volumes:
      - ./test-env/coredns:/etc/coredns
    command: ["-conf", "/etc/coredns/Corefile"]
    networks:
      testnet:
        ipv4_address: 172.28.0.10

  backend-v1:
    image: nginx:alpine
    volumes:
      - ./test-env/backend-v1.conf:/etc/nginx/conf.d/default.conf
    networks:
      testnet:
        ipv4_address: 172.28.0.20

  backend-v2:
    image: nginx:alpine
    volumes:
      - ./test-env/backend-v2.conf:/etc/nginx/conf.d/default.conf
    networks:
      testnet:
        ipv4_address: 172.28.0.21

  openresty:
    image: openresty/openresty:alpine
    volumes:
      - ./lib:/opt/app/lib
      - ./test-env/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf
    depends_on: [coredns, backend-v1, backend-v2]
    networks:
      testnet:
        ipv4_address: 172.28.0.30

  test-runner:
    image: curlimages/curl:latest
    depends_on: [openresty]
    entrypoint: ["sh", "-c", "sleep 3 && sh /tests/run.sh"]
    volumes:
      - ./test-env/tests:/tests
    networks:
      testnet:

networks:
  testnet:
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

### 4.3 CoreDNS 配置（可动态修改）

```
# test-env/coredns/Corefile
.:53 {
    file /etc/coredns/db.test.zone
    log
    errors
}
```

```
; test-env/coredns/db.test.zone
$ORIGIN test.zone.
@       IN SOA  ns1 admin 2024010101 3600 1200 604800 30
        IN NS   ns1
ns1     IN A    172.28.0.10
api     IN A    172.28.0.20   ; 初始指向 backend-v1
```

### 4.4 测试场景脚本

```bash
#!/bin/bash
# test-env/tests/run.sh
set -e

BASE="http://172.28.0.30:8080"
PASS=0
FAIL=0

assert_contains() {
    local desc="$1" url="$2" expected="$3"
    local body
    body=$(curl -sf "$url" 2>&1) || body="CURL_FAILED"
    if echo "$body" | grep -q "$expected"; then
        echo "  PASS: $desc"
        PASS=$((PASS+1))
    else
        echo "  FAIL: $desc"
        echo "    expected: $expected"
        echo "    got: $body"
        FAIL=$((FAIL+1))
    fi
}

# ===== 场景 1：正常请求（DNS 可用） =====
echo "== 场景 1：正常请求 =="
assert_contains \
    "DNS 正常时请求成功" \
    "$BASE/proxy" \
    "backend-v1"

# ===== 场景 2：DNS 故障降级 =====
echo "== 场景 2：DNS 故障降级 =="

# 停止 CoreDNS
docker compose pause coredns
sleep 3

# 等待 resolver 缓存过期（valid=5s for test）
sleep 6

assert_contains \
    "DNS 故障时应降级成功" \
    "$BASE/proxy" \
    "backend-v1"

assert_contains \
    "降级响应应带 X-DNS-Fallback 头" \
    "$BASE/proxy-headers" \
    "X-DNS-Fallback: true"

# 恢复 CoreDNS
docker compose unpause coredns
sleep 3

assert_contains \
    "DNS 恢复后应走正常路径" \
    "$BASE/proxy" \
    "backend-v1"

# ===== 场景 3：蓝绿部署 =====
echo "== 场景 3：蓝绿部署模拟 =="

# 修改 DNS 记录指向 backend-v2
docker compose exec coredns sh -c \
    "sed -i 's/172.28.0.20/172.28.0.21/' \
     /etc/coredns/db.test.zone"
docker compose kill -s SIGUSR1 coredns  # reload
sleep 2

# 等待 DNS 探测发现变更
sleep 20

# 检查降级缓存是否已更新为新 IP
assert_contains \
    "降级缓存应更新为新 IP (v2)" \
    "$BASE/fallback-status?domain=api.test.zone" \
    "172.28.0.21"

# 停止 DNS，验证降级到新 IP
docker compose pause coredns
sleep 6

assert_contains \
    "蓝绿切换后 DNS 故障应降级到新 IP" \
    "$BASE/proxy" \
    "backend-v2"

docker compose unpause coredns

# ===== 场景 4：降级次数耗尽 =====
echo "== 场景 4：降级次数耗尽 =="

docker compose pause coredns
sleep 6

# 消耗所有降级次数
for i in $(seq 1 11); do
    curl -sf "$BASE/proxy" > /dev/null 2>&1 || true
done

assert_contains \
    "次数耗尽后应返回错误" \
    "$BASE/proxy" \
    "error"

docker compose unpause coredns

# ===== 汇总 =====
echo ""
echo "==============================="
echo "  PASS: $PASS  FAIL: $FAIL"
echo "==============================="
[ $FAIL -eq 0 ] && exit 0 || exit 1
```

### 4.5 运行

```bash
docker compose up --build --abort-on-container-exit
# 测试结果在 test-runner 容器的输出中
```

---

## 五、第 4 层：灰度环境验证

### 5.1 灰度验证清单

| 阶段 | 验证项 | 方法 | 通过标准 |
|------|-------|------|---------|
| 部署前 | 降级缓存功能关闭时无副作用 | 部署代码但不启动后台探测 | 所有请求走正常路径 |
| 部署后 | 后台探测正常运行 | 查看日志中的探测记录 | 无 ERR 级别日志 |
| 稳定运行 1h | 监控指标正常 | Prometheus 指标 | `dns_fallback_hits_total` = 0 |
| 手动触发 | 修改 resolver 指向错误 NS | 临时改配置并 reload | 降级成功 + 日志输出 |
| 蓝绿模拟 | 在灰度环境做一次 DNS 切换 | 修改 DNS 记录 | 探测检测到 IP 变更 |
| 长期观察 | 7 天无异常 | 日志 + 指标 | 无误降级 |

### 5.2 灰度环境的安全开关

在配置中加一个全局开关，方便随时关闭降级功能：

```lua
-- 可通过 lua_shared_dict 控制的全局开关
local function is_fallback_enabled()
    local switch = ngx.shared.dns_fallback:get("__enabled__")
    -- 默认关闭，显式设为 "1" 才开启
    return switch == "1"
end

-- 开启: curl /dns-fallback/enable
-- 关闭: curl /dns-fallback/disable
```

这样可以在灰度环境中先部署代码，再通过 API 逐步开启。

### 5.3 关键监控仪表盘

```
┌──────────────────────────────────────────────┐
│  DNS Fallback Cache Dashboard                │
│                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │ 降级触发  │ │ 降级成功  │ │ 降级失败  │     │
│  │   0/min  │ │   0/min  │ │   0/min  │     │
│  └──────────┘ └──────────┘ └──────────┘     │
│                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │ 次数耗尽  │ │ IP 变更   │ │ 缓存条目  │     │
│  │   0/min  │ │   0/day  │ │   12     │     │
│  └──────────┘ └──────────┘ └──────────┘     │
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │  时间线: 降级触发次数                    │    │
│  │  ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁   │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  告警规则:                                    │
│  • 降级触发 > 0 持续 1 分钟 → P3 通知         │
│  • 降级失败 > 0 持续 1 分钟 → P2 告警         │
│  • 次数耗尽 > 0             → P1 紧急         │
└──────────────────────────────────────────────┘
```

---

## 六、CI/CD 集成建议

```yaml
# .gitlab-ci.yml 或 GitHub Actions
stages:
  - unit-test
  - integration-test
  - e2e-test
  - deploy-canary

unit-test:
  stage: unit-test
  image: openresty/openresty:alpine
  script:
    - luarocks install busted
    - busted t/unit/
  # 每次 push 都跑，几秒完成

integration-test:
  stage: integration-test
  image: openresty/openresty:alpine
  script:
    - # 启动 OpenResty + 运行 Test::Nginx
    - prove t/integration/
  # 每次 MR 都跑，1-2 分钟

e2e-test:
  stage: e2e-test
  services:
    - docker:dind
  script:
    - docker compose -f test-env/docker-compose.yml up
      --build --abort-on-container-exit
  # 合入主分支前跑，3-5 分钟
  only:
    - merge_requests

deploy-canary:
  stage: deploy-canary
  script:
    - # 部署到灰度环境，降级开关默认关闭
    - # 手动确认后通过 API 开启
  when: manual
```

---

## 七、快速验证命令速查

日常开发时最常用的验证命令：

```bash
# 1. 跑单元测试（改完代码立刻验证，几秒）
busted t/unit/

# 2. 本地启动 OpenResty 手动测试
openresty -c test-env/nginx.conf
curl localhost:8080/seed                              # 预热缓存
curl localhost:8080/proxy                             # 正常请求
# 手动停 DNS 后：
curl localhost:8080/proxy                             # 验证降级
curl localhost:8080/dns-fallback/status?domain=api.x  # 查看缓存状态

# 3. Docker 端到端测试（完整场景）
docker compose -f test-env/docker-compose.yml up --build

# 4. 灰度环境开关
curl canary-host:8080/dns-fallback/enable   # 开启降级
curl canary-host:8080/dns-fallback/disable  # 关闭降级
curl canary-host:8080/dns-fallback/status?domain=api.example.com
```

---

## 一句话总结

四层测试策略：**单元测试（秒级，验证逻辑正确性）→ OpenResty 集成测试（分钟级，验证 cosocket 降级链路）→ Docker Compose 端到端（分钟级，验证真实 DNS 故障和蓝绿切换）→ 灰度环境（带安全开关逐步放量）**。日常开发改完代码跑 `busted t/unit/` 几秒出结果，合入前跑 Docker 端到端确保蓝绿安全，上线用灰度开关控制风险。