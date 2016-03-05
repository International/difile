{SelectListView} = require 'atom-space-pen-views'

module.exports =
class BranchListView extends SelectListView
  constructor: (serializedState) ->
    super
    @addClass('overlay from-top')
    @setItems(['Hello', 'World'])
    @panel = atom.workspace.addModalPanel(item: this, visible: false)
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    console.log("#{item} was selected")
    @panel.destroy()
