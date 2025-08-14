local M = {}

-- Default configuration
local default_config = {
    symbol = '󱓻 ', -- Default symbol with space
    filetypes = { 'css', 'scss', 'sass', 'less', 'stylus' }, -- Supported file types
    auto_trigger = true, -- Auto-trigger on file events
}

-- Current configuration (will be set during setup)
local config = {}

-- Common CSS color names mapping
local color_names = {
    aliceblue = '#F0F8FF',
    antiquewhite = '#FAEBD7',
    aqua = '#00FFFF',
    aquamarine = '#7FFFD4',
    azure = '#F0FFFF',
    beige = '#F5F5DC',
    bisque = '#FFE4C4',
    black = '#000000',
    blanchedalmond = '#FFEBCD',
    blue = '#0000FF',
    blueviolet = '#8A2BE2',
    brown = '#A52A2A',
    burlywood = '#DEB887',
    cadetblue = '#5F9EA0',
    chartreuse = '#7FFF00',
    chocolate = '#D2691E',
    coral = '#FF7F50',
    cornflowerblue = '#6495ED',
    cornsilk = '#FFF8DC',
    crimson = '#DC143C',
    cyan = '#00FFFF',
    darkblue = '#00008B',
    darkcyan = '#008B8B',
    darkgoldenrod = '#B8860B',
    darkgray = '#A9A9A9',
    darkgreen = '#006400',
    darkkhaki = '#BDB76B',
    darkmagenta = '#8B008B',
    darkolivegreen = '#556B2F',
    darkorange = '#FF8C00',
    darkorchid = '#9932CC',
    darkred = '#8B0000',
    darksalmon = '#E9967A',
    darkseagreen = '#8FBC8F',
    darkslateblue = '#483D8B',
    darkslategray = '#2F4F4F',
    darkturquoise = '#00CED1',
    darkviolet = '#9400D3',
    deeppink = '#FF1493',
    deepskyblue = '#00BFFF',
    dimgray = '#696969',
    dodgerblue = '#1E90FF',
    firebrick = '#B22222',
    floralwhite = '#FFFAF0',
    forestgreen = '#228B22',
    fuchsia = '#FF00FF',
    gainsboro = '#DCDCDC',
    ghostwhite = '#F8F8FF',
    gold = '#FFD700',
    goldenrod = '#DAA520',
    gray = '#808080',
    green = '#008000',
    greenyellow = '#ADFF2F',
    honeydew = '#F0FFF0',
    hotpink = '#FF69B4',
    indianred = '#CD5C5C',
    indigo = '#4B0082',
    ivory = '#FFFFF0',
    khaki = '#F0E68C',
    lavender = '#E6E6FA',
    lavenderblush = '#FFF0F5',
    lawngreen = '#7CFC00',
    lemonchiffon = '#FFFACD',
    lightblue = '#ADD8E6',
    lightcoral = '#F08080',
    lightcyan = '#E0FFFF',
    lightgoldenrodyellow = '#FAFAD2',
    lightgray = '#D3D3D3',
    lightgreen = '#90EE90',
    lightpink = '#FFB6C1',
    lightsalmon = '#FFA07A',
    lightseagreen = '#20B2AA',
    lightskyblue = '#87CEFA',
    lightslategray = '#778899',
    lightsteelblue = '#B0C4DE',
    lightyellow = '#FFFFE0',
    lime = '#00FF00',
    limegreen = '#32CD32',
    linen = '#FAF0E6',
    magenta = '#FF00FF',
    maroon = '#800000',
    mediumaquamarine = '#66CDAA',
    mediumblue = '#0000CD',
    mediumorchid = '#BA55D3',
    mediumpurple = '#9370DB',
    mediumseagreen = '#3CB371',
    mediumslateblue = '#7B68EE',
    mediumspringgreen = '#00FA9A',
    mediumturquoise = '#48D1CC',
    mediumvioletred = '#C71585',
    midnightblue = '#191970',
    mintcream = '#F5FFFA',
    mistyrose = '#FFE4E1',
    moccasin = '#FFE4B5',
    navajowhite = '#FFDEAD',
    navy = '#000080',
    oldlace = '#FDF5E6',
    olive = '#808000',
    olivedrab = '#6B8E23',
    orange = '#FFA500',
    orangered = '#FF4500',
    orchid = '#DA70D6',
    palegoldenrod = '#EEE8AA',
    palegreen = '#98FB98',
    paleturquoise = '#AFEEEE',
    palevioletred = '#DB7093',
    papayawhip = '#FFEFD5',
    peachpuff = '#FFDAB9',
    peru = '#CD853F',
    pink = '#FFC0CB',
    plum = '#DDA0DD',
    powderblue = '#B0E0E6',
    purple = '#800080',
    red = '#FF0000',
    rosybrown = '#BC8F8F',
    royalblue = '#4169E1',
    saddlebrown = '#8B4513',
    salmon = '#FA8072',
    sandybrown = '#F4A460',
    seagreen = '#2E8B57',
    seashell = '#FFF5EE',
    sienna = '#A0522D',
    silver = '#C0C0C0',
    skyblue = '#87CEEB',
    slateblue = '#6A5ACD',
    slategray = '#708090',
    snow = '#FFFAFA',
    springgreen = '#00FF7F',
    steelblue = '#4682B4',
    tan = '#D2B48C',
    teal = '#008080',
    thistle = '#D8BFD8',
    tomato = '#FF6347',
    turquoise = '#40E0D0',
    violet = '#EE82EE',
    wheat = '#F5DEB3',
    white = '#FFFFFF',
    whitesmoke = '#F5F5F5',
    yellow = '#FFFF00',
    yellowgreen = '#9ACD32'
}

