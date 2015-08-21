# # Tests for TEIditto

describe 'TEIditto', ->

  it "parses XML", (done) ->

    cb = (data) ->
      $(data).find("TEI").get(0).tagName.should.equal("TEI")
      done()

    TEIditto.loadTEI("testTEI.xml", cb)

  it "builds non-empty element table from TEI", (done) ->

    cb = (data) ->
      table = TEIditto.fromTEI(data)
      Object.keys(table).should.have.length.above(1)
      done()

    TEIditto.loadTEI("testTEI.xml", cb)

  it "converts TEI to custom HTML5 elements", (done) ->

    cb = (html5) ->
      @html5 = html5
      $(html5).find("tei-title").eq(1).text().should.equal("Die Leiden des jungen Werther")
      done()

    TEIditto.getHTML5("testTEI.xml", null, cb)