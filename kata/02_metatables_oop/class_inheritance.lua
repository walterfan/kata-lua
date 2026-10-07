-- class_inheritance.lua
-- Demonstrates single inheritance and method overriding with metatables

local Animal = {}
Animal.__index = Animal

function Animal:new(name)
    local instance = setmetatable({}, self)
    instance.name = name or "Unknown"
    return instance
end

function Animal:speak()
    return self.name .. " makes a generic sound"
end

function Animal:extend()
    local sub_class = {}
    sub_class.__index = sub_class
    setmetatable(sub_class, self)
    return sub_class
end

-- Dog subclass
local Dog = Animal:extend()

function Dog:new(name, breed)
    local instance = Animal.new(self, name)
    instance.breed = breed or "Mixed"
    return instance
end

function Dog:speak()
    return self.name .. " (" .. self.breed .. ") barks: Woof!"
end

-- Cat subclass
local Cat = Animal:extend()

function Cat:speak()
    return self.name .. " meows: Meow!"
end

local a = Animal:new("Creature")
local d = Dog:new("Buddy", "Golden Retriever")
local c = Cat:new("Whiskers")

assert(a:speak() == "Creature makes a generic sound")
assert(d:speak() == "Buddy (Golden Retriever) barks: Woof!")
assert(c:speak() == "Whiskers meows: Meow!")

print("02_metatables_oop: class_inheritance passed successfully!")
