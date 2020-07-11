if Meteor.isClient
    Router.route '/user/:username/badges', (->
        @layout 'profile_layout'
        @render 'user_badges'
        ), name:'user_badges'

    Template.user_badges.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'


    Template.user_badges.onCreated ->
        @autorun => Meteor.subscribe 'user_badges', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'credit'
        @autorun => Meteor.subscribe 'model_docs', 'badge'

    Template.user_badges.events
        'keyup .new_credit': (e,t)->
            if e.which is 13
                val = $('.new_credit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'credit'
                    body: val
                    target_user_id: target_user._id



    Template.user_badges.helpers
        user_badges: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'credit'
                target_user_id: target_user._id

        all_badges: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'badge'

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_badges', (username)->
        Docs.find
            model:'credit'
