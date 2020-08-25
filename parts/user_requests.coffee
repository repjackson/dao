if Meteor.isClient
    Router.route '/user/:username/requests', (->
        @layout 'profile_layout'
        @render 'user_requests'
        ), name:'user_requests'

    Template.user_requests.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'request', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_requests', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'request'

    Template.user_requests.events
        'keyup .new_request': (e,t)->
            if e.which is 13
                val = $('.new_request').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'request'
                    body: val
                    target_user_id: target_user._id



    Template.user_requests.helpers
        requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_requests', (username)->
        Docs.find
            model:'request'
