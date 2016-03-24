{CompositeDisposable} = require 'atom'
BranchListView = require "./branch-list-view"
{$$$, View} = require "atom-space-pen-views"

module.exports =
class CustomDiffView extends View
  initialize: (tabInstance) ->
    @diffContent = tabInstance.tabContent
    @renderHTML()

  renderDiffAsHTML: (diffContent) ->
    stringToShow = diffContent.split("\n").map (l) =>
      firstChar = l[0]
      diffContent = l.substring(1)
      removeFirstChar = true
      classToAdd = switch firstChar
        when "-"
          "removal"
        when "+"
          "addition"
        else
          removeFirstChar = false
          ""
      stringToShow = if removeFirstChar then diffContent else l
      stringToShow = stringToShow.replace /[ ]/g, "&nbsp;"
      @span class: classToAdd, =>
        @raw stringToShow
      @br()

  renderHTML: ->
    self = @
    @html $$$ ->
      @div class: "difile", =>
        self.renderDiffAsHTML.apply(@, [self.diffContent])


  @content: ->
    @div class: 'custom-diff-preview native-key-bindings', tabindex: -1
