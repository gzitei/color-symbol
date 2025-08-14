# CSS Color Symbols Plugin

A custom Neovim plugin that displays color symbols as virtual text next to color values in CSS files.

## Features

- Detects various color formats:
  - Hexadecimal colors (`#ff0000`, `#fff`, `#ff000080`)
  - RGB/RGBA functions (`rgb(255, 0, 0)`, `rgba(255, 0, 0, 0.5)`)
  - HSL/HSLA functions (`hsl(120, 100%, 50%)`, `hsla(240, 100%, 50%, 0.8)`)
  - Named colors (`red`, `orange`, `blue`, etc.)

- Displays a configurable colored symbol as virtual text to the left of each color value
- The symbol is colored using the actual color value
- Supports CSS, SCSS, Sass, Less, and Stylus files
- Fully configurable symbol and file types

## Installation

The plugin is already configured in your Neovim setup. It will automatically activate when you open CSS-related files.

## Configuration

You can customize the plugin by modifying the setup call in `lua/plugins/css-color-symbols.lua`:

```lua
require('css-color-symbols').setup({
    -- Customize the symbol (default: '󱓻 ')
    symbol = '● ',        -- Use a simple dot
    -- symbol = '◆ ',     -- Use a diamond
    -- symbol = '▌',      -- Use a block
    -- symbol = '🎨 ',    -- Use an emoji (if your terminal supports it)
    
    -- Customize supported file types (default: { 'css', 'scss', 'sass', 'less', 'stylus' })
    filetypes = { 'css', 'scss', 'sass' },
    
    -- Enable/disable auto-triggering (default: true)
    auto_trigger = true,
})
```

### Configuration Options

- **`symbol`** (string): The symbol to display next to colors. Default: `'󱓻 '`
- **`filetypes`** (table): List of file types to activate on. Default: `{ 'css', 'scss', 'sass', 'less', 'stylus' }`
- **`auto_trigger`** (boolean): Whether to automatically highlight colors on file events. Default: `true`

## Usage

The plugin works automatically when you open or edit CSS files. You can also manually trigger highlighting with:

```
:CssColorSymbols
```

## Supported File Types

- `.css`
- `.scss`
- `.sass`
- `.less`
- `.stylus`

## Example

```css
.example {
    color: #ff0000;          /* Shows: [symbol] #ff0000 (red symbol) */
    background: orange;      /* Shows: [symbol] orange (orange symbol) */
    border: 1px solid rgb(0, 255, 0);  /* Shows: [symbol] rgb(0, 255, 0) (green symbol) */
}
```

The symbols will appear in the actual colors they represent using your configured symbol.