# # TEIditto

# ODD-driven JavaScript library to load a TEI XML document and register it as HTML5 custom elements.

TEIditto = {}

(($) ->

  TEIditto.elTable = {}
  TEIditto.behaviors = {}

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
    $(TEI).find(':root').find('*').andSelf().each (i, el) ->
      TEIditto.elTable[el.tagName] = "tei-" + el.tagName
    if cb? then cb(TEIditto.elTable)
    TEIditto.elTable

  # Apply table
  TEIditto.applyCustomElements = (options={}, cb=null) ->
    for el of TEIditto.elTable
      template = null
      # Add behavior if available
      bhv = TEIditto.behaviors[el]
      if bhv?
        if bhv == "div"
          template = { prototype: Object.create HTMLDivElement.prototype }
        else if bhv == "span"
          template = { prototype: Object.create HTMLSpanElement.prototype }
        else if bhv == "a"
          template = { prototype: Object.create HTMLAnchorElement.prototype }
      registered_el = document.registerElement(TEIditto.elTable[el], template)
      # options for custom behaviour mapping
    if cb? then cb()

  # Convert TEI elements to HTML5 custom elements
  # * return document
  TEIditto.getHTML5 = (TEI_url, options={}, cb=null) ->
    TEIditto.loadTEI TEI_url, (TEI) ->
      newTree = null
      TEIditto.fromTEI TEI, options, ->
        TEIditto.applyCustomElements(options)

        convertEl = (el) ->
          # Create new element
          newElement = $("<"+TEIditto.elTable[el.tagName]+">")
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

  TEIditto.addBehaviors = (bhvs) ->
    for el, bhv of bhvs
      if bhv in ["div", "span", "a"]
        TEIditto.behaviors[el] = bhv 

)($);

root = exports ? window
root.TEIditto = TEIditto