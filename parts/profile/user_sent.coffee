if Meteor.isClient
    Router.route '/user/:username/sent', (->
        @layout 'profile_layout'
        @render 'user_sent'
        ), name:'user_sent'
    Router.route '/user/:username/debits', (->
        @layout 'profile_layout'
        @render 'user_sent'
        ), name:'user_debits'

    Template.user_sent.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'debit', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_sent', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_sent.events
        'keyup .new_debit': (e,t)->
            if e.which is 13
                val = $('.new_debit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'debit'
                    body: val
                    target_user_id: target_user._id



    Template.user_sent.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_sent', (username)->
        Docs.find
            model:'debit'
