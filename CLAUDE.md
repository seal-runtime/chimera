# Directions for agents (Claude specifically)

## Initial prompt

This is an HTML static site DSL library for Luwu-enabled seal ('scl' ~/.zshrc
alias).

Objective is to make an object oriented DSL that uses luwu classes features to
best ability. This should be well organized and readable by humans. End product
is a composable fluent OOP interface for using classes (ideally with primary
constructor and POD syntax) to easily define and roundtrip to/from HTML static
websites. We should support things like menus, styling/stylesheets/themes,
buttons, expand/hide/etc. and adding user defined JS, although ideally we should
be able to abstract simple stuff like buttons, dropdowns, containers, etc. to
Luwu itself. Users should be able to define their own kinds of
elements/components/whatever you call them and register them into the library so
roundtripping from html works. For theming, users should be able to use and
implement themes and be able to override styles for specific elements and
specific containers/user defined components/etc. a theme itself can be a class
that implements a Theme trait; when site or user changes theme I expect all
elements in the document to update. So components can be placed in a Document
which holds the 'global' state like that without requiring users handle their
own global state.

Doc comments use `--[=[]=]` and `---` syntax.

Internal library code goes in ./src/*. This is Luwu code, not Luau code. Use
`~/Repositories/luwu`'s RFCs as docs for Luwu-specific features such as classes,
traits, do exprs, table comps, destructuring, etc.. Make a reusable Luwu claude
skill as you go to organize best practices for Luwu programming and
typechecking/validation for agents. seal runtime documentation is available in
`~/Repositories/seal` markdown and `.seal/typedefs/**`.

All code must be Luwu strict compatible. If you do an `:: any` cast or otherwise
bypass the type system unnecessarily (for reasons other than a straight up Luwu
bug) I will embarrass you in front of your family (don't do it). Use
luwu-analyze (the one that lives in the luwu directory and adds --defs support)
with seal's globals (`--defs`) to check code validity and type safety. It should
recognize std defs when ran in this dir. Rebuild it if it doesn't support latest
Luwu syntax. If it doesn't recognize real Luwu syntax check to ensure you pass
in the correct FFlags (non Debug prefixed flags should work but ??)

Local variables, functions, methods, etc., should be snake case. Use `const`
instead of `local` like `const` instead of `let` in JS/TS. All `local` variables
should be mutated or converted into `do/give` for `const` if doing so makes more
sense/is readable.

Enable `--!lint ConstLocal` to statically check exactly which `local`s can be
made `const` in analysis.

Classes, traits, and types (aliases) should be PascalCase. Use `do-give`
expressions when the PURPOSE is logic that builds up the variable we *care
about*, unless of course it's shared logic to abstract into a `const function`
(same as a local function but spelled via `const`). Use table comprehensions
instead when this is a map/filter on a table. You may use `--!trust` and must
use `--!optimize 2` compiler directives in each file to enable more aggressive
inlining.

Do NOT add doc comments describing the "how", only "why" in relation to bigger
picture. NO HISTORY COMMENTS. If doubt, code inside functions should explain
itself without needing comments at all. If you must add comments, LEAD WITH THE
POINT. Sentences MUST have FEWER THAN 4 CLAUSES and NEVER BE ROUNDABOUT. Of
course, all user facing documentation comments (visible in editor) must be
properly documented with luwu codeblock examples. Module/file level docs belong
on the local/const/type/thing being returned, not at the top of the module. This
is because lsp attaches comments to types and runtime values not to files. 

`init.luwu` in top level is what consumers require via
`require("@libraries/chimera")`; where `@libraries` is a require-by-string alias
that points to wherever this `chimera` directory exists.

Each 'component/element/whatever' should be a class. Reusable logic should be
traits. Luwu traits are basically "classes that cannot be instantiated"... name
them like classes, don't name them like XBehavior/HtmlComponentFactory/etc.
nonsense. Traits CAN be named after more abstract concepts that they manage. If
needed, you can use the trait factory pattern to make a trait that instantiates
specific objects of classes that implement the trait. I prefer possibly nested
directories that organize related files/modules/classes by purpose rather than a
flat directory inside src with purpose separated by underscores. Classes should
implement Display `display` and `__tostring` as well as To/From Html, which can
be traits with default impls that can be overriden. This is so we can pretty
print html containers in terminal w/out needing to html serialize. seal's
`print` calls `display` method on classes before going to `tostring`, but
interpolated strings only call `__tostring` on interpolation. Useful traits
users can use to implement their own custom components/help reduce the amt of
work should be made available to user code using this library.

Tests go in the `./tests` folder. There can be a test orchestrator file
`run.luwu` that runs the tests; each test should be a module that returns the
test functions as a map of name, test, whatever.

Note that very hot code should be in the same module to take advantage of method
inlining. This means if an external caller needs to call a ton of the same
methods from a different file consider making such a method on the class that
exists in the class' own file.

## Implementation

"chimera" is a working name: a UI library already uses it. Will be renamed
later.

### Commands

- `scl` is `~/Repositories/seal/target/release/seal` (seal built against Luwu).
  Agents' shells lack the alias: call it by path. System `seal` is 0.8.x and
  can't run this code.
- Tests: `scl test` runs `tests/run.luwu`; `scl test site` runs one suite.
- Example site: `scl ./examples/site.luwu` writes `examples/out/`. It is checked in, so people without a
  Luwu-enabled seal can read the docs: rebuild it after any change that affects the site.
- Typecheck a file: `~/Repositories/luwu/luwu-analyze
  --defs=.seal/typedefs/globals.d.luau <file>`. Sweep with `for f in $(fd -e
  luwu . src tests examples --exclude out) init.luwu; do luwu-analyze ... $f;
  done`. Keep it at zero diagnostics, lints included. Lines stay at 120
  characters or fewer.
- Editor errors that `luwu-analyze` doesn't show mean luwu-lsp is stale: its
  `luwu` submodule must track luwu's latest `integration` commit.
- Visual checks: `firefox --headless --no-remote --profile <scratch>/ffprofile
  --window-size=WxH --screenshot out.png file://...`. Headless renders the light
  defaults; add `?theme=catppuccin-mocha` (any offered theme's name) to the URL
  for another. The window height sets how much of the page the shot covers, and
  headless reports no mouse, so `(hover: hover)` media rules don't apply.

### Layout

```text
init.luwu              consumer entry: Component, Container, Layout, SourceCode, Document, Parser, and the hubs
src/core/markup.luwu   Writer, Attributes, the core traits, Text/Raw/Comment/Fragment/Tag
src/elements/          one class per HTML tag: text, layout, lists, forms, tables, disclosure, head
src/components/        higher-level pieces: Menu, Dropdown, Toggle, ThemeSwitcher, Card, SiteFooter (components.luwu),
                       Row/Column/Grid (layout.luwu), CodeBlock/Code (code.luwu)
src/style/             Style, Rule (style.luwu), typed CSS (properties.luwu), Color, Token, Theme/Palette
src/themes/            ready-made themes: Light, Dark (init.luwu), the Catppuccin flavors (catppuccin.luwu)
src/document/          Document: one page, its head, themes and generated CSS/JS
src/site/              Site, Page, PageLink, TableOfContents, Breadcrumbs
src/parse/parser.luwu  HTML back into chimera objects
tests/                 run.luwu runs every suite; each suite returns { [name]: () -> () }
examples/site.luwu     the docs site: home page and Site config
examples/guide/        chimera's guide, one module per page; example.luwu cuts `--@ name` snippets from
                       the page's own source so each example shows the code that built it
examples/luwu/         the Luwu language docs
```

Each directory has an `init.luwu` hub re-exporting its modules (`export .{ ... }
= require("@self/...")`, types via `export type .{ ... } = module`). `.luaurc`
has one alias per directory (`@core`, `@elements`, ...); modules require each
other through those, never `require("..")`. Users import from the hubs:
`chimera.elements`, `chimera.components`, `chimera.style`, `chimera.themes`,
`chimera.site`, `chimera.core`.

Where a class belongs:

- **elements**: a plain HTML tag, rendered without `data-element`, registered by
  tag with `Element.register_class`.
- **components**: anything higher-level, rendered with `data-element="<Class>"`
  and registered with `Component.register`. The parser rebuilds them from that
  attribute.
- **site**: components that only make sense inside a `Site` (they read the page
  tree from the `Writer`).
- **top level**: traits users implement (`Component`, `Container`, `Layout`, `SourceCode`), and `Document` and
  `Parser`.

### Core model (`src/core/markup.luwu`)

Every node implements `Markup` (`render`, `to_html`, `child_nodes`,
`display`/`__tostring`). The traits, by `needs`:

- `Child`: can sit inside a container (text, comments and every element).
- `Tagged`: `expect function tag(): string`, a static giving the HTML tag.
- `Element needs Markup, Tagged`: attributes, style classes, inline style,
  scoped rules (`style_inside`), events, `default_styles` (CSS the class needs
  once per page), `head_elements` (scripts/links it needs), `lists_headings`,
  `adopt` (taking parsed children), `render_open`/`render`. It re-expects
  `tag()`; see "Luwu bugs" below.
- `Container needs Element`: holds children (`add`, `insert`, `clear`).
  `Content` is what `add` takes: strings, numbers, children, or arrays of them.
  Arrays may hold `none` for a left-out item.
- `Component needs Element, Child`: a user-facing element;
  `Component.register(cls)` makes it parseable.
- `Metadata needs Element`: things that go in `<head>`.
- `Layout needs Container` (`src/elements/layout.luwu`): `row`, `column`,
  `grid`, `gap`, `wrap`, `align`, `justify`. Each arrangement is a theme class
  (`chimera-row`, ...); only explicit overrides are inline style. All built-in
  containers implement it.

`Writer` collects output and carries page context to render methods: `themes`
(for `ThemeSwitcher`), `location` (the page's path), `pages` (the site tree),
`headings` (when something lists them), and `href_to(path)` for relative links.
Hot render paths live in the class's own module so methods inline.

### Styling and themes

- `StyleInput` (`src/style/properties.luwu`) is a typed table of about 150 CSS
  properties. Keyword properties take stringleton unions (`Display`,
  `FontWeight`, ...). Lengths and colors use validators (`CssLength`,
  `CssColor`, through `type function ValidLength`/`ValidColor`) unioned with
  numbers, `Color` and `Token`. Unknown keys still pass (custom properties as
  `["--x"]`); misspellings get a "did you mean" warning. `webkit_`/`moz_` keys
  render with a leading `-`. `Style.merge` reads the record through one cast to
  a map, since records can't be iterated.
- `token(name)` returns a `Token` (`var(--chimera-<name>)`);
  `token("radius"):times(1.5)` gives a `calc()`.
- `Theme` trait: `expect const name`, `expect const mode: ThemeMode` ("Light" |
  "Dark"), `palette()`,
  `base_styles()` (all built-in element/component CSS lives here, written with
  tokens). `Theme.register`/`find` make themes parseable by name.
- `Document` holds `default_light_theme`/`default_dark_theme` plus offered
  themes; with neither default set it uses `Light` and `Dark`. The generated
  stylesheet writes each theme's tokens under `:root[data-theme="<name>"]`, the
  defaults under `:root:not([data-theme])` with a `prefers-color-scheme: dark`
  media rule, then the first default's `base_styles`, then each present class's
  `default_styles` once.
- The runtime script (`RUNTIME_JS` in `document.luwu`): a picked theme sets
  `data-theme`, is saved to `localStorage`, and is carried on relative links as
  `?theme=` (file:// pages don't share storage). Before a pick the CSS follows
  the OS; the script only keeps the switcher's checkmark in sync. It also closes
  menus and runs `Toggle`s.

### Documents and sites

- `Document` renders a whole page. Its head gets, all marked `data-chimera`: the
  base stylesheet; an overrides stylesheet (`style_every`, `style_inside`); the
  runtime script; and the deduplicated `head_elements`. The parser drops the
  generated parts and reads the overrides back into `rules`. Headings below the
  title get ids from their text and a section link after their text
  (`heading_links`, on by default; the parser drops the link). With a table of
  contents on the page, the title gets an id too. Headings inside an element
  whose `contributes_headings()` is false (cards) get neither.
- `Site` builds one `Document` per `Page`. Shared parts can't drift. It holds
  the themes, header, footer and sidebar (defaults: a menu of top-level pages
  with a brand link and theme switcher, and a `SiteFooter` with the site's
  copyright; `none` removes either), plus `style_every`, `customize(fn)` and
  breadcrumbs for nested pages. `build(out_dir)` writes every page and errors on
  clashing paths.
- `Page(title, content?, file?)` owns a `Main`. Child pages live in their
  parent's folder (`docs/index.html` → `docs/*`). `PageLink`, `TableOfContents`
  and `Breadcrumbs` resolve links per page through `Writer.href_to`.
- The page `TableOfContents` is a collapsible box with "On this page" and
  "Subpages" columns. On wide screens it becomes a sticky rail beside `main`
  (`main:has(> .chimera-toc)` turns into a grid there). Grid children's margins
  don't collapse, and the rail rules adjust them.

### Code highlighting

`Code` (inline, and the class for every `<code>` tag) and `CodeBlock` both
implement the `SourceCode` trait: `source`, `language()`, `highlighted()`, and
parsing their text back. `CodeBlock:copyable()` adds a copy button that the page
script (`chimera.copy`) runs. They highlight Luwu, Luau and Lua at build time
with the highlighter in `src/components/code.luwu`, emitting highlight.js class names
that the theme colors through `syntax_*` tokens. It handles interpolated
strings, type annotations and built-ins. Other languages load highlight.js from
a CDN. Blocks record their longest line (`--chimera-code-columns`) so the theme
can shrink the font slightly to fit. `luwu-highlight` (the Luwu playground's
TextMate highlighter) was evaluated and rejected here: it needs a JavaScript
regex engine, and chimera must not shell out to Node.

`CodeBlock` dedents its source (`CodeBlock.dedent`): write code strings indented
one level past the surrounding code, on their own lines after `[====[`, never
flush left. Helpers that read code strings themselves call `CodeBlock.dedent`
first.

`SourceCode` also carries `Squiggle`s (wavy, a message; stored in
`data-squiggles`) and `Hover`s (dotted underline, any `Content`; each rendered
into a `<template data-hover="N">` inside the code). Both mark `SourceSpan`s,
two `vector`s of line and column. Implementors call `render_source(out)` where
the code goes. The runtime script clones a hover's template into the
`.chimera-hover` box. The Better Hovers page (`examples/luwu/hovers/`) shows
luwu-lsp's real hovers: `capture.luwu` asks the server and writes
`hovers.json`. Rerun it when luwu-lsp's hovers change.

### Luwu bugs

Report Luwu bugs with a minimal repro. Open: `Element` repeats `expect function
tag()` from `Tagged` (`CLASS_TRAIT_BUGS` 1).

### Conventions learned here

These add to the global style rules:

- Map types have optional values: `{ [string]: number? }`, not `{ [string]: number }`. Luau doesn't flag
  that indexing a map can give `nil` (Luwu's new strict mode will).
- A union spread over several lines puts `|` before every member, the first included:
  `type Event =` then `    | { kind: "join" }` and `    | { kind: "leave" }` on their own lines.
- One `type .{ A, B } = module` per module instead of several 
  `type A =  module.A` lines.
- Prefer table comprehensions to `table.insert` loops. A comprehension must be
  the only item in its table.
- Optional items in a table literal use `none`, not `nil`.
- Doc examples show output in a separate ```` ```html ```` / ```` ```css ````
  block, never as `-->` comments.
- Traits can have `private` helpers. Once one member has an access specifier,
  every member needs one.
- A class method overriding a trait's must work as the trait's version (extra
  parameters optional). Rename instead of overriding when the meanings differ
  (`SiteFooter:link_column` vs `Layout.column`).
- Use seal's datetime library (`@std/time/datetime`), not `os.date`.
- Describe Luwu as its own language, never as "Luau plus extras". The
  canonical description is the opening of `examples/luwu/index.luwu` ("a fast,
  object oriented, and highly expressive embeddable scripting language forked
  from Luau 0.730 ..."): reuse it instead of paraphrasing. Say strict type
  checking by default and gradual typing as separate facts, never "strictly
  and gradually typed" in one phrase.

### Docs wording

These cover the guide (`examples/guide/`), the home page (`examples/site.luwu`)
and the Luwu docs (`examples/luwu/`, also copied to luwu.org).

- When deviaze hands over sentences, use them. Fix typos and grammar only;
  don't rewrite them into vaguer prose. Rephrase only what they ask for.
- Open a page with what the feature is and why it exists, through a concrete
  scenario. Never "This page is for ..." or "This page covers ...".
- Vary sentence length. A run of short, same-shaped sentences reads as
  unreviewed machine prose. Join related facts with "and", "because" or
  "when". Keep the tone friendly and direct.
- No quips: no punchy one-liners that add nothing ("A class can.", "You
  write the rules.", "for free", "never goes stale", "minus the confusing
  parts"). A short sentence that states a fact is fine.
- No comma add-on clauses. Follow "Writing prose, docs and code comments" in
  the global `~/.claude/CLAUDE.md`: remove the comma, restructure the
  sentence, or drop the clause. Never split it into its own sentence.
- Use the real terms and introduce them gently. A class represents a domain
  concept; it groups data (fields) with behavior (methods), and encapsulates
  the data to protect its invariants. Don't say a class "describes a kind of
  object".
- Upstream Luau: state differences, not disagreements ("Since the fork, Luau
  and Luwu have diverged. The main differences today are ..."). Comparisons
  stay factual: say what each tool prints or does, never "Luau gives up",
  "narrates" or "has nothing like it". Where Luwu is objectively better, show
  it side by side; don't hide it.
- Luwu type errors limit jargon. When a term is needed, Luwu attaches a
  "Help" explanation; say so rather than implying the term never appears.
- Feature names follow what the feature covers: "Default Arguments" (functions
  and class constructors), not "Function Default Arguments".
- Name seal precisely: "seal, a Luau and Luwu runtime"; fully qualify std
  imports in examples (`@std/io/colors`).
- Examples must be true:
  - Run every example whose output is shown. Guide examples render from their
    own source (`--@ name` snippets via `examples/guide/example.luwu`); Luwu
    samples in `examples/luwu/samples/` run at build time
    (`examples/luwu/terminal.luwu`).
  - Show real tool output (luwu-analyze, luwu-lsp hovers) instead of writing
    it by hand. Verify every claim about behavior before publishing it.
  - Examples that teach a principle must actually follow it (a class that
    "protects its invariant" keeps its fields and constructor private).
- Example code style: no blank lines between methods; blank lines only
  separate groups (fields from functions, private from public fields).
  Shorten long examples on overview pages with a `-- ...` comment and link the
  full version on the feature's page.
- Check docs changes visually with headless Firefox (see Commands). Append
  `?theme=<name>` to the page URL to render a theme other than the light
  default, like `?theme=catppuccin-mocha`. Headless can't hover, so to check a
  hover-only style, inject a style that forces it on a copy of the page in
  your scratch directory. Crop screenshots by cropping the image, never by
  hiding page elements (that hides the contents box too).
