vim.wo.foldmethod="syntax"

for _, match in ipairs(vim.fn.getmatches()) do
  if match['group'] == 'DiffText' then
    vim.fn.matchdelete(match['id'])
    break
  end
end

vim.fn.matchadd('DiffText', '\\%89v')
