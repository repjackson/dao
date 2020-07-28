Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    # @autorun => Meteor.subscribe 'all_users'

Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
    , 1000

Template.nav.events
    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .set_member': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'member', ->
            Session.set 'loading', false
    'click .set_shift': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'shift', ->
            Session.set 'loading', false
    'click .set_request': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'request', ->
            Session.set 'loading', false
    'click .set_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'model', ->
            Session.set 'loading', false
    'click .set_rental': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'rental', ->
            Session.set 'loading', false
    'click .set_product': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'product', ->
            Session.set 'loading', false
    'click .set_event': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'event', ->
            Session.set 'loading', false
    'click .set_badge': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'badge', ->
            Session.set 'loading', false
    'click .set_location': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'location', ->
            Session.set 'loading', false
    'click .set_discussion': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'discussion', ->
            Session.set 'loading', false
    'click .set_project': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'project', ->
            Session.set 'loading', false
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_gift_id =
            Docs.insert
                model:'gift'
                recipient_id: @_id
        Router.go "/gift/#{new_gift_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"


    'click .view_profile': ->
        Meteor.call 'calc_user_points', Meteor.userId()