exports = this
exports.YJ = Em.Application.create()

####
# MODELS
####

YJ.Term = Em.Object.extend(
  term: null
  description: null

  firstLetter: (->
    return @get('term').charAt(0).toUpperCase()
  ).property('term')

  sortValue: (->
    return @get("term")
  ).property("term")
)

####
# CONTROLLERS
####

YJ.termsController = Em.ArrayProxy.create(
  content: []
  currentTerm: null
  searchLetter: null

  add: (term) ->
    length = @get("length")
#    idx = undefined
    srtValue = term.get('sortValue')
    console.log("termsController#add: sortValue='#{srtValue}'")
    idx = @binarySearch(srtValue, 0, length)
    console.log("termsController#add: sortValue='#{srtValue}'; idx='#{idx}'; length='#{@.get('content').length}'")
    @insertAt idx, term
    term.addObserver "sortValue", this, "termSortValueDidChange"

  addCurrent: ->
    @add(@currentTerm)
    YJ.stateManager.goToState('mainState')

  # todo: move this to a SortArray class
  binarySearch: (value, low, high) ->
    mid = undefined
    midValue = undefined
    return low  if low is high
    mid = low + Math.floor((high - low) / 2)
    midValue = @objectAt(mid).get("sortValue")
    return @binarySearch(value, mid + 1, high) if value > midValue
    return @binarySearch(value, low, mid) if value < midValue
    mid

  remove: (term) ->
    @removeObject term
    term.removeObserver "sortValue", this, "termSortValueDidChange"

  termSortValueDidChange: (term) ->
    console.log("termSortValueDidChange: '#{term.term}'")
    @remove term
    @add term

  newTerm: ->
    @set('currentTerm', YJ.Term.create())
    YJ.stateManager.goToState('newTermState')

  editTerm: (term) ->
    console.log("editTerm: '#{term.term}' => '#{term.description}'")
    @set('currentTerm', term)
    YJ.stateManager.goToState('editTermState')

  updateTerm: () ->
    YJ.stateManager.goToState('mainState')

  filtered: (->
    if @get("searchLetter") is null
      @get('content')
    else
      filteredList = @get('content').filterProperty 'firstLetter', @get('searchLetter')
  ).property('searchLetter').cacheable()


  # This is temporary so that we can see some generated data on the list page.  It will come out soon.
  loadTermsForTesting: ->
    t = YJ.Term.create(term: "Newt")
    t.set('description', 'plays fast and loose in debates')
    @add(t)
    t = YJ.Term.create(term: "Mitt")
    t.set('description', 'has a lot of money')
    @add(t)
    t = YJ.Term.create(term: "Santorum")
    t.set('description', 'Dan Savage coined his last name')
    @add(t)

  # Another debugger function. Will come out
  addTestTerm: ->
    t = YJ.Term.create(term: "Obama", description: "Good speaker")
    @pushObject(t)

)

YJ.alphabetController = Em.ArrayProxy.create(
  content: ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
)

####
# VIEWS
####

YJ.MainView = Em.View.extend(
  templateName: 'templates/terms/index',
  elementId: 'content'
)

YJ.ListTermsView = Em.View.extend(
  templateName: 'templates/terms/list'
  termsBinding: 'YJ.termsController.filtered'
)

YJ.LinkView = Em.View.extend(
  term: null

  edit: (event) ->
    event.preventDefault() # this keeps the browser from trying to refresh/reload the page
    term = this.get('term')
    console.log(this.get('term'))
    YJ.termsController.editTerm(term)
)

YJ.EditTermView = Em.View.extend(
  termBinding: 'YJ.termsController.currentTerm'
  templateName: 'templates/terms/edit'

  update: ->
    YJ.termsController.updateTerm()
)

YJ.NewTermView = Em.View.extend(
  termBinding: 'YJ.termsController.currentTerm'
  templateName: 'templates/terms/new'
  add: ->
    YJ.termsController.addCurrent()
)

YJ.NewTermButton = Em.Button.extend(
  term: null
  description: null
  click: ->
    YJ.termsController.newTerm()
)

#YJ.NewButtonView = Em.View.extend(
#
#  new: ->
#    YJ.termsController.newTerm()
#)

YJ.AlphabetView = Em.View.extend(
  templateName: 'templates/alphabet'

  all: (event) ->
    event.preventDefault()
    YJ.termsController.set('searchLetter', null)

)

YJ.AlphabetLinkView = Em.View.extend(

  click: (event) ->
    event.preventDefault() # this keeps the browser from trying to refresh/reload the page
    YJ.termsController.set('searchLetter', @get('content').valueOf())
)

####
# STATE MANAGER
####

YJ.stateManager = Em.StateManager.create(

  rootElement: '#content'

  mainState: Ember.ViewState.create(
    view: YJ.MainView
    isStart: true

    exit: ->
      console.log("exitting mainState")
      @._super()
  )
  newTermState: Ember.ViewState.create(
    view: YJ.NewTermView

    exit: ->
      console.log("exitting newTermState")
      @._super()
  )
  editTermState: Ember.ViewState.create(
    view: YJ.EditTermView

    exit: ->
      console.log("exitting editTermState")
      @._super()
  )
  start: @.mainState

)

# This will come out before release:
YJ.termsController.loadTermsForTesting()

# Wait for everything to load, then start
Ember.$ ->
YJ.stateManager.goToState('mainState')
