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
    full_file_path = atom.workspace.getActiveTextEditor().getPath()
    full_file_path.replace(repoPath, "").substring(1)

  execFromCurrent: (cmd, callback)->
    exec cmd, cwd: @repoPath(), callback
