local global_snippets = {}

local snippets_by_filetype = {
  go = {
    -- functions
    {
      trigger = "append",
      body = [[ append(${1:someslice}, ${0:value}) ]],
    },
    {
      trigger = "make",
      body = [[ make(${1:[]string}, ${0:0}) ]],
    },
    {
      trigger = "fmtPrintf",
      body = [[ fmt.Printf("${1}\n", ${2:var}) ]],
    },
    {
      trigger = "logPrintf",
      body = [[ log.Printf("${1}", ${2:var}) ]],
    },
    {
      trigger = "fmtPrintln",
      body = [[ fmt.Println("${1}") ]],
    },
    {
      trigger = "logPrintln",
      body = [[ log.Println("${1}") ]],
    },
    -- types
    {
      trigger = "map",
      body = [[ map[${1:string}]${0:int} ]],
    },
    -- defers
    {
      trigger = "defer",
      body = [[ defer ${0:func}() ]],
    },
    {
      trigger = "deferf",
      body = [[ defer func(){
    ${0}
	}()]],
    },
    {
      trigger = "deferr",
      body = [[
	defer func() {
		if err := recover(); err != nil {
			${0}
		}
	}()]],
    },
    -- if
    {
      trigger = "iferr",
      body = [[
	if err != nil {
		return err
	}
	${0}]],
    },
    {
      trigger = "iferrw",
      body = [[
	if err != nil {
		return fmt.Errorf("${1} %w", err)
	}
	${0}]],
    },
    {
      trigger = "if",
      body = [[
	if ${1:value}, ok := ${2:map}[${3:key}]; ok == true {
		${4:/* code */}
	}]],
    },
    -- for
    {
      trigger = "for",
      body = [[
	for ${1:e} := range ${2:collection} {
		${0}
	}]],
    },
    {
      trigger = "fori",
      body = [[
	for ${2:i} := 0; $2 < ${1:count}; $2${3:++} {
		${0}
	}]],
    },
    -- other control flow
    {
      trigger = "select",
      body = [[
	select {
	case ${1:v1} := <-${2:chan1}
		${3}
	default:
		${0}
	}]],
    },
    {
      trigger = "switch",
      body = [[
	switch ${1:var} {
	case ${2:value1}:
		${3}
	default:
		${0}
	}]],
    },
    -- declarations
    {
      trigger = "func",
      body = [[
	func ${1:funcName}(${2}) ${3:error} {
		${0}
	}]],
    },
    {
      trigger = "closure",
      body = [[
	func(${1}) {
		${2}
	}(${3})]],
    },
    {
      trigger = "method",
      body = [[
	func (${1:receiver} ${2:type}) ${3:funcName}(${4}) ${5:error} {
		${0}
	}]],
    },
    {
      trigger = "struct",
      body = [[
	type ${1:structName} struct {
		${0}
	}]],
    },
    {
      trigger = "interface",
      body = [[
	type ${1:interfaceName} interface {
		${0}
	}]],
    },
    {
      trigger = "const",
      body = [[
	const (
		${1:FOO} = iota
		${0:BAR}
	)]],
    },
    -- templates
    {
      trigger = "funcdebug",
      body = [[
	func TestDebug(t *testing.T) {
		${0}
	}]],
    },
    {
      trigger = "functest",
      body = [[
	func Test${1:Name}(t *testing.T) {
		${0}
	}]],
    },
    {
      trigger = "functestt",
      body = [[
	func Test${1:Name}(t *testing.T) {
		tests := []struct {
			name string
		}{
			{
				name: "${2:test name}",
			},
		}

		for _, test := range tests {
			t.Run(test.name, func(t *testing.T) {
				${0}
			})
		}
	}]],
    },
    {
      trigger = "funcbench",
      body = [[
	func Benchmark${1:Name}(b *testing.B) {
		for i := 0; i < b.N; i++ {
			${2}
		}
	}
	${0}
]],
    },
  },
}

local function get_buf_snips()
  local ft = vim.bo.filetype
  local snips = vim.list_slice(global_snippets)

  if ft and snippets_by_filetype[ft] then
    vim.list_extend(snips, snippets_by_filetype[ft])
  end

  return snips
end

local M = {}

-- cmp source for snippets to show up in completion menu
function M.register_cmp_source()
  local cmp_source = {}
  local cache = {}
  function cmp_source.complete(_, _, callback)
    local bufnr = vim.api.nvim_get_current_buf()
    if not cache[bufnr] then
      local completion_items = vim.tbl_map(function(s)
        local item = {
          word = s.trigger,
          label = s.trigger,
          kind = vim.lsp.protocol.CompletionItemKind.Snippet,
          insertText = s.body,
          insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
        }
        return item
      end, get_buf_snips())

      cache[bufnr] = completion_items
    end

    callback(cache[bufnr])
  end

  require("cmp").register_source("snippets", cmp_source)
end

return M
