{SelectListView} = require 'atom-space-pen-views'
os = require("os")
Path = require("path")
fs = require("fs")
{CompositeDisposable} = require 'atom'
helpers = require "../helpers"

module.exports =
class BranchListView extends SelectListView
  @DIFF = "diff"
  @DIFF_WITH_CUSTOM_VIEW = "diff_html_view"
  @DIFFTOOL = "difftool"

  constructor: (serializedState, compareMode = BranchListView.DIFF) ->
    super
    @setCompareMode compareMode

    @disposables = new CompositeDisposable
    @addClass('overlay from-top')
    @panel = atom.workspace.addModalPanel(item: this, visible: false)

  setCompareMode: (action) ->
    @compareMode = action

    switch @compareMode
      when BranchListView.DIFF, BranchListView.DIFF_WITH_CUSTOM_VIEW
        @confirmedCb = @runDiff
      when BranchListView.DIFFTOOL
        @confirmedCb = @runDiffTool

  display: ->
    helpers.execFromCurrent "git branch", (err, stdout, stderr) =>
      splitOn = os.EOL
      if(err != null)
        throw err
      if stdout.indexOf splitOn == -1
        splitOn = "\n"
      lines = stdout.split(splitOn).filter((l) -> l != "").map((l) -> l.substring(2))
      masterBranch = "master"
      haveMaster = false
      counter = 0
      while counter < lines.length
        line = lines[counter]
        if line == masterBranch
          lines.splice(counter,1)
          haveMaster = true
          break
        counter += 1
      lines = lines.sort()
      if haveMaster != 0
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
        if @compareMode == BranchListView.DIFF
          fs.writeFile diffPath, stdout, (err) =>
            if err != null
              throw err
            atom.workspace.open(diffPath).then (textEditor) =>
              @disposables.add textEditor.onDidDestroy -> fs.unlink diffPath
        else
          @onDiffOutput(currentFilePath, stdout)
        @panel.hide()

  runAction: (branchName, currentFilePath) ->
    if @compareMode == BranchListView.DIFF
      @runDiff(branchName, currentFilePath)
    else
      @runDiffTool(branchName, currentFilePath)

  runDiffTool: (branchName, currentFilePath) ->
    @panel.hide()
    helpers.execFromCurrent "git difftool #{branchName} #{currentFilePath}", (err, stdout, stderr) =>
      if(err != null)
        throw err

  onConfirmed: (@confirmedCb) ->
  onDiffOutput: (@onDiffOutput) ->

  confirmed: (branchName) ->
    currentFilePath = helpers.currentFileProjectPath()
    @confirmedCb(branchName, currentFilePath)
