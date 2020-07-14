if Meteor.isClient
    Router.route '/user/:username/gifted', (->
        @layout 'profile_layout'
        @render 'user_gifts'
        ), name:'user_gifts'

    Template.user_gifts.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'gift', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_gifts', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'gift'

    Template.user_gifts.events
        'keyup .new_gift': (e,t)->
            if e.which is 13
                val = $('.new_gift').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'gift'
                    body: val
                    target_user_id: target_user._id



    Template.user_gifts.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'gift'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_gifts', (username)->
        Docs.find
            model:'gift'
