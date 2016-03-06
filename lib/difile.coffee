DifileView = require './difile-view'
{CompositeDisposable} = require 'atom'
BranchListView = require "./branch-list-view"

module.exports = Difile =
  difileView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    console.log "activating"
    @difileView = new DifileView(state.difileViewState)
    @bListView = new BranchListView(state.difileViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @difileView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:branch-list': => @toggle_branch_list()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @difileView.destroy()

  serialize: ->
    difileViewState: @difileView.serialize()

  toggle_branch_list: ->
    @bListView.toggle_display()

  toggle: ->
    @bListView.toggle_display()
