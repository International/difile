exec = require("child_process").exec

module.exports =
  repoPath: ->
    atom.workspace.getActiveTextEditor().project.rootDirectories[0].path

  currentFileProjectPath: ->
    repoPath = @repoPath()
    full_file_path = atom.workspace.getActiveTextEditor().getPath()
    full_file_path.replace(repoPath, "").substring(1)

  execFromCurrent: (cmd, callback)->
    exec cmd, cwd: @repoPath(), callback
