if Meteor.isClient
    Template.rentals.onCreated ->
        @autorun => Meteor.subscribe 'rentals', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'rental'

    Template.rentals.events
        'keyup .add_rental': (e,t)->
            Docs.insert
                model:'rental'



    Template.rentals.helpers
        user_rentals: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'rental'
                _author_id:target_user._id
                # target_user_id: target_user._id

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'rentals', (username)->
        Docs.find
            model:'rental'
