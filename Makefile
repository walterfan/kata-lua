LUA ?= lua
LUAC ?= luac
UV ?= uv
CC ?= cc
PKG_CONFIG ?= pkg-config
LUA_PKG ?= lua
LUA_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags $(LUA_PKG) 2>/dev/null || pkg-config --cflags lua-5.4 2>/dev/null || echo "")
LUA_LIBS ?= $(shell $(PKG_CONFIG) --libs $(LUA_PKG) 2>/dev/null || pkg-config --libs lua-5.4 2>/dev/null || echo "-llua")
CFLAGS ?= -O2 -Wall -Wextra -Wpedantic -fstack-protector-strong

.DEFAULT_GOAL := help

.PHONY: all run test check deps c-demo lua-state-demo doc-html doc-serve clean help

all: check test docs

run:
	$(LUA) kata/01_basics/basic_types.lua

test:
	@echo "==> Running 01_basics katas..."
	$(LUA) kata/01_basics/basic_types.lua
	$(LUA) kata/01_basics/closure_memo.lua
	$(LUA) kata/01_basics/pattern_matching.lua
	@echo "==> Running 02_metatables_oop katas..."
	$(LUA) kata/02_metatables_oop/vector2d.lua
	$(LUA) kata/02_metatables_oop/class_inheritance.lua
	@echo "==> Running 03_coroutines katas..."
	$(LUA) kata/03_coroutines/generator_pipeline.lua
	$(LUA) kata/03_coroutines/micro_scheduler.lua
	@echo "==> Running 05_testing katas..."
	LUA_PATH="?.lua;./?.lua;;" $(LUA) kata/05_testing/test_ivr_service.lua
	@echo "==> Running 06_redis_scripts katas..."
	$(LUA) kata/06_redis_scripts/simulate_redis.lua
	@echo "==> Running legacy basics katas..."
	$(LUA) kata/basics/hello.lua
	$(LUA) kata/basics/insert_sort.lua
	@echo "==> All executable kata tests passed!"

check:
	@echo "==> Syntax-checking all Lua files with luac..."
	find kata -name '*.lua' -print0 | xargs -0 -n1 $(LUAC) -p
	@echo "==> All Lua files passed syntax check!"

deps:
	$(UV) sync

DOCS = lua-cheat-sheet.md doc/README.md doc/basic.md doc/freeswitch.md doc/lua_test.md

PANDOC ?= pandoc

docs:
	mkdir -p build
	@if command -v $(PANDOC) >/dev/null 2>&1; then \
		$(PANDOC) --from gfm --standalone --metadata title="kata-lua" $(DOCS) -o build/kata-lua-docs.html; \
		echo "==> Generated build/kata-lua-docs.html"; \
	else \
		echo "pandoc not found, skipping single-page HTML doc generation."; \
	fi

build/call_lua_demo: kata/04_c_interop/call_lua_demo.c
	mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LUA_CFLAGS) $< -o $@ $(LUA_LIBS)

c-demo: build/call_lua_demo
	@echo "==> Running C call Lua demo..."
	./build/call_lua_demo

build/lua_state_demo: kata/04_c_interop/lua_state_demo.c
	mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LUA_CFLAGS) $< -o $@ $(LUA_LIBS)

lua-state-demo: build/lua_state_demo
	@echo "==> Running Lua call C demo..."
	./build/lua_state_demo

doc-html:
	$(MAKE) -C doc html

doc-serve:
	$(MAKE) -C doc serve

clean:
	rm -rf build
	$(MAKE) -C doc clean-all 2>/dev/null || true

help:
	@printf '%s\n' \
		'make run            Run the introductory Lua kata' \
		'make test           Run all runnable kata checks' \
		'make check          Syntax-check all Lua files with luac' \
		'make deps           Install documentation Python libraries with uv' \
		'make c-demo         Build and execute the C-calling-Lua demo' \
		'make lua-state-demo Build and execute the Lua-calling-C demo' \
		'make doc-html       Build Sphinx HTML documentation' \
		'make doc-serve      Serve documentation at http://localhost:8000' \
		'make clean          Remove build artifacts' \
		'make all            Run syntax checks and all tests'
