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

local last_color

local function updapte_cursor_color()
    local hi_group = {}
    local posInfo = vim.inspect_pos()
    if #posInfo.syntax > 0 then
        -- lower priority
        hi_group = posInfo.syntax[#posInfo.syntax]
    end
    if #posInfo.treesitter > 0 then
        -- higher priority
        hi_group = posInfo.treesitter[#posInfo.treesitter]
    end

    if hi_group.hl_group_link == nil then
        return false
    end

    local cursorHi = vim.api.nvim_command_output("hi Cursor")
    local hi = vim.api.nvim_command_output("hi " .. hi_group.hl_group_link)

    if hi == last_color then
        -- don't update color if same color found
        return false
    end

    t = {
        guifg = cursorHi.guifg,
        guibg = cursorHi.guibg,
    }
    if cursorHi.guifg == nil then t.guibg = "NONE" else t.guibg = cursorHi.guifg end
    if cursorHi.guibg == nil then t.guifg = "NONE" else t.guifg = cursorHi.guibg end
    for k, v in string.gmatch(hi, "(%w+)=([#%w]+)") do
        t[k] = v
    end

    vim.api.nvim_set_hl(0, "Cursor", { fg=t.guibg, bg=t.guifg, })
    vim.api.nvim_set_hl(0, "CursorIM", { fg=t.guibg, bg=t.guifg, })

    return true
end

local function setup(parameters)

    augroup("SyntaxColorCursor", {
        {
            events = {"CursorMoved"},
            opts = {
                pattern = {"*"},
                desc = "SyntaxColorCursor",
                callback = function()
                    print(123)
                    if updapte_cursor_color() then
                        local esc_keys = vim.api.nvim_replace_termcodes('<ESC>',true,false,true)
                        -- HACK: to update cursor color immediately
                        -- just go to insert mode than back to normal mode
                        vim.api.nvim_feedkeys('a', 'm', false)
                        vim.api.nvim_feedkeys(esc_keys,'m', false)
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
