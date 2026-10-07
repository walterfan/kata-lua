-- vector2d.lua
-- Demonstrates operator overloading using metatables

local Vector2D = {}
Vector2D.__index = Vector2D

function Vector2D.new(x, y)
    local self = setmetatable({}, Vector2D)
    self.x = tonumber(x) or 0
    self.y = tonumber(y) or 0
    return self
end

function Vector2D.__add(a, b)
    return Vector2D.new(a.x + b.x, a.y + b.y)
end

function Vector2D.__sub(a, b)
    return Vector2D.new(a.x - b.x, a.y - b.y)
end

function Vector2D.__mul(a, scalar)
    if type(a) == "number" then
        return Vector2D.new(b.x * a, b.y * a)
    end
    return Vector2D.new(a.x * scalar, a.y * scalar)
end

function Vector2D.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector2D:__tostring()
    return string.format("Vector2D(%.1f, %.1f)", self.x, self.y)
end

function Vector2D:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

-- Test operators
local v1 = Vector2D.new(3, 4)
local v2 = Vector2D.new(1, 2)

local v3 = v1 + v2
assert(v3.x == 4 and v3.y == 6)

local v4 = v1 - v2
assert(v4.x == 2 and v4.y == 2)

local v5 = v1 * 2
assert(v5.x == 6 and v5.y == 8)

assert(v1:length() == 5)
assert(tostring(v1) == "Vector2D(3.0, 4.0)")
assert(v1 == Vector2D.new(3, 4))

print("02_metatables_oop: vector2d passed successfully!")
