-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {} -- this is equalent to setup({}) function
	},
	{
		'tpope/vim-surround'
	},
	{
		"dpayne/CodeGPT.nvim",
		dependencies = {
			'nvim-lua/plenary.nvim',
			'MunifTanjim/nui.nvim',
		},
		config = function()
			require("codegpt.config")
		end
	}
}
