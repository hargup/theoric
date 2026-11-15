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

  -- A `<!-- toc -->` line becomes a nested table of contents of the post's
  -- level-2 and level-3 headings, linking to their anchors.
  local function is_toc_marker(block)
    return block.t == "RawBlock" and block.format == "html"
      and block.text:match("^%s*<!%-%-%s*toc%s*%-%->%s*$")
  end

  local function table_of_contents(blocks)
    local entries = {}
    local section = nil
    for _, block in ipairs(blocks) do
      if block.t == "Header" and block.identifier ~= "" and (block.level == 2 or block.level == 3) then
        local link = pandoc.Plain({ pandoc.Link(block.content, "#" .. block.identifier) })
        if block.level == 2 or section == nil then
          section = { link }
          table.insert(entries, section)
        else
          if section[2] == nil then section[2] = {} end
          table.insert(section[2], { link })
        end
      end
    end
    local items = {}
    for _, entry in ipairs(entries) do
      local item = { entry[1] }
      if entry[2] then table.insert(item, pandoc.BulletList(entry[2])) end
      table.insert(items, item)
    end
    return {
      pandoc.RawBlock("html", '<nav class="toc" aria-label="Contents"><details open><summary>Contents</summary>'),
      pandoc.BulletList(items),
      pandoc.RawBlock("html", "</details></nav>"),
    }
  end

  local with_toc = {}
  for _, block in ipairs(doc.blocks) do
    if is_toc_marker(block) then
      for _, b in ipairs(table_of_contents(doc.blocks)) do table.insert(with_toc, b) end
    else
      table.insert(with_toc, block)
    end
  end
  doc.blocks = with_toc

  -- Load Twitter's embed script only on posts that embed a tweet.
  pandoc.Pandoc(body):walk({
    RawBlock = function(block)
      if block.format == "html" and block.text:find('class="twitter-tweet"', 1, true) then
        doc.meta.tweet_embed = true
      end
    end,
  })

  return doc
end
