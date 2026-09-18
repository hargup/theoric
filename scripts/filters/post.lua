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

-- GFM treats \(...\) as escaped parentheses, so leftover TeX like
-- (3 \times 2 = 48) is recovered as inline math here.
function Inlines(inlines)
  local result = {}
  local index = 1

  while index <= #inlines do
    local start = inlines[index]
    local stop = nil
    local has_times = false

    if start.t == "Str" and start.text:match("^%(") then
      for look = index, #inlines do
        local item = inlines[look]
        if item.t == "Str" then
          if item.text:find("\\times", 1, true) then
            has_times = true
          end
          if item.text:match("%)$") then
            stop = look
            break
          end
        elseif item.t ~= "Space" then
          break
        end
      end
    end

    if stop and has_times then
      local tex = {}
      for look = index, stop do
        local item = inlines[look]
        if item.t == "Space" then
          table.insert(tex, " ")
        else
          table.insert(tex, item.text)
        end
      end
      local math = table.concat(tex):gsub("^%(", ""):gsub("%)$", "")
      table.insert(result, pandoc.Math("InlineMath", math))
      index = stop + 1
    else
      table.insert(result, inlines[index])
      index = index + 1
    end
  end

  return result
end

function Pandoc(doc)
  local title = doc.blocks[1]
  if title == nil or title.t ~= "Header" or title.level ~= 1 then
    error("post must begin with a level-one heading")
  end

  local subtitle_disabled = doc.meta.subtitle ~= nil
    and pandoc.utils.stringify(doc.meta.subtitle) == "false"

  local body_start = 2
  if not subtitle_disabled then
    local subtitle = doc.blocks[2]
    if subtitle == nil or subtitle.t ~= "Para" then
      error("post must include an opening paragraph after its title, or set `subtitle: false` in its metadata")
    end
    doc.meta.subtitle = pandoc.MetaInlines(subtitle_inlines(subtitle.content))
    body_start = 3
  else
    doc.meta.subtitle = nil
  end

  doc.meta.title = pandoc.MetaInlines(title.content)

  required_metadata(doc.meta, "description")
  required_metadata(doc.meta, "author")
  required_metadata(doc.meta, "author_url")
  required_metadata(doc.meta, "date")
  required_metadata(doc.meta, "canonical")

  doc.meta.author_url = pandoc.MetaString(pandoc.utils.stringify(doc.meta.author_url))

  local body = {}
  for index = body_start, #doc.blocks do
    table.insert(body, doc.blocks[index])
  end

  doc.blocks = body
  return doc
end
