if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
        
        
    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'user_credits', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_debits', Router.current().params.username
        
    Template.user_dashboard.helpers
        user_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
            }, sort: _timestamp:-1
        user_credits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                recipient_id: current_user._id
            }, sort: _timestamp:-1


if Meteor.isServer
    Meteor.publish 'user_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'debit'
            _author_id:user._id
