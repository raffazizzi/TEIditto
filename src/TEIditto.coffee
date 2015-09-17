# # TEIditto

# ODD-driven JavaScript library to load a TEI XML document and register it as HTML5 custom elements.

TEIditto = {}

(($) ->

  # Load TEI XML

  TEIditto.loadTEI = (url, cb) ->
    $.ajax
      url: url
      success: (data) ->
        parsed = $.parseXML(data) 
        if cb? then cb(parsed)
        parsed

  # Create table of elements from ODD
  # * default HTML behaviour mapping on/off (eg tei:div to html:div)
  # ** phrase level elements behave like span (can I tell this from ODD classes?)
  # * optional custom behaviour mapping 
  TEIditto.fromODD = ->

  # Without ODD, build table based on distinct list of elements in document
  TEIditto.fromTEI = (TEI, options={}, cb=null) ->
    table = {}
    $(TEI).find(':root').find('*').andSelf().each (i, el) ->
      table[el.tagName] = "tei-" + el.tagName
    if cb? then cb(table)
    table

  # Apply table
  TEIditto.applyCustomElements = (table, options={}, cb=null) ->
    for el of table
      registered_el = document.registerElement(table[el])
      # options for custom behaviour mapping
    if cb? then cb()

  # Convert TEI elements to HTML5 custom elements
  # * return document
  TEIditto.getHTML5 = (TEI_url, options={}, cb=null) ->
    TEIditto.loadTEI TEI_url, (TEI) ->
      newTree = null
      TEIditto.fromTEI TEI, options, (table) ->
        TEIditto.applyCustomElements(table, options)

        convertEl = (el) ->
          # Create new element
          newElement = $("<"+table[el.tagName]+">")
          # Copy attributes
          $.each el.attributes, (index) ->
            $(newElement).attr(el.attributes[index].name, el.attributes[index].value)
          # Recurse down
          contents = $(el).contents()
          if contents.length > 0
            contents.each (i, node) -> 
              if node.nodeType == 1
                newElement.append convertEl(node)
              else
                newElement.append node.cloneNode()

          newElement

        newTree = convertEl($(TEI).children().get(0))

      if cb? then cb(newTree)
      newTree

)($);

root = exports ? window
root.TEIditto = TEIditto