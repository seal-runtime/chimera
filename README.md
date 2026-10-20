# chimera

expressive html static site builder written in luwu for seal (0.9.x)/luwu versions.
See seal branch luwu-classes.

this repo is 99% written by Claude. But it is a pretty good example of using
OOP Luwu with classes and traits.

## Usage

Point a `.luaurc` alias at this directory and require it. Run your build script with a Luwu-enabled seal
(`seal ./site.luwu`).

```luwu
const fs = require("@std/fs")
const chimera = require("@path/to/chimera")
const .{
    Component,
    Container,
    Layout,
    Document,
    Parser,
    elements.{ Heading, Paragraph, Link, Main },
    components.{ Card, CodeBlock, Grid },
    style.{ Rule, Palette, Color, Theme, token },
    themes.{ catppuccin },
    site.{ Site, Page, TableOfContents },
} = chimera
type .{ Content } = chimera
const .{ h1, h2 } = Heading
```

The modules:

| Module | What's in it |
| --- | --- |
| `elements` | one class per HTML tag: `Div`, `Paragraph`, `Heading`, `Link`, `Table`, `Form`, ... |
| `components` | `Card`, `Menu`, `Toggle`, `ThemeSwitcher`, `SiteFooter`, `Row`/`Column`/`Grid`, `CodeBlock`, ... |
| `style` | `Style`, `Rule`, `Color`, `token`, the `Theme` trait and `Palette` |
| `themes` | `Light`, `Dark` and the `catppuccin` flavors |
| `site` | `Site`, `Page`, `PageLink`, `TableOfContents`, `Breadcrumbs` |

### A site

Pages hold content and other pages; nested pages go in their parent's folder. The site renders every page with
the same header, footer and themes, and links between them from any folder.

```luwu
const home = Page("Home", {
    h1("Hello"),
    Paragraph("A site built from Luwu classes."),
    Grid({
        Card("Typed", Paragraph("Wrong CSS values are type errors.")),
        Card("Themed", Paragraph("Readers pick a theme; it follows them across pages.")),
    }, "14rem"),
}, "index.html")

const guide = Page("Guide", {
    h1("Guide"),
    TableOfContents(), -- the headings below, and the pages under this one
    h2("Install"),
    CodeBlock("seal ./site.luwu", "bash"),
    h2("Write pages"),
    Paragraph({ "Every page is made of ", Link("Luwu classes", "https://github.com/luwu-community/luwu"), "." }),
})
guide:add_page(Page("Themes", { h1("Themes"), Paragraph("Pick a default for light and dark mode.") }))

Site("My site")
    :default_dark_theme(catppuccin.Mocha)
    :default_light_theme(catppuccin.Latte)
    :describe("Notes, guides and examples")
    :add_page(home, guide)
    :build("out") -- out/index.html, out/guide.html, out/guide/themes.html
```

Without `:header(...)` and `:footer(...)`, every page gets a menu of the top-level pages with a theme switcher, and a
footer with the site's copyright. Readers first see the default theme for their OS's light or dark mode.

### A single page

```luwu
const page = Document("Hello")
    :default_dark_theme(catppuccin.Mocha)
    :add(Main { h1("Hello"), Paragraph("One page, no site.") })
fs.writefile("hello.html", page:to_html(true))
```

### Styling

Style tables are typed: `padding = "1rx"` or `display = "flexx"` is a type error. `token(...)` reads the current
theme. Styles using it follow theme switches.

```luwu
Paragraph("Heads up!")
    :style({
        padding = "0.75rem 1rem",
        border_left = `3px solid {token("accent")}`,
        background = token("surface"),
    })

page
    :style_every(Card, { border_radius = "16px" })
    :style_every(".tagline", {
        color = token("muted"),
        font_size = "1.2rem",
    })
```

Containers arrange their children with `:row()`, `:column()` or `:grid(min_width)`, or start arranged as `Row`,
`Column` and `Grid`.

### Your own components

Implement `Component` (plus `Container` to hold children, or `Layout` to also arrange them) and register the class.
Registered components parse back from HTML as themselves.

```luwu
class Callout implements Component, Container
    function tag(): string
        return "aside"
    end

    function __init(self, title: string?, content: Content?)
        self:add_style_class("callout")
        self:add(Paragraph(title):add_style_class("callout-title"), content)
    end

    function default_styles(self): { Rule }
        return {
            Rule(self:style_selector(), {
                padding = "1rem 1.25rem",
                border = `1px solid {token("border")}`,
                border_radius = token("radius"),
            }),
            Rule(`{self:style_selector()} .callout-title`, { font_weight = "700" }),
        }
    end
end

Component.register(Callout)
```

`default_styles` is added once to every page that uses the component.

### Your own theme

```luwu
class Sepia() implements Theme
    const name = "sepia"
    const mode = "Light"

    function palette(self): Palette
        return Palette {
            background = Color.hex("#f4ecd8"),
            text = Color.hex("#5b4636"),
            primary = Color.hex("#8b5e3c"),
        }
    end
end

Theme.register(Sepia)
site:default_light_theme(Sepia)
```

### Parsing HTML back

```luwu
const nodes = Parser():parse(`<aside data-element="Callout" class="callout">...</aside>`)
const document = Parser():parse_document(fs.readfile("out/index.html"))
```

See `examples/site.luwu` for a full site.
