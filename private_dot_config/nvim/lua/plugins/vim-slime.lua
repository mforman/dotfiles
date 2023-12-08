return {
	'jpalardy/vim-slime',
	config = function()
		vim.cmd([[
		let g:slime_target = "tmux"
			]])
	end
}
