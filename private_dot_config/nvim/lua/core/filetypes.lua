vim.filetype.add {
  pattern = {
    ['.*/templates/.*%.yaml'] = 'helm',
    ['.*/templates/.*%.tpl'] = 'helm',
    ['helmfile.*%.yaml'] = 'helm',
    ['docker%-compose.*%.yaml'] = 'yaml.docker-compose',
    ['docker%-compose.*%.yml'] = 'yaml.docker-compose',
    ['compose.*%.yaml'] = 'yaml.docker-compose',
    ['compose.*%.yml'] = 'yaml.docker-compose',
  },
  filename = {
    ['Chart.yaml'] = 'helm',
  },
}

-- vim: ts=2 sts=2 sw=2 et
