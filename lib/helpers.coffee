exec = require("child_process").exec

module.exports =
  repoPath: ->
    project = atom.project
    path = atom.workspace.getActiveTextEditor()?.getPath()
    dir = project.getDirectories().filter((d) -> d.contains(path))[0]
    if dir
      dir.path
    else
      throw "No dir found"

  currentFileProjectPath: ->
    repoPath = @repoPath()
    fullFilePath = atom.workspace.getActiveTextEditor().getPath()
    fullFilePath.replace(repoPath, "").substring(1)

  currentFileFullPath: ->
    atom.workspace.getActiveTextEditor().getPath()

  execFromCurrent: (cmd, callback)->
    exec cmd, cwd: @repoPath(), callback
