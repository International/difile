{SelectListView} = require 'atom-space-pen-views'
exec = require("child_process").exec
os = require("os")
Path = require("path")
fs = require("fs")
{CompositeDisposable} = require 'atom'

module.exports =
class BranchListView extends SelectListView
  constructor: (serializedState) ->
    super
    @disposables = new CompositeDisposable
    @addClass('overlay from-top')
    @panel = atom.workspace.addModalPanel(item: this)

  toggle_display: ->
    if @panel?.isVisible()
      @remove()
    else
      @display()

  repo_path: ->
    atom.workspace.getActiveTextEditor().project.rootDirectories[0].path

  current_file_project_path: ->
    repo_path = @repo_path()
    full_file_path = atom.workspace.getActiveTextEditor().getPath()
    full_file_path.replace(repo_path, "").substring(1)

  display: ->
    exec "git branch | cut -c 3-", cwd: @repo_path(), (err, stdout, stderr) =>
      if(err != null)
        throw err;
      lines = stdout.split(os.EOL).filter (l) -> l != ""
      @setItems lines

    @panel.show()
    @focusFilterEditor()

  remove: ->
    @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    diffPath = Path.join(@repo_path(), "difile.diff")
    project_path = @current_file_project_path()
    exec "git diff #{item} #{project_path}", cwd: @repo_path(), (err, stdout, stderr) =>
      if(err != null)
        throw err;
      fs.writeFile diffPath, stdout, (err) =>
        if err != null
          throw err
        atom.workspace.open(diffPath).then (textEditor) =>
          @disposables.add textEditor.onDidDestroy -> fs.unlink diffPath
        @panel.hide()
