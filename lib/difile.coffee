DifileView = require './difile-view'
{CompositeDisposable} = require 'atom'

module.exports = Difile =
  difileView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @difileView = new DifileView(state.difileViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @difileView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @difileView.destroy()

  serialize: ->
    difileViewState: @difileView.serialize()

  toggle: ->
    console.log 'Difile was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
