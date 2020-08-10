if Meteor.isClient
    Router.route '/inbox', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'inbox'

    Template.inbox.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'messge', Router.current().params.username
        @autorun => Meteor.subscribe 'my_received_messages'
        @autorun => Meteor.subscribe 'my_sent_messages'
        # @autorun => Meteor.subscribe 'inbox', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'stat'

    Template.inbox.events
        'keyup .new_offer': (e,t)->
            if e.which is 13
                val = $('.new_offer').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'offer'
                    body: val
                    target_user_id: target_user._id



    Template.inbox.helpers
        my_received_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                _author_id: Meteor.userId()
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        my_sent_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                recipient_id: Meteor.userId()
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'inbox', (username)->
        Docs.find
            model:'offer'
