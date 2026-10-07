local function greeting(name)
    return "Hello, " .. (name or "Lua") .. "!"
end

assert(greeting("FreeSWITCH") == "Hello, FreeSWITCH!")
assert(greeting() == "Hello, Lua!")

print(greeting("Lua"))
