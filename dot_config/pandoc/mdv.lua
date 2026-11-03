-- Pandoc filter for mdv: shows a document's YAML front matter as a box at the
-- top (Pandoc would otherwise hide it) and titles the page after the file.

local function text(value)
  if pandoc.utils.type(value) == "List" then
    local parts = {}
    for _, item in ipairs(value) do
      parts[#parts + 1] = pandoc.utils.stringify(item)
    end
    return table.concat(parts, ", ")
  end
  return pandoc.utils.stringify(value)
end

function Pandoc(doc)
  local keys = {}
  for key in pairs(doc.meta) do
    keys[#keys + 1] = key
  end
  table.sort(keys)

  if #keys > 0 then
    local items = {}
    for _, key in ipairs(keys) do
      local value = text(doc.meta[key])
      items[#items + 1] = { { pandoc.Str(key) }, { { pandoc.Plain({ pandoc.Str(value ~= "" and value or "—") }) } } }
    end
    local html = pandoc.write(pandoc.Pandoc({ pandoc.DefinitionList(items) }), "html")
    doc.blocks:insert(1, pandoc.RawBlock("html", (html:gsub("^<dl>", '<dl class="front-matter">'))))
  end

  -- Front matter is shown above, so keep it out of Pandoc's own title block
  local file = PANDOC_STATE.input_files[1] or "Markdown"
  doc.meta = pandoc.Meta({ pagetitle = pandoc.path.filename(file) })
  return doc
end
