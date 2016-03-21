{CompositeDisposable} = require 'atom'
BranchListView = require "./branch-list-view"

module.exports = Difile =
  subscriptions: null

  activate: (state) ->
    @bListView = new BranchListView(state.difileViewState)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:difftool-toggle': => @diffToolToggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @bListView.destroy()

  serialize: ->
    difileViewState: @bListView.serialize()

  diffToolToggle: ->
    @bListView.setCompareMode(BranchListView.DIFFTOOL)
    @bListView.toggleDisplay()

  toggle: ->
    @bListView.setCompareMode(BranchListView.DIFF)
    @bListView.toggleDisplay()
