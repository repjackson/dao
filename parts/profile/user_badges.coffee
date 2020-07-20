if Meteor.isClient
    Router.route '/user/:username/badges', (->
        @layout 'profile_layout'
        @render 'user_badges'
        ), name:'user_badges'
    

    Template.user_badges.onCreated ->
        @autorun => Meteor.subscribe 'user_badges', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'badge'

    Template.user_badges.events
        'keyup .new_badge': (e,t)->
            if e.which is 13
                val = $('.new_badge').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'badge'
                    body: val
                    target_user_id: target_user._id
                val = $('.new_badge').val('')

        'click .submit_badge': (e,t)->
            val = $('.new_badge').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'badge'
                body: val
                target_user_id: target_user._id
            val = $('.new_badge').val('')



    Template.user_badges.helpers
        user_badges: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'badge'
                # target_user_id: target_user._id

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_badges', (username)->
        Docs.find
            model:'badge'
