###
  The creation of the Your Jargon ('YJ') namespace
###
exports = this

exports.YJ = Em.Application.create(
  god: null

  createGod: ->
    YJ.set('god', YJ.User.createRecord("god", "yourjargon@gmail.com"))

  ready: ->
    YJ.initialize()
    YJ.createGod()
    YJ.currentUser = YJ.User.createRecord()
)

YJ.store = DS.Store.create(
  revision: 4,
  adapter: DS.RESTAdapter.create(bulkCommit: false)
)

YJ.searchTerm = Em.Object.create(term: null)

