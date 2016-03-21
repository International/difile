Difile = require '../lib/difile'
BranchListView = require '../lib/branch-list-view'
helpers = require '../lib/helpers'
child_process = require("child_process")

{
  pathToRepoFile,
  textEditor,
  panel,
  repoPath
} = require './atom_objects'

describe "BranchListView", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('difile')

  describe 'view specs', ->
    it 'should trigger a diff by default', ->
      spyOn(helpers, 'repoPath').andReturn repoPath
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
      spyOn(helpers, 'execFromCurrent')

      view = new BranchListView()
      view.setItems(["devel", "master"])
      view.confirmSelection()
      mrc = helpers.execFromCurrent.mostRecentCall
      expect(mrc.args.length).toEqual(2)
      expect(mrc.args[0]).toEqual("git diff devel some.file")
      expect(typeof(mrc.args[1])).toEqual("function")

    it 'should trigger a difftool by default', ->
      spyOn(helpers, 'repoPath').andReturn "/home/geo/github/difile"
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
      spyOn(helpers, 'execFromCurrent')

      view = new BranchListView()
      view.setCompareMode(BranchListView.DIFFTOOL)
      view.setItems(["devel", "master"])
      view.confirmSelection()
      mrc = helpers.execFromCurrent.mostRecentCall
      expect(mrc.args.length).toEqual(2)
      expect(mrc.args[0]).toEqual("git difftool devel some.file")
      expect(typeof(mrc.args[1])).toEqual("function")