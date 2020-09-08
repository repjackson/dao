if Meteor.isClient
    Router.route '/user/:username/tribes', (->
        @layout 'profile_layout'
        @render 'user_tribes'
        ), name:'user_tribes'

    Template.user_tribes.onCreated ->
        @autorun -> Meteor.subscribe 'user_member_tribes', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_leader_tribes', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_tribes', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'order'

    Template.user_tribes.events
        'keyup .new_order': (e,t)->
            if e.which is 13
                val = $('.new_order').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'order'
                    body: val
                    target_user_id: target_user._id

    Template.enter_tribe.events
        'click .enter': ->
            Meteor.call 'enter_tribe', @_id, ->

    Template.user_tribes.helpers
        tribes: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'order'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        user_member_tribes: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'tribe'
                tribe_member_ids:$in:[user._id]
            
        user_leader_tribes: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'tribe'
                tribe_leader_ids:$in:[user._id]




if Meteor.isServer
    Meteor.methods 
        enter_tribe: (tribe_id)->
            Meteor.users.update Meteor.userId(),
                $set:
                    current_tribe_id:tribe_id
    
    Meteor.publish 'user_member_tribes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'tribe'
            tribe_member_ids:$in:[user._id]
            
    Meteor.publish 'user_leader_tribes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'tribe'
            tribe_leader_ids:$in:[user._id]
            
