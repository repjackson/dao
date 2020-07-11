Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    # @autorun => Meteor.subscribe 'all_users'


Template.nav.events
    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .set_user': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'user', ->
            Session.set 'loading', false
    'click .set_shift': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'shift', ->
            Session.set 'loading', false
    'click .set_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'model', ->
            Session.set 'loading', false
    'click .set_shop': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'shop', ->
            Session.set 'loading', false
