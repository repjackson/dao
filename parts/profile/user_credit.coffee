if Meteor.isClient
    Router.route '/user/:username/credit', (->
        @layout 'profile_layout'
        @render 'user_credit'
        ), name:'user_credit'

    Template.user_credit.onCreated ->
        @autorun -> Meteor.subscribe 'received_dollar_debits', Router.current().params.username
        @autorun -> Meteor.subscribe 'sent_dollar_debits', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_credit', Router.current().params.username

    Template.user_credit.events
        'keyup .new_debit': (e,t)->
            if e.which is 13
                val = $('.new_debit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'debit'
                    body: val
                    target_user_id: target_user._id



    Template.user_credit.helpers
        received_dollar_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'dollar_debit'
                recipient_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        sent_dollar_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'dollar_debit'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'received_dollar_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'dollar_debit'
            recipient_id:user._id
    
    Meteor.publish 'sent_dollar_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'dollar_debit'
            _author_id:user._id
