{SelectListView} = require 'atom-space-pen-views'
os = require("os")
Path = require("path")
fs = require("fs")
{CompositeDisposable} = require 'atom'
helpers = require "./helpers"

module.exports =
class BranchListView extends SelectListView
  constructor: (serializedState) ->
    super
    @disposables = new CompositeDisposable
    @addClass('overlay from-top')
    @panel = atom.workspace.addModalPanel(item: this, visible: false)

  toggleDisplay: ->
    if @panel?.isVisible()
      @remove()
    else
      @display()

  display: ->
    helpers.execFromCurrent "git branch | cut -c 3-", (err, stdout, stderr) =>
      if(err != null)
        throw err;
      lines = stdout.split(os.EOL).filter (l) -> l != ""
      @setItems lines

    @panel.show()
    @focusFilterEditor()

  cancelled: -> @panel.hide()

  remove: ->
    @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    diffPath = Path.join(helpers.repoPath(), "difile.diff")
    projectPath = helpers.currentFileProjectPath()
    helpers.execFromCurrent "git diff #{item} #{projectPath}", (err, stdout, stderr) =>
      if(err != null)
        throw err;
      fs.writeFile diffPath, stdout, (err) =>
        if err != null
          throw err
        atom.workspace.open(diffPath).then (textEditor) =>
          @disposables.add textEditor.onDidDestroy -> fs.unlink diffPath
        @panel.hide()