local function generate_named_color_pattern()
    local color_keys = {}
    for color_name, _ in pairs(color_names) do
        table.insert(color_keys, color_name)
    end
    -- Sort by length (longer names first) to avoid partial matches
    table.sort(color_keys, function(a, b) return #a > #b end)
    return '%f[%w](' .. table.concat(color_keys, '|') .. ')%f[%W]'
end

-- Check if a word is a named color (more robust approach)
local function is_named_color(word)
    return color_names[word:lower()] ~= nil
end

-- Namespace for virtual text
local ns_id = vim.api.nvim_create_namespace('css_color_symbols')

-- Color patterns (ordered by specificity - most specific first)
local patterns = {
    -- RGB/RGBA functions (most specific first)
    { pattern = 'rgba%s*%([^%)]+%)',                                                                               type = 'rgb' },
    { pattern = 'rgb%s*%([^%)]+%)',                                                                                type = 'rgb' },
    -- HSL/HSLA functions
    { pattern = 'hsla%s*%([^%)]+%)',                                                                               type = 'hsl' },
    { pattern = 'hsl%s*%([^%)]+%)',                                                                                type = 'hsl' },
    -- Hexadecimal colors (8-digit, 6-digit, 4-digit, 3-digit)
    { pattern = '#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%f[%W]', type = 'hex' },
    { pattern = '#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%f[%W]',                       type = 'hex' },
    { pattern = '#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%f[%W]',                                             type = 'hex' },
    { pattern = '#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%f[%W]',                                                        type = 'hex' },
    -- Named colors - will be populated during setup
    { pattern = '',                                                                                                type = 'named' },
}

-- Convert color to hex format
local function color_to_hex(color_str, color_type)
    if color_type == 'hex' then
        -- Normalize hex colors
        local hex = color_str:gsub('#', ''):upper()
        if #hex == 3 then
            -- Convert #RGB to #RRGGBB
            hex = hex:gsub('(.)', '%1%1')
        elseif #hex == 4 then
            -- Convert #RGBA to #RRGGBBAA, but only return RGB part
            hex = hex:gsub('(.)', '%1%1')
            hex = hex:sub(1, 6)
        elseif #hex == 8 then
            -- Take only RGB part from #RRGGBBAA
            hex = hex:sub(1, 6)
        end
        if #hex == 6 then
            local result = '#' .. hex
            return result
        end
    elseif color_type == 'named' then
        return color_names[color_str:lower()]
    elseif color_type == 'rgb' then
        -- Extract RGB values from rgb(r,g,b) or rgba(r,g,b,a)
        -- First try integer values
        local r, g, b = color_str:match('rgba?%s*%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)')
        if r and g and b then
            return string.format('#%02X%02X%02X',
                math.min(255, tonumber(r)),
                math.min(255, tonumber(g)),
                math.min(255, tonumber(b)))
        end
        -- Try percentage values
        r, g, b = color_str:match('rgba?%s*%((%d+)%%%s*,%s*(%d+)%%%s*,%s*(%d+)%%')
        if r and g and b then
            return string.format('#%02X%02X%02X',
                math.floor(math.min(100, tonumber(r)) * 255 / 100),
                math.floor(math.min(100, tonumber(g)) * 255 / 100),
                math.floor(math.min(100, tonumber(b)) * 255 / 100))
        end
    elseif color_type == 'hsl' then
        -- Basic HSL to RGB conversion
        local h, s, l = color_str:match('hsla?%s*%((%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%')
        if h and s and l then
            h, s, l = tonumber(h) / 360, tonumber(s) / 100, tonumber(l) / 100

            local function hue_to_rgb(p, q, t)
                if t < 0 then t = t + 1 end
                if t > 1 then t = t - 1 end
                if t < 1 / 6 then return p + (q - p) * 6 * t end
                if t < 1 / 2 then return q end
                if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
                return p
            end

            local r, g, b
            if s == 0 then
                r, g, b = l, l, l
            else
                local q = l < 0.5 and l * (1 + s) or l + s - l * s
                local p = 2 * l - q
                r = hue_to_rgb(p, q, h + 1 / 3)
                g = hue_to_rgb(p, q, h)
                b = hue_to_rgb(p, q, h - 1 / 3)
            end

            return string.format('#%02X%02X%02X',
                math.floor(r * 255),
                math.floor(g * 255),
                math.floor(b * 255))
        end
    end
    return nil
end

-- Convert hex color to decimal
local function hex_to_decimal(hex_color)
    -- Remove # if present and ensure uppercase
    local hex = hex_color:gsub('#', ''):upper()
    -- Convert hex to decimal
    return tonumber(hex, 16)
end

-- Create highlight group for a specific color
local function create_color_highlight(hex_color)
    local hl_name = 'CssColorSymbol_' .. hex_color:gsub('#', ''):upper()
    local decimal_color = hex_to_decimal(hex_color)

    -- Create highlight with decimal color value
    vim.api.nvim_set_hl(0, hl_name, {
        fg = decimal_color,
    })
    return hl_name
end

-- Find and highlight colors in buffer
local function highlight_colors()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Clear existing virtual text
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    for line_num, line in ipairs(lines) do
        -- Track processed positions to avoid overlaps
        local processed_positions = {}

        -- First, process function-based and hex colors
        for _, pattern_info in ipairs(patterns) do
            if pattern_info.type ~= 'named' then -- Skip named colors for now
                local start_pos = 1
                while start_pos <= #line do
                    local match_start, match_end, capture = line:find(pattern_info.pattern, start_pos)
                    if not match_start then break end

                    -- Check if this position has already been processed
                    local already_processed = false
                    for _, pos_range in ipairs(processed_positions) do
                        if match_start >= pos_range.start and match_start <= pos_range.finish then
                            already_processed = true
                            break
                        end
                    end

                    if not already_processed then
                        local color_str = capture or line:sub(match_start, match_end)
                        local hex_color = color_to_hex(color_str, pattern_info.type)

                        if hex_color then
                            local hl_group = create_color_highlight(hex_color)
                            vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num - 1, match_start - 1, {
                                virt_text = { { config.symbol, hl_group } },
                                virt_text_pos = 'inline',
                            })
                            -- Mark this position as processed
                            table.insert(processed_positions, { start = match_start, finish = match_end })
                        end
                    end

                    start_pos = match_end + 1
                end
            end
        end

        -- Now process named colors with word boundary approach
        local word_start = 1
        while word_start <= #line do
            local word_match_start, word_match_end = line:find('%w+', word_start)
            if not word_match_start then break end

            -- Check if this position has already been processed
            local already_processed = false
            for _, pos_range in ipairs(processed_positions) do
                if word_match_start >= pos_range.start and word_match_start <= pos_range.finish then
                    already_processed = true
                    break
                end
            end

            if not already_processed then
                local word = line:sub(word_match_start, word_match_end)
                if is_named_color(word) then
                    local hex_color = color_to_hex(word, 'named')
                    if hex_color then
                        local hl_group = create_color_highlight(hex_color)
                        vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num - 1, word_match_start - 1, {
                            virt_text = { { config.symbol, hl_group } },
                            virt_text_pos = 'inline',
                        })
                        -- Mark this position as processed
                        table.insert(processed_positions, { start = word_match_start, finish = word_match_end })
                    end
                end
            end

            word_start = word_match_end + 1
        end
    end
