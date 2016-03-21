class PathWrapper
  constructor: (@path) ->
  contains: (str) ->
    ///#{@path}///.exec(str.path) != null

pathToRepoFile = new PathWrapper("/home/geo/github/difile/some.file")
repoPath = "/home/geo/github/difile"

module.exports =
  repoPath: repoPath
  pathToRepoFile: pathToRepoFile
  panel:
    show: -> undefined

  textEditor:
    getPath: -> pathToRepoFile.path
    getURI: -> pathToRepoFile
    onDidDestroy: (@destroy) ->
      dispose: ->
    onDidSave: (@save) ->
      dispose: -> undefined
