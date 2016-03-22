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
    @view = new BranchListView()
    @view.setItems(["devel", "master"])
    spyOn(helpers, 'repoPath').andReturn repoPath
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor

  describe 'view specs', ->
    describe 'compare modes', ->
      beforeEach ->
        spyOn(helpers, 'execFromCurrent')

      it 'should trigger a diff by default', ->
        @view.confirmSelection()

        mrc = helpers.execFromCurrent.mostRecentCall
        expect(mrc.args.length).toEqual(2)
        expect(mrc.args[0]).toEqual("git diff devel some.file")
        expect(typeof(mrc.args[1])).toEqual("function")

      it 'should trigger a difftool by default', ->
        @view.setCompareMode(BranchListView.DIFFTOOL)
        @view.confirmSelection()
        mrc = helpers.execFromCurrent.mostRecentCall
        expect(mrc.args.length).toEqual(2)
        expect(mrc.args[0]).toEqual("git difftool devel some.file")
        expect(typeof(mrc.args[1])).toEqual("function")

    it 'should place master branch first', ->
      spyOn(window, 'alert')
      spyOn(@view, 'setItems').andCallFake (itemz) ->
        expect(itemz).toEqual(["master","branch1", "branch2"])
      spyOn(helpers, 'execFromCurrent').andCallFake (cmd, callback) ->
        callback(null, "  branch1\n* master\n  branch2", "")
      @view.display()

    it 'should show an alert in the case of unknown revision or path not in the working tree', ->
      git_err_string="""
Uncaught Error: Command failed: /bin/sh -c git diff master db/migrate/my_gration.rb
fatal: ambiguous argument 'db/migrate/my_gration.rb': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
      """
      spyOn(window, 'alert')
      spyOn(helpers, 'execFromCurrent').andCallFake (cmd, callback) ->
        callback(git_err_string, "", git_err_string)
      @view.confirmSelection()
      expect(window.alert).toHaveBeenCalledWith("Unknown revision or path not in the working tree!")

    it 'should show an alert if stdout content is the same', ->
      spyOn(window, 'alert')
      spyOn(helpers, 'execFromCurrent').andCallFake (cmd, callback) ->
        callback(null, "", "")
      @view.confirmSelection()
      expect(window.alert).toHaveBeenCalledWith("No changes!")
