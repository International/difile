{CompositeDisposable} = require 'atom'
BranchListView = require "./views/branch-list-view"
DiffTab = require "./diff-tab"

module.exports = Difile =
  subscriptions: null
  branchlistViewState: {previousSelection: null}

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:difftool-toggle': => @diffToolToggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:custom-diff-toggle': => @customDiffToggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'difile:checkout-version-from-other-branch': => @checkoutOtherVersion()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    difileViewState: {}

  showBranchView: (viewState, compareMode, diffOutputCb) ->
    br = new BranchListView(viewState, compareMode)
    br.onConfirmed (branchName) ->
      viewState.previousSelection = branchName
    if diffOutputCb?
      br.onDiffOutput diffOutputCb
    br.display()

  checkoutOtherVersion: ->
    @showBranchView(@branchlistViewState, BranchListView.CHECKOUT_OTHER)

  diffToolToggle: ->
    @showBranchView(@branchlistViewState, BranchListView.DIFFTOOL)

  customDiffToggle: ->
    @showBranchView @branchlistViewState, BranchListView.DIFF_WITH_CUSTOM_VIEW, (filePath, output) ->
      atom.workspace.getActivePane().activateItem(new DiffTab("HTML Diff: #{filePath}",output))

  toggle: ->
    @showBranchView(@branchlistViewState, BranchListView.DIFF)
