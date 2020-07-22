if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
        
        
    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'user_credits', Router.current().params.username
        
    Template.user_dashboard.helpers
        debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
            }, sort: _timestamp:-1
        credits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                recipient_id: current_user._id
            }, sort: _timestamp:-1
