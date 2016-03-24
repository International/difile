{CompositeDisposable} = require 'atom'
BranchListView = require "./views/branch-list-view"
DiffTab = require "./diff-tab"

module.exports = Difile =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:difftool-toggle': => @diffToolToggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:custom-diff-toggle': => @customDiffToggle()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    difileViewState: {}

  diffToolToggle: ->
    new BranchListView({}, BranchListView.DIFFTOOL).display()

  customDiffToggle: ->
    br = new BranchListView({}, BranchListView.DIFF_WITH_CUSTOM_VIEW)
    br.onDiffOutput (filePath, output) ->
      atom.workspace.getActivePane().activateItem(new DiffTab("HTML Diff: #{filePath}",output))
    br.display()

  toggle: ->
    new BranchListView({}, BranchListView.DIFF).display()
