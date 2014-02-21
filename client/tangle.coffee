# interpret item's markup
parse = (text) ->
  program = {targets: [], errors: []}
  page = null

  for line in text.split /\n/
    words = line.match /\S+/g
    if words is null or words.length < 1
      # ignore it
    else if words[0] is 'TANGLE'
      program.targets.push page if page?
      page =
        page: "#{(words[1..].join ' ').trim()}"
        filechunks: []
    else if parts = /^MAP(.*)TO(.*)$/g.exec line
      if page?
        page.filechunks.push {file: "#{parts[2]}", chunk: "#{parts[1]}"}
      else
        program.errors.push {line, message: "MAP line without target"}
    else
      program.errors.push {line, message: "can't make sense of line"}

  program.targets.push page if page?
  program


fetch = (page, chunks, done) ->
  wiki.log "fetching..."
  wiki.log page
  fetch = $.getJSON "/#{wiki.asSlug page}.json"
  $.when(fetch...).then (xhrs...) ->
    # get 'literate' items only
    for item in xhrs[i].story when item.type is 'literate'
      wiki.log item.name
  done page


tangle = (program) ->
  for p in program
    msg = "in page '#{p.page}'\n"
    for fc in p.filechunks
      msg += "   tangle chunk '#{fc.chunk}'\n"
  # titles = (target.page for target in program)
  # data = fetch titles, (titles) ->
  #   wiki.log "fetching...done"
  #   titles
  alert msg
  # data


# render in the wiki page
emit = (div, item) ->
  program = parse item.text
  # tangle program

  div.append (table = $ """
    <table style="width:100%; background:#eee; padding:.8em; margin-bottom:5px;">
    </table>""")
  for page in program.targets
    row = $ """<tr><td><strong>#{page.page}</strong><td>"""
    table.append row
    for fc in page.filechunks
      row = $ """<tr><td>#{fc.chunk}<td>#{fc.file}"""
      table.append row

  table.append row
  div.append (button = $ """<td><button>Tangle!""")
  button.click ->
    wiki.log program
    tangle program.targets



bind = (div, item) ->
  div.dblclick -> wiki.textEditor div, item

window.plugins.tangle = {emit, bind}