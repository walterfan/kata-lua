# 8.1 Lua 核心语法速查

## 1. 基础类型

- `nil`, `boolean`, `number`, `string`, `function`, `userdata`, `thread` (协程), `table`

## 2. 模式匹配符号速查

| 字符类别 | 含义 |
|---|---|
| `.` | 任意字符 |
| `%a` | 字母 |
| `%c` | 控制字符 |
| `%d` | 数字 (0-9) |
| `%l` | 小写字母 |
| `%u` | 大写字母 |
| `%p` | 标点符号 |
| `%s` | 空白字符 |
| `%w` | 字母与数字 |
| `%x` | 十六进制数字 |
| `%bxy`| 平衡匹配（如 `%b()` 匹配括号配对） |

## 3. 标准库常用函数

```lua
-- 字符串
string.format("%s %04d", "id", 7)
string.gmatch("hello world", "%a+")
string.gsub("hello 123", "(%d+)", "[%1]")

-- 表
table.insert(t, val)
table.remove(t, idx)
table.concat(t, ", ")
table.sort(t, function(a, b) return a > b end)
```
