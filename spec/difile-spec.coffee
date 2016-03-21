Difile = require '../lib/difile'
BranchListView = require '../lib/branch-list-view'
helpers = require '../lib/helpers'
child_process = require("child_process")

{
  pathToRepoFile,
  textEditor,
  panel
} = require './atom_objects'

describe "Difile", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('difile')

  describe "when triggering difile:toggle", ->
    it "should populate the select view with branches", ->
      spyOn(atom.workspace, 'addModalPanel').andReturn(panel)
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
      spyOn(atom.project, 'getDirectories').andReturn [pathToRepoFile]
      spyOn(helpers, 'execFromCurrent').andCallFake (cmd, callback) ->
        callback(null, "master\ndevel")

      spyOn(BranchListView.prototype, 'setItems').andCallFake (itemz) ->
        expect(itemz).toEqual(["master","devel"])
      atom.commands.dispatch workspaceElement, 'difile:toggle'
