{SelectListView} = require 'atom-space-pen-views'

module.exports =
class BranchListView extends SelectListView
  constructor: (serializedState) ->
    super
    @addClass('overlay from-top')
    # @setItems(['Hello', 'World'])
    @panel = atom.workspace.addModalPanel(item: this)
    # @panel = atom.workspace.addModalPanel(item: this, visible: false)

  toggle_display: ->
    console.log "toggle_display"
    if @panel?.isVisible()
      @remove()
    else
      @display()

  display: ->
    @setItems ["Hello", "World"]
    @panel.show()
    # @focusFilterEditor()

  remove: ->
    @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    console.log("#{item} was selected")
    @panel.destroy()
