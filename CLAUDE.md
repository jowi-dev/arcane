# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Arcane is a custom programming language compiler written in Elixir. It's inspired by Elixir, Odin, and JavaScript, designed to compile to multiple backends including LLVM IR for native binaries and Nix expressions for system configuration.

## Development Commands

### Core Mix Commands
```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Run specific test file
mix test test/path/to/test_file.exs

# Run tests with coverage
mix test --cover

# Generate documentation
mix docs

# Start interactive shell with project loaded
iex -S mix

# Format code
mix format
```

### Compilation Pipeline
The compiler can be used interactively in `iex -S mix`:
```elixir
# Compile expression and dump LLVM IR to stdout
Arcane.compile_expression("some_expression")

# Compile expression and create executable
Arcane.compile_and_build("some_expression", "output_name")
```

## Architecture

### High-Level Pipeline
Source Code → Lexer → Parser → AST → S-expressions → Backend (LLVM IR/Nix/etc.) → Output

### Key Modules Structure

**Core Entry Point:**
- `Arcane` - Main API module with `compile_expression/1` and `compile_and_build/2`

**Parser Components:**
- `Arcane.Parser` - Main parser converting tokens to AST/S-expressions
- `Arcane.Parser.Lexer` - Tokenization of source code
- `Arcane.Parser.Token` - Token type definitions
- `Arcane.Parser.Statement` - Statement parsing logic
- `Arcane.Parser.Expression` - Expression handling
- `Arcane.Parser.Declaration` - Declaration parsing
- `Arcane.Parser.Branch` - Branch/conditional parsing
- `Arcane.Parser.Context` - Parser context management

**Compiler Components:**
- `Arcane.Compiler` - Main compiler API delegating to frontend/backends
- `Arcane.Compiler.CompilerFrontend` - S-expression generation from AST
- `Arcane.Compiler.LLVMBackend` - LLVM IR generation and executable creation

### Compilation Flow
1. **Frontend**: `Parser.pass_through()` (currently bypassing actual parsing)
2. **S-Expression Generation**: `Compiler.compile_s_expression()`  
3. **Backend Compilation**: `Compiler.compile_llvm()` for LLVM IR output or executable generation

### Output Directory
- Compiled artifacts are placed in `./target/` directory
- LLVM IR files and executables are generated here

## Language Design Notes

The language syntax (as documented in README.md) features:
- Module-based architecture similar to Elixir
- Explicit dependency declarations
- Arrow function syntax from JavaScript
- Type system with struct declarations
- Pattern matching for conditionals
- Resource management with `using` blocks and automatic cleanup
- Tail call optimization for recursion
- Memory arena allocation for predictable performance

## Current State

Based on recent commits, the project is focusing on:
- Boolean algebra implementation needed for conditional logic
- Branch expressions as a fundamental language construct
- Match expressions for pattern matching
- Statement/token relationship refinement

The parser currently uses `pass_through()` suggesting active development of the parsing pipeline.
- save this for later