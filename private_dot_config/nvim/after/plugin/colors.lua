require("catppuccin").setup({
    custom_highlights = function(colors)
        return {
            LineNr = { fg = colors.overlay1 }
        }
    end
})

function ColorMyPencils(color)
    color = color or 'catppuccin'
    vim.cmd.colorscheme(color)
end

ColorMyPencils()
