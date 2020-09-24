if Meteor.isClient
    Router.route '/user/:username/edit/alerts', (->
        @layout 'user_edit_layout'
        @render 'user_edit_alerts'
        ), name:'user_edit_alerts'


    Template.user_edit_alerts.onCreated ->
        @autorun => Meteor.subscribe 'user_edit_alerts', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

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

        transactions: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                _author_id: target_user._id
            }, 
                sort:
                    _timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_edit_alerts', (username)->
        Docs.find
            model:'picture'
