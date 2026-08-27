# A strongly typed SQL frontend can exist

Because in Lean 4 your schema, your queries and your migrations can all be types, and the compiler checks all three.

This post has three jobs. Communicate that a strongly typed SQL frontend can exist. Explain why it might be valuable. Show the first cut so that you can tell me where it is wrong.

Every code example below compiles on Lean 4.33. The ones marked "does not compile" really do not, and I have pasted what the compiler says.

## First, why Lean?

Also see my post [Why am I betting on Lean 4 for agentic coding?](https://theoric.com/blog/why-lean-4-for-agentic-coding/) from December last year.

You should think of Lean, and other languages with dependent types, as a class above functional programming languages.

In functional programming languages you can pass around functions, combine functions, have one function as the input of another.

In Lean, your types are first class objects. You can create abstract types, combine types, pass around types, and your types themselves can have inputs and parameters. And the compiler enforces all of that.

Three examples.

### Types with conditions

A type can carry a rule. Here is a type for ages, and the rule is that the number is below 150.

```lean
def Age := { n : Nat // n < 150 }

def me : Age := ⟨34, by decide⟩
```

That `by decide` is the proof. The compiler checks `34 < 150` for you. Try to cheat:

```lean
def nobody : Age := ⟨200, by decide⟩   -- does not compile
```

```
error: Tactic `decide` proved that the proposition
  200 < 150
is false
```

Now the more useful version. You do not know at compile time whether a string is an email. So you check once, and the type remembers that you checked.

```lean
def Email := { s : String // s.contains '@' }

def Email.parse (s : String) : Option Email :=
  if h : s.contains '@' then some ⟨s, h⟩ else none
```

Here is the magic: `h` is the proof that the check passed. Once you have a value of type `Email`, nobody downstream can ever hand you a string without an `@` in it. Not you, not a library, not an agent. The validation happened exactly once, and the type carries the receipt.

### Types combining other types

This part will look familiar if you have used Rust or TypeScript. Records, choices, and optional things.

```lean
structure Money where
  amount   : Nat
  currency : String

inductive Payment where
  | card (last4 : String)
  | wire (iban : String)
  | credit

structure Order where
  id     : Nat
  total  : Money
  paidBy : Option Payment
```

`Order` is built out of `Money`, `Payment` and `Option`. And when you pattern match on a `Payment`, the compiler makes you handle every case.

```lean
def describe : Payment → String
  | .card last4 => s!"card ending {last4}"
  | .wire iban  => s!"wire from {iban}"
  | .credit     => "store credit"
```

Forget `.credit` and it does not compile.

### Types with parameters

This is the part that is a class above.

A type can take a value as input. So a database row can take the schema as input, and a row for one schema is a different type from a row for another schema.

Start with the column types a database understands, and a function that maps each of them to a Lean type.

```lean
inductive Ty where
  | int | text | bool

abbrev Ty.denote : Ty → Type
  | .int  => Int
  | .text => String
  | .bool => Bool
```

`Ty.denote` is a function that returns a type. That sentence is not possible in most languages.

A schema is a list of named columns. A row is indexed by the schema it belongs to.

```lean
abbrev Schema := List (String × Ty)

inductive Row : Schema → Type where
  | nil  : Row []
  | cons {n : String} {t : Ty} {s : Schema} : t.denote → Row s → Row ((n, t) :: s)
```

Read `Row : Schema → Type` as: give me a schema, I give you back a type. Now define a table and a row in it.

```lean
abbrev users : Schema := [("id", .int), ("email", .text), ("active", .bool)]

def alice : Row users := .cons 1 (.cons "alice@example.com" (.cons true .nil))
```

That is the whole idea. Everything below is just using it.

## Why do we need a strongly typed database?

### If you accidentally try to push bad data, the compiler will prevent you from doing so.

Wrong type in a column:

```lean
def bob : Row users := .cons "bob" (.cons "bob@example.com" (.cons true .nil))  -- does not compile
```

```
error: Application type mismatch: The argument
  "bob"
has type
  String
but is expected to have type
  Ty.int.denote
```

Missing column:

```lean
def carol : Row users := .cons 3 (.cons "carol@example.com" .nil)  -- does not compile
```

```
error: Application type mismatch: The argument
  Row.nil
has type
  Row []
but is expected to have type
  Row [("active", Ty.bool)]
```

Look at that second error. The compiler is telling you exactly which column you forgot.

### If you accidentally miss a validation, your compiler tells you.

Say withdrawing from an account requires that the account has enough balance. Put that requirement into the function's type.

```lean
structure Account where
  id      : Nat
  balance : Nat

def withdraw (a : Account) (amt : Nat) (_ : amt ≤ a.balance) : Account :=
  { a with balance := a.balance - amt }
```

The third argument is a proof. You cannot call `withdraw` without one.

```lean
def overdraw (a : Account) : Account := withdraw a 1000000  -- does not compile
```

```
error: Type mismatch
  withdraw a 1000000
has type
  1000000 ≤ a.balance → Account
but is expected to have type
  Account
```

The only way to get the proof is to do the check.

```lean
def safeWithdraw (a : Account) (amt : Nat) : Option Account :=
  if h : amt ≤ a.balance then some (withdraw a amt h) else none
```

So the validation is not a thing you remember to do. It is a thing the compiler will not let you forget. This is the exact class of bug that agents introduce: the code works, the tests pass, and the check that used to be there is gone. Here, the check cannot be gone.

### More important, and interesting: typed databases let you express queries which are just super hard to express otherwise.

Column access, checked at compile time. First we need a way to say "column `n` with type `t` exists in schema `s`". That is itself a type.

```lean
inductive HasCol : Schema → String → Ty → Type where
  | here  {s : Schema} {n : String} {t : Ty} : HasCol ((n, t) :: s) n t
  | there {s : Schema} {n n' : String} {t t' : Ty} : HasCol s n t → HasCol ((n', t') :: s) n t
```

Then a lookup that takes the row and the proof that the column is there.

```lean
def Row.get {s : Schema} {n : String} {t : Ty} : Row s → HasCol s n t → t.denote
  | .cons v _, .here    => v
  | .cons _ r, .there h => r.get h

def Row.col {s : Schema} (r : Row s) (n : String) {t : Ty}
    (h : HasCol s n t := by repeat constructor) : t.denote :=
  r.get h
```

That `by repeat constructor` is the compiler searching the schema for the column at compile time. You just write the column name.

```lean
#eval alice.col "email"    -- "alice@example.com"
#eval alice.col "active"   -- true
```

Notice the return types. `alice.col "email"` is a `String`. `alice.col "active"` is a `Bool`. Not a `Value`, not an `Any`, not a string you cast later. The type of the result depends on which column you asked for.

And a typo:

```lean
#eval alice.col "emial"  -- does not compile
```

```
error: unsolved goals
⊢ HasCol [] "emial" ?m.3
```

The compiler walked the whole schema, ran out of columns, and stopped you. Your SQL database would have told you at 3am.

Now joins. The result schema of a join is computed from the input schemas. In the type.

```lean
def Row.append {a b : Schema} : Row a → Row b → Row (a ++ b)
  | .nil,      r => r
  | .cons v l, r => .cons v (l.append r)

abbrev orders : Schema := [("order_id", .int), ("total", .int)]

def joined : Row (users ++ orders) :=
  alice.append (.cons 17 (.cons 4200 .nil))

#eval joined.col "total"   -- 4200
```

`Row (users ++ orders)` is a type that was computed by concatenating two lists. You never wrote the joined schema down. The compiler derived it, and `joined.col "total"` type-checks against the derived schema.

Try doing that in an ORM.

## Design goals

**Forward compatibility with SQL databases.** You should be able to import your existing SQL database into LeanDB and start using it right away. Your `CREATE TABLE users (id INTEGER, email TEXT, active BOOLEAN)` becomes a `users : Schema`. Nothing moves.

**Reasonable performance.** Built for eventual use in real world systems. Types are checked at compile time and erased at runtime. The proofs cost nothing when the query runs.

**Strongly typed domain schemas for data.** The compiler should ensure that your database is always coherent. Not "usually coherent, with a nightly job that finds the rows that are not".

**Strongly typed queries.** Everything above. Wrong column, wrong type, wrong shape, missing check: does not compile.

**Typed migrations.** Production database migrations are a nightmare. Here is what a migration looks like when it is a function between row types.

```lean
abbrev Schema.addCol (s : Schema) (n : String) (t : Ty) : Schema := (n, t) :: s

def Row.addCol {s : Schema} {n : String} {t : Ty} (default : t.denote)
    (r : Row s) : Row (s.addCol n t) :=
  .cons default r

def Row.dropCol {s : Schema} {n : String} {t : Ty} : Row (s.addCol n t) → Row s
  | .cons _ r => r
```

The up migration takes a `Row s` and returns a `Row (s.addCol n t)`. It cannot return anything else. It cannot forget the default. It cannot silently drop a different column.

And because a migration is just a function, you can prove things about it. Here is a proof that the down migration undoes the up migration, for every row, every schema, every default value.

```lean
theorem migration_reversible {s : Schema} {n : String} {t : Ty}
    (d : t.denote) (r : Row s) : (r.addCol (n := n) d).dropCol = r := rfl
```

That proof is `rfl`. The compiler can see it is true by just computing. You did not test the rollback on staging. You proved the rollback.

```lean
abbrev usersV2 := users.addCol "plan" .text

def aliceV2 : Row usersV2 := alice.addCol "free"

#eval aliceV2.col "plan"   -- "free"
#eval aliceV2.col "email"  -- "alice@example.com"
```

## First cut

[LeanDB v0.1](https://github.com/theoriclabs/leandb) is live and available on GitHub.

It is a first cut. The type layer works the way this post describes. The parts that talk to an actual SQL database are young. Expect rough edges, and please tell me about them.

We intend to use it in [compute.cx](https://compute.cx) as the underlying datastore, the thing that routes your computations to the fastest, or cheapest, or "best" GPU available. That is a problem with a lot of invariants (a job cannot be scheduled twice, a GPU cannot be over-committed, a price quote cannot go stale mid-route) and we would rather the compiler hold them than a test suite.

If you want to poke at the ideas without cloning anything, the full example file from this post is [here](https://gist.github.com/hargup/f8c68821d28250c7e2b3e78e2c31e08c). It compiles on its own, no dependencies.

## FAQs

**Is this an ORM?**
No. An ORM maps tables to objects and trusts you from there. LeanDB is a type layer. The schema, the queries and the migrations are types, and the compiler checks them against each other. The storage engine underneath stays boring.

**Do I have to write proofs for every query?**
Mostly no. Column lookups, joins and bounds checks are discharged automatically, the way `by repeat constructor` and `by decide` did above. You write a proof by hand only where you would have written a validation by hand anyway. The difference is that you cannot skip it.

**Does this replace my Postgres?**
No. Design goal one is that you import what you have. LeanDB sits in front of your SQL database, not instead of it.

**What does it cost at runtime?**
Nothing extra. Proofs are erased when the code is compiled. What runs is the query.

**Isn't Lean too niche for a database layer?**
For humans, maybe. For agents, Lean is the point. The reason I am betting on Lean 4 for agentic coding is that an agent cannot ship code that does not compile, and with dependent types "does not compile" covers "forgot a validation" and "broke an invariant". A database is where those bugs hurt the most. See the December post.

**Why not Idris, Haskell, or Rust?**
Idris has the types but not the ecosystem or the tooling momentum. Haskell can fake a lot of this with extensions, and it gets ugly fast. Rust's types describe the shape of data, not its behaviour. Lean 4 has the types, a real compiler, an LSP that exposes everything, and a very active community.

**What do you want feedback on?**
Whether the query layer feels natural or feels like fighting the compiler. Whether the migration story would actually work on a database you run. What the first query is that you tried to write and could not. Reply on X, or open an issue on the repo.
