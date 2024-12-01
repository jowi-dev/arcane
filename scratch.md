```rust

// Everything is a module. This is familiar to Elixir,
// but differs in that there are explicit declarations for
// dependencies, behaviours, macros, and system deps.
Arcane.CreateContract :: contract_module (
  deps: [],
  sys: [],
  expands: [],
  contracts: []
) => {

    // contact modules describe declarations without implementations
    create(map()) -> Result<T, E>

}

// Modules are just declarations
Arcane.CreateMacro :: macro_module {
    

}
```


## Architecural Philosophy
In Arcane, The AST is just a collection of Declarations, Expressions, Statements, and Tokens.
- Declarations are referencable inter or intra-application values
- Expressions are structured statements which accept input and provide output
- Statements are a collection of values and operations which can be evaluated
- Tokens are the smallest building block, representing either values or operators

The ideal for Arcane is a language which is void of special forms, yet expressive and readable. 
- Words should be meaningful, and symbols should be used when possible for concise syntax that is clear in intent.
- The language is extendable at the expression level. Expressions provide coordinated intent to reduce redundancy without hiding functionality.
- Dependencies are grouped by their origins and usage. This means clear boundaries on third party code.
- The Core Grammar should easily cover most cases, The Core library should cover any non-trivial but common implementation outside the grammar
```mermaid
A[Declarations] -> B[Expressions]
A[Declarations] -> C[Tokens]
B[Expressions] -> D[Statements]
D[Statements] -> C[Tokens]
```
