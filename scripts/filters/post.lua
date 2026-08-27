local function required_metadata(meta, key)
  if meta[key] == nil or pandoc.utils.stringify(meta[key]) == "" then
    error("missing required post metadata: " .. key)
  end
end

local function subtitle_inlines(inlines)
  local result = {}

  for _, inline in ipairs(inlines) do
    if inline.t == "SoftBreak" then
      table.insert(result, pandoc.LineBreak())
    else
      table.insert(result, inline)
    end
  end

  return result
end

function Link(link)
  if link.target:match("^https?://") then
    link.attributes.target = "_blank"
    link.attributes.rel = "noopener"
  end
  return link
end

function Pandoc(doc)
  local title = doc.blocks[1]
  if title == nil or title.t ~= "Header" or title.level ~= 1 then
    error("post must begin with a level-one heading")
  end

  local subtitle = doc.blocks[2]
  if subtitle == nil or subtitle.t ~= "Para" then
    error("post must include an opening paragraph after its title")
  end

  doc.meta.title = pandoc.MetaInlines(title.content)
  doc.meta.subtitle = pandoc.MetaInlines(subtitle_inlines(subtitle.content))

  required_metadata(doc.meta, "description")
  required_metadata(doc.meta, "author")
  required_metadata(doc.meta, "author_url")
  required_metadata(doc.meta, "date")
  required_metadata(doc.meta, "canonical")

  doc.meta.author_url = pandoc.MetaString(pandoc.utils.stringify(doc.meta.author_url))

  local body = {}
  for index = 3, #doc.blocks do
    table.insert(body, doc.blocks[index])
  end

  doc.blocks = body
  return doc
end
