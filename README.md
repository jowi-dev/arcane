# Arcane Compiler

Based on my infatuation with Elixir and Odin, along with practicalities of JS

TLDR - A hammer so I can see the world as a nail

### Syntax Pending
```elixir
UserStore.Users :: module(%{
    # Dependencies declared as parameters of the module
    attrs: %{ },
    deps: [
        Arcane.Repo,
        Arcane.UserLand
    ],
    c_deps: [ SDL ],
    expands: [ Arcane.MemoryReference, Arcane.Loop ]
}) => 

  @doc """
  Creates a user

  createUser/0
  input: None
  output: {:ok, User.t()}
  """
  createUser :: func() =>
    # Type declaration is always -> at the end of a statement
    user = Repo.create(User) -> User.t()

    # Type inference is a familiar <-
    user <- Repo.create(User) 

    # Pattern matching also available
    %User{} = user <- Repo.create(User)

    {:ok, user}
  end

  @pub renderUser(^User.t()) -> :ok
  renderUser :: (user) =>
    stop = false -> boolean()

    # variables must be initialized! this will result in a compiler error
    input -> UserLand.KeyboardInput.t()

    renderLoop :: loop (
        until: input.keyDown == "C" and input.modifier == "Ctrl",
        max: :infinity
    ) =>
        SDL.draw(user)
        input = UserLand.gatherInput()
    end

    renderStart <- Label

    drawUser(user)
    input <- Arcane.UserLand.gatherInput()

    # Rather than having loop ceremony, we use jump statements
    # jumpEqual also available
    if not (input.keydown == "C" and input.modifier == "Ctrl") then
        jump renderStart
    end

    IO.puts("Ctrl-C Pressed. Goodbye")
  end

  @pub validUserDoc(String.t()) -> boolean()
  validUserDoc :: (filename) =>
    using
      file <- Arcane.File.open(filename)
      metric <- Arcane.Metrics.connect() 
    =>
     result <- 
       file
       |> Arcane.File.read_line()
       |> Stream.map(line) =>
         contains_arcane = String.contains?(line, "ARCANE IS NEAT") -> String.t()
         Metrics.increment(metric, "user_likes_arcane", contains_arcane)
         contains_arcane
       end
       |> Stream.find(line => line == true)

      result || false
    end
  end

  @doc """
  Given a User, update it with a map of arguments
  Multi-line string
  """
  @pub updateUser(^User.t(), map()) -> {:ok, user} | {:error, String.t()} 
  updateUser :: (user_ref, values) =>
    # Pass by reference
    checkForUpdates(user_ref)

    # referencing/deferencing via keywords `ref` and `deref`

    # String concatenation + dereferencing
    values = Map.put(values, :name, "#{deref(user_ref).first} Apple")

    result <-
        user_ref
        |> deref
        |> User.changes(values)
        |> Repo.update()

    switch =>
        result@{:ok, user} ? ({:ok, user}),
        result@{:error, _} ? ({:error, "Failed to update"})
    end
  end

  # We have options 
  @priv checkIfBob(User.t(), boolean()) -> {:ok, true} | {:ok, false}
  checkIfBob :: (user, false) => (user.email == "bob@bob.com")
  checkIfBob :: (%User{name: "Bob"}, true) => (true)
  checkIfBob :: (_,_) => (false)

  checkIfBob :: (user, useName?) => 
   switch
     user@%User{name: "Bob"} ? {:ok, true}
     _user ? {:ok, false}
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

