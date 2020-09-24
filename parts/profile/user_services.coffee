if Meteor.isClient
    Router.route '/user/:username/services', (->
        @layout 'profile_layout'
        @render 'user_services'
        ), name:'user_services'

    Template.user_services.onCreated ->
        @autorun -> Meteor.subscribe 'user_services', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_services', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'service'

    Template.user_services.events
        'keyup .new_service': (e,t)->
            if e.which is 13
                val = $('.new_service').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'service'
                    body: val
                    target_user_id: target_user._id



    Template.user_services.helpers
        services: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'service'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_services', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'service'
            _author_id:user._id
            
