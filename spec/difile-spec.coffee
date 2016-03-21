Difile = require '../lib/difile'
BranchListView = require '../lib/branch-list-view'
helpers = require '../lib/helpers'
child_process = require("child_process")
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Difile", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('difile')

  class PathWrapper
    constructor: (@path) ->
    contains: (str) ->
      ///#{@path}///.exec(str.path) != null

  pathToRepoFile = new PathWrapper("some.file")

  panel =
    show: -> undefined

  textEditor =
    getPath: -> pathToRepoFile
    getURI: -> pathToRepoFile
    onDidDestroy: (@destroy) ->
      dispose: ->
    onDidSave: (@save) ->
      dispose: -> undefined

  describe "when triggering difile:toggle", ->
    it "should populate the select view with branches", ->
      spyOn(atom.workspace, 'addModalPanel').andReturn(panel)
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
      spyOn(atom.project, 'getDirectories').andReturn [pathToRepoFile]
      spyOn(helpers, 'execFromCurrent').andCallFake (cmd, callback) ->
        callback(null, "master\ndevel")

      spyOn(BranchListView.prototype, 'runDiff').andCallFake
      spyOn(BranchListView.prototype, 'setItems').andCallFake (itemz) ->
        expect(itemz).toEqual(["master","devel"])
      atom.commands.dispatch workspaceElement, 'difile:toggle'