end

-- Setup function
function M.setup(opts)
    opts = opts or {}

    -- Merge user config with defaults
    config = vim.tbl_deep_extend('force', default_config, opts)

    -- Create autocommands for CSS-related files
    local group = vim.api.nvim_create_augroup('CssColorSymbols', { clear = true })

    -- Use configured filetypes and check if auto_trigger is enabled
    if config.auto_trigger then
        local patterns = {}
        for _, ft in ipairs(config.filetypes) do
            table.insert(patterns, '*.' .. ft)
        end

        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'TextChanged', 'TextChangedI' }, {
            group = group,
            pattern = patterns,
            callback = function()
                -- Small delay to ensure buffer is ready
                vim.defer_fn(highlight_colors, 100)
            end,
        })

        -- Also trigger on filetype change
        vim.api.nvim_create_autocmd('FileType', {
            group = group,
            pattern = config.filetypes,
            callback = function()
                vim.defer_fn(highlight_colors, 100)
            end,
        })
    end

    -- Create user command for manual trigger
    vim.api.nvim_create_user_command('CssColorSymbols', highlight_colors, {
        desc = 'Manually trigger CSS color symbol highlighting'
    })

    -- Create debug command
    vim.api.nvim_create_user_command('CssColorDebug', function(args)
        local test_color = args.args or '#ddd'
        local hex_result = color_to_hex(test_color, 'hex')
        print('Input:', test_color)
        print('Output:', hex_result)
        if hex_result then
            local hl_name = create_color_highlight(hex_result)
            print('Highlight group:', hl_name)

            -- Check what the highlight group actually contains
            local hl_def = vim.api.nvim_get_hl(0, { name = hl_name })
            print('Highlight definition:', vim.inspect(hl_def))
        end
    end, {
        desc = 'Debug CSS color parsing',
        nargs = '?'
    })

    -- Create command to list all CSS color highlight groups
    vim.api.nvim_create_user_command('CssColorList', function()
        local hls = vim.api.nvim_get_hl(0, {})
        print('CSS Color Symbol highlight groups:')
        for name, def in pairs(hls) do
            if name:match('^CssColorSymbol_') then
                print(name, ':', vim.inspect(def))
            end
        end
    end, {
        desc = 'List all CSS color symbol highlight groups'
    })
end

-- Expose highlight_colors function
M.highlight_colors = highlight_colors

return M
