# Arcane Compiler

Based on my infatuation with Elixir and Odin, along with practicalities of JS

TLDR - A hammer so I can see the world as a nail

### Syntax Pending
```elixir
UserStore.Users :: module => 

  @spec createUser() -> {:ok, User.t()}
  createUser :: () =>
   user = Repo.create(User) ~t(User.t())
   #equivalent
   user ~= Repo.create(User) 
   #equivalent
   %User{} = user ~= Repo.create(User)

   {:ok, user}
  end

  @spec updateUser(^User.t(), map()) -> {:ok, user} | {:error, String.t()} 
  updateUser :: (ref user, values) =>
    #Pass by reference
    checkForUpdates(user)

    user
    |> deref
    |> User.changes(values)
    |> Repo.update()
    =|> 
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
  end

  @spec checkIfBob(User.t()) -> {:ok, true} | {:ok, false} 
  checkIfBob :: ~p(user) => 
   case user =>
     %User{name: "Bob"} -> {:ok, true}
     _user -> {:ok, false}
   end
  end 
end
```

```mermaid
flowchart TD
    A[Source Code] --> B[Lexer]
    B --> C[Parser]
    C --> D[AST]
    D --> E[S-expressions]
    
    E --> F[LLVM IR Generator]
    E --> G[Nix Expression Generator]
    
    F --> H[LLVM Backend]
    G --> I[Nix Evaluator]
    
    H --> J[Native Binary]
    I --> K[Nix Store Path]

    note1[Other Backends]
    note2[System configuration]
    note3[Runtime execution]
    
    E -.- note1
    I -.- note2
    J -.- note3
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/arcane>.

