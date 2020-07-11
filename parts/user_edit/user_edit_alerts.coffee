if Meteor.isClient
    Router.route '/user/:username/edit/alerts', (->
        @layout 'user_edit_layout'
        @render 'user_edit_alerts'
        ), name:'user_edit_alerts'

    Template.user_edit_alerts.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'


    Template.user_edit_alerts.onCreated ->
        @autorun => Meteor.subscribe 'user_edit_alerts', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'picture'

    Template.user_edit_alerts.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_alerts.helpers
        user_edit_alerts: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'picture'
                target_user_id: target_user._id

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_edit_alerts', (username)->
        Docs.find
            model:'picture'
