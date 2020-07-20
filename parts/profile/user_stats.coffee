if Meteor.isClient
    Router.route '/user/:username/stats', (->
        @layout 'profile_layout'
        @render 'user_stats'
        ), name:'user_stats'

    Template.user_stats.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'event', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_stats', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'event'

    Template.user_stats.events
        'keyup .new_event': (e,t)->
            if e.which is 13
                val = $('.new_event').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'event'
                    body: val
                    target_user_id: target_user._id



    Template.user_stats.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'event'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_stats', (username)->
        Docs.find
            model:'event'
