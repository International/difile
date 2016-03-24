CustomDiffView = require './views/custom-diff-view'

module.exports =
class DiffTab
  constructor: (@tabTitle, @tabContent) ->

  getTitle:     -> @tabTitle
  getViewClass: -> CustomDiffView
