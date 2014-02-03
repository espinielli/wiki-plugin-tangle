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
        files: []
    else if parts = /^MAP(.*)WITH(.*)$/g.exec line
      if page?
        page.files.push {file: "#{parts[1]}", chunk: "#{parts[2]}"}
      else
        program.errors.push {line, message: "MAP line without target"}
    else
      program.errors.push {line, message: "can't make sense of line"}

  program.targets.push page if page?
  wiki.log program
  debugger
  program


# render in the wiki page
emit = (div, item) ->
  program = parse item.text

  div.append """
    <table style="width:100%; background:#eee; padding:.8em; margin-bottom:5px;">
    </table>"""
  console.log program
  for page in program.targets
    row = $ """<tr><td>#{page.page}<td style="text-align:right;">"""
    div.find('table').append row
    for map in page.maps
      row = $ """<tr><td>#{map.file}<td style="text-align:right;">#{map.chunk}"""
      div.find('table').append row


bind = (div, item) ->
  div.dblclick -> wiki.textEditor div, item


window.plugins.tangle = {emit, bind}