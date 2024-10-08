-- By convention, nvim Lua plugins include a setup function that takes a table
-- so that users of the plugin can configure it using this pattern:
--
-- require'myluamodule'.setup({p1 = "value1"})

function augroup (group_name, autocmds)
    -- autocmds = list of {
    --     events = {},
    --     opts = {
    --         pattern = {"*"},
    --         desc = "",
    --         command = "",
    --     },
    -- }
    local group = vim.api.nvim_create_augroup(group_name, {
        clear = true,
    })
    for _, autocmd in pairs(autocmds) do
        local opts = autocmd["opts"]
        opts["group"] = group
        vim.api.nvim_create_autocmd(autocmd["events"], opts)
    end
end

-- The function is called `t` for `termcodes`.
-- You don't have to call it that, but I find the terseness convenient
local function t(str)
    -- Adjust boolean arguments as needed
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local last_color
local cursorDefaultHi = vim.api.nvim_command_output("hi Cursor")

local function updapte_cursor_color()
    local hi_group = {}
    local posInfo = vim.inspect_pos()
    if #posInfo.semantic_tokens > 0 then
        -- mid priority
        hi_group = posInfo.semantic_tokens[1].opts or hi_group
    elseif #posInfo.treesitter > 0 then
        -- higher priority
        hi_group = posInfo.treesitter[#posInfo.treesitter] or hi_group
    elseif #posInfo.syntax > 0 then
        -- lower priority
        hi_group = posInfo.syntax[#posInfo.syntax] or hi_group
    end

    if hi_group.hl_group_link == nil then
        -- restore default color
        vim.api.nvim_set_hl(0, "Cursor", {
            fg = cursorDefaultHi.guifg,
            bg = cursorDefaultHi.guibg,
        })
        return true
    end

    local cursorHi = vim.api.nvim_command_output("hi Cursor")
    local hi = vim.api.nvim_command_output("hi " .. hi_group.hl_group_link)

    if hi == last_color then
        -- don't update color if same color found
        return false
    end

    last_color = hi

    local colors = {}
    if cursorHi.guifg == nil then colors.guifg = "NONE" else colors.guifg = cursorHi.guifg end
    if cursorHi.guibg == nil then colors.guibg = "NONE" else colors.guibg = cursorHi.guibg end
    for k, v in string.gmatch(hi, "(%w+)=([#%w]+)") do
        colors[k] = v
    end

    vim.api.nvim_set_hl(0, "Cursor", { fg=colors.guibg, bg=colors.guifg, })

    return true
end

local function valid_buffer()
    if vim.bo.readonly then
        -- cursor color does not change in readonly buffer
        -- disable tempararily
        return false
    end
    if vim.bo.buftype == "nofile" then
        -- fix compatibility with plenary popup window
        return false
    end
    if vim.bo.buftype == "prompt" then
        -- fix compatibility with prompt window, ie. Telescope
        return false
    end
    local cfg = vim.api.nvim_win_get_config(0)
    if cfg.relative ~= "" or cfg.external then
        -- fix compatibility with floating window
        return false
    end
    if vim.fn.mode() ~= "n" then
        -- can only change mode in normal mode
        return false
    end
    if vim.b[0].VM_Selection and next(vim.b[0].VM_Selection) then
        -- workaround for mg979/vim-visual-multi
        return false
    end
    return true
end

local function setup(parameters)
    -- HACK: to update cursor color immediately
    -- just go to command mode than back to normal mode.
    -- but since we do not want cursor jumping around window
    -- between current position and command line, so set a silent keymap.
    -- I just map : to : to minimize the impact to user keymaps
    vim.keymap.set('n', ':', ':', {
        silent = true,
        desc="<syntax-highlighted-cursor.nvim> Silent out : for updating color workaround."
    })

    local options = {
        debounce_ms = 50,
    }

    if parameters ~= nil then
        for k, v in pairs(parameters) do
            options[k] = v
        end
    end

    local debounce_ts = 0
    local moved = false

    augroup("SyntaxColorCursor", {
        {
            events = {"CursorMoved"},
            opts = {
                pattern = {"*"},
                desc = "SyntaxColorCursor",
                callback = function()
                    if valid_buffer() == false then
                        return
                    end
                    moved = true
                    if vim.uv.now() - debounce_ts < options["debounce_ms"] then
                        -- debounce within 10 ms movement
                        debounce_ts = vim.uv.now()
                        return
                    end
                    debounce_ts = vim.uv.now()

                    if updapte_cursor_color() then
                        vim.api.nvim_feedkeys(t':', 'm', false)
                        vim.api.nvim_feedkeys(t'<ESC>','n', false)
                    end
                end,
            },
        },
        {
            events = {"CursorHold"},
            opts = {
                pattern = {"*"},
                desc = "SyntaxColorCursor",
                callback = function()
                    if moved == false then
                        return
                    end
                    moved = false

                    if updapte_cursor_color() then
                        vim.api.nvim_feedkeys(t':', 'm', false)
                        vim.api.nvim_feedkeys(t'<ESC>','n', false)
                    end
                end,
            },
        },
    })
end

-- Returning a Lua table at the end allows fine control of the symbols that
-- will be available outside this file. Returning the table also allows the
-- importer to decide what name to use for this module in their own code.

return {
    setup = setup,
}
