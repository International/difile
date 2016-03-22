{SelectListView} = require 'atom-space-pen-views'
os = require("os")
Path = require("path")
fs = require("fs")
{CompositeDisposable} = require 'atom'
helpers = require "./helpers"
_ = require "lodash"

module.exports =
class BranchListView extends SelectListView
  @DIFF = "diff"
  @DIFFTOOL = "difftool"

  constructor: (serializedState) ->
    super
    @actionToTake = BranchListView.DIFF

    @disposables = new CompositeDisposable
    @addClass('overlay from-top')
    @panel = atom.workspace.addModalPanel(item: this, visible: false)

  setCompareMode: (action) ->
    @actionToTake = action

  toggleDisplay: ->
    if @panel?.isVisible()
      @remove()
    else
      @display()

  display: ->
    helpers.execFromCurrent "git branch", (err, stdout, stderr) =>
      if(err != null)
        throw err
      lines = stdout.split(os.EOL).filter((l) -> l != "").map((l) -> l.substring(2))
      masterBranch = "master"
      masterBranchEntry = _.remove(lines, (l) -> l == masterBranch)
      lines = lines.sort()
      if masterBranchEntry.length != 0
        lines.unshift masterBranch
      @setItems lines

    @panel.show()
    @focusFilterEditor()

  cancelled: -> @panel.hide()

  remove: ->
    @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  runDiff: (branch, currentFilePath) ->
    diffPath = Path.join(helpers.repoPath(), ".git/difile.diff")
    helpers.execFromCurrent "git diff #{branch} #{currentFilePath}", (err, stdout, stderr) =>
      if(err != null)
        if not /unknown revision or path not in the working tree/.exec(err.toString())
          throw err
        else
          @panel.hide()
          window.alert "Unknown revision or path not in the working tree!"
          return
      if stdout == ""
        @panel.hide()
        window.alert "No changes!"
      else
        fs.writeFile diffPath, stdout, (err) =>
          if err != null
            throw err
          atom.workspace.open(diffPath).then (textEditor) =>
            @disposables.add textEditor.onDidDestroy -> fs.unlink diffPath
          @panel.hide()

  runAction: (branchName, currentFilePath) ->
    if @actionToTake == BranchListView.DIFF
      @runDiff(branchName, currentFilePath)
    else
      @runDiffTool(branchName, currentFilePath)

  runDiffTool: (branchName, currentFilePath) ->
    @panel.hide()
    helpers.execFromCurrent "git difftool #{branchName} #{currentFilePath}", (err, stdout, stderr) =>
      if(err != null)
        throw err

  confirmed: (branchName) ->
    currentFilePath = helpers.currentFileProjectPath()
    @runAction(branchName, currentFilePath)
