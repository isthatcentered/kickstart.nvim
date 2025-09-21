# Mark targets as phony (not actual file names) to ensure they always run
.PHONY: test test-watch test-watch-path setup-lua clean

# Configuration variables for Lua environment
LUA_DIR := __lua__                        # Directory for local Lua installation
LUA_ACTIVATE := $(LUA_DIR)/bin/activate   # Path to Lua environment activation script
LUA_VERSION := 5.1.1                     # Lua version (5.1 required for Neovim compatibility)

# Set up local Lua environment with testing dependencies
# This creates an isolated Lua environment to avoid conflicts with system Lua
setup-lua:
	# Check if Lua environment already exists, create if missing
	@if [ ! -f "$(LUA_ACTIVATE)" ]; then \
		echo "Setting up Lua $(LUA_VERSION) with hererocks..."; \
		# Install hererocks if not present (tool for managing multiple Lua versions)
		if ! command -v hererocks >/dev/null 2>&1; then \
			echo "Installing hererocks..."; \
			pip3 install hererocks; \
		fi; \
		# Create local Lua installation with specified version and latest LuaRocks
		hererocks $(LUA_DIR) -l$(LUA_VERSION) -rlatest; \
		echo "Lua $(LUA_VERSION) installed in $(LUA_DIR)"; \
		echo "Installing nlua and busted..."; \
		# Install nlua (Neovim Lua runner) and busted (testing framework)
		bash -c "source $(LUA_ACTIVATE) && luarocks install nlua && luarocks install busted"; \
	fi
	# Ensure nlua is installed (needed for Neovim API access in tests)
	@if [ ! -f "$(LUA_DIR)/bin/nlua" ]; then \
		echo "Installing missing nlua..."; \
		bash -c "source $(LUA_ACTIVATE) && luarocks install nlua"; \
	fi
	# Ensure busted is installed (our test runner)
	@if ! bash -c "source $(LUA_ACTIVATE) && luarocks list | grep -q busted"; then \
		echo "Installing missing busted..."; \
		bash -c "source $(LUA_ACTIVATE) && luarocks install busted"; \
	fi

# Run all tests once
# Depends on setup-lua to ensure test environment is ready
test: setup-lua
	# Use local Lua environment if available, otherwise fall back to system Lua
	@if [ -f "$(LUA_ACTIVATE)" ]; then \
		# Source the Lua environment, set up LuaRocks paths, and run tests
		bash -c "source $(LUA_ACTIVATE) && eval \$$(luarocks path --no-bin) && luarocks test --local"; \
	else \
		# Fallback: use system Lua with LuaRocks paths
		eval $$(luarocks path --no-bin) && luarocks test --local; \
	fi

# Watch for file changes and automatically re-run tests
# Monitors both test files (*_spec.lua) and source files (lua/*.lua)
test-watch: setup-lua
	@if [ -f "$(LUA_ACTIVATE)" ]; then \
		# Find all test files and Lua source files, pipe to entr for file watching
		(find . -name "*_spec.lua"; find lua/ -name "*.lua" 2>/dev/null || true) | entr -s 'source $(LUA_ACTIVATE) && eval $$(luarocks path --no-bin) && luarocks test --local'; \
	else \
		# Fallback version without local Lua environment
		(find . -name "*_spec.lua"; find lua/ -name "*.lua" 2>/dev/null || true) | entr -s 'eval $$(luarocks path --no-bin) && luarocks test --local'; \
	fi

# Watch for test file changes in a specific directory
# Useful for focusing on a subset of tests during development
# Usage: make test-watch-path PATH=lua/some/specific/path/
test-watch-path: setup-lua
ifndef PATH
	$(error PATH is not set. Usage: make test-watch-path PATH=lua/)
endif
	@if [ -f "$(LUA_ACTIVATE)" ]; then \
		# Watch only test files in the specified PATH
		find $(PATH) -name "*_spec.lua" | entr -s 'source $(LUA_ACTIVATE) && eval $$(luarocks path --no-bin) && luarocks test --local'; \
	else \
		# Fallback version for system Lua
		find $(PATH) -name "*_spec.lua" | entr -s 'eval $$(luarocks path --no-bin) && luarocks test --local'; \
	fi

# Clean up the local Lua installation
# Removes the entire __lua__ directory and all its contents
clean:
	rm -rf $(LUA_DIR)
