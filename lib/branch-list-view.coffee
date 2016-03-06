{SelectListView} = require 'atom-space-pen-views'
exec = require("child_process").exec
os = require("os")

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
    repo_path = atom.project.rootDirectories[0].path
    exec "git branch | cut -c 3-", cwd: repo_path, (err, stdout, stderr) =>
      if(err != null)
        throw err;
      lines = stdout.split(os.EOL).filter (l) -> l != ""
      @setItems lines

    @panel.show()

  remove: ->
    @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    console.log("#{item} was selected")
    @panel.destroy()
