if Meteor.isClient
    Router.route '/inbox', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'inbox'

    Template.inbox.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'offer', Router.current().params.username
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
        offers: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'offer'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'inbox', (username)->
        Docs.find
            model:'offer'
