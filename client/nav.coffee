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
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_debit_id =
            Docs.insert
                model:'debit'
                recipient_id: @_id
        Router.go "/debit/#{new_debit_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"
