# C Compiler

A complete C compiler implementation built in four stages as part of **CSE310 Compiler Sessional (July 2023)**. The compiler translates a subset of C into x86 assembly, covering all major compilation phases: lexical analysis, symbol table management, syntax & semantic analysis, and intermediate code generation.

-----------------

## C Subset Supported

| Feature | Supported |
|---|---|
| Data types | `int`, `float`, `char`, `void` |
| Arithmetic operators | `+`, `-`, `*`, `/`, `%` |
| Relational operators | `<`, `>`, `<=`, `>=`, `==`, `!=` |
| Logical operators | `&&`, `\|\|`, `!` |
| Bitwise operators | `&`, `\|`, `^`, `~`, `<<`, `>>` |
| Assignment operators | `=`, `+=`, `-=`, `*=`, `/=` |
| Increment/Decrement | `++`, `--` (prefix and postfix) |
| Control flow | `if-else`, `for`, `while` |
| Functions | Declarations, definitions, calls |
| Arrays | Single-dimensional with index access |
| Scoping | Nested local/global scopes |

--------------------

## Compiler Phases

```
Source (.c)
    │
    ▼
Lexical Analyzer      →  token stream + symbol table entries
    │
    ▼
Syntax Analyzer       →  parse tree
    │
    ▼
Semantic Analyzer     →  type-checked AST + error/warning log
    │
    ▼
Code Generator        →  x86 assembly (.asm)
```
----------------------

## Assignment 1 — Symbol Table

Implements a multi-scope symbol table using hash tables with separate chaining.

**Components:**
- `SymbolInfo` — stores symbol name, type, and next pointer
- `ScopeTable` — a single hash table scope (uses sdbm hash, chains on collision); scope IDs are hierarchical (e.g., `1.2.3`)
- `SymbolTable` — a stack of `ScopeTable`s managing nested scopes

**Operations supported:** `I` (insert), `L` (lookup), `D` (delete), `P` (print), `S` (enter scope), `E` (exit scope), `Q` (quit)

**Build & Run:**
```bash
cd symboltable
g++ Main.cpp ScopeTable.cpp SymbolTable.cpp SymbolInfo.cpp -o symboltable
./symboltable
```

---

## Assignment 2 — Lexical Analyzer


A Flex-based lexer for a subset of C that tokenizes source code and populates the symbol table.

**Tokens recognized:**
- Keywords: `if`, `else`, `for`, `while`, `do`, `int`, `float`, `char`, `double`, `void`, `return`, `switch`, `case`, `default`, `break`, `continue`
- Integer and floating-point constants
- Character and string literals (including multi-line strings with backslash continuation)
- All C operators and punctuators
- Identifiers (inserted into symbol table)
- Single-line (`//`) and multi-line (`/* */`) comments (ignored)

**Error detection:**
- Redundant decimal points (e.g., `3.1.4`)
- Ill-formed numbers (e.g., `1E10.7`, `12abcd`)
- Multi-character char literals (`'ab'`)
- Unterminated char/string literals and comments
- Unrecognized characters

**Build & Run:**
```bash
cd lexical_analyzer
flex 2005059.l
g++ scanner.cpp lex.yy.c -o lexer
./lexer < input.txt
# or use the helper script:
bash command.sh
```

**Output files:** `token.txt` (tokens), `log.txt` (detailed log)

---

## Assignment 3 — Syntax & Semantic Analyzer


A Flex + Bison parser that performs full syntax analysis and semantic checking.

**Grammar covers:**
- Global and local variable declarations
- Function declarations and definitions
- Expressions with correct operator precedence and associativity
- Control flow: `if-else`, `for`, `while`
- Function calls with arguments
- Single-dimensional arrays with index expressions
- `return` and `println` statements

**Semantic checks:**
| Check | Description |
|---|---|
| Duplicate declaration | No two variables/functions with same name in the same scope |
| Type mismatch | Assignment operand types must be consistent |
| Array index type | Index expression must be integer |
| Modulus operands | `%` requires integer operands |
| Function arguments | Argument count and types must match definition |
| Void in expression | Void-returning functions cannot appear in expressions |
| Float-to-int | Implicit narrowing assignments produce a warning |

**Build & Run:**
```bash
cd "Syntax & Semantic Analyzer"
flex lexer.l
bison -d parser.y
g++ parser.tab.c lex.yy.c -o parser
./parser < input.c
# or:
bash command.sh
```

**Output files:** `parseTree.txt`, `log.txt` (grammar rule trace), `error.txt`

---

## Assignment 4 — Intermediate Code Generation

**Location:** [ICG/code/](ICG/code/)

Extends the parser to emit x86 (8086) assembly code targeting the DOS `MODEL SMALL` architecture.

**Features:**
- Global variable declarations in `.DATA` segment
- Function prologue/epilogue with stack frame setup
- Local variable offset calculation on the stack
- Expression evaluation with register allocation
- Conditional and unconditional jumps for control flow
- `NEWLINE` and `PRINTNUMBER` helper procedures in output assembly
- Peephole-style optimized output (`optcode.asm`)

**Build & Run:**
```bash
cd ICG/code
flex lexer.l
bison -d parser.y
g++ parser.tab.c lex.yy.c -o icg
./icg < input2.c
# or:
bash command.sh
```

**Output files:** `code.asm` (raw assembly), `optcode.asm` (optimized assembly), `parseTree.txt`, `log.txt`, `error.txt`


---

## Technology Stack

- **Flex** — lexical analysis (tokenizer generation)
- **Bison (GNU Yacc)** — LALR(1) parser generation
- **C++** — all implementation
- **x86 Assembly** — compilation target
