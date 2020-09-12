if Meteor.isClient
    Template.user_friends.onCreated ->
        @autorun => Meteor.subscribe 'all_users'



    Template.user_friends.helpers
        friended: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user
                Meteor.users.find
                    _id:$in:current_user.friend_ids
        friended_by: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user
                Meteor.users.find
                    friend_ids:$in:[current_user._id]


    Template.user_friend_button.helpers
        is_friend: ->
            Meteor.user() and Meteor.user().friend_ids and @_id in Meteor.user().friend_ids
    Template.user_friend_button.events
        'click .friend':->
            Meteor.users.update Meteor.userId(),
                $addToSet: friend_ids:@_id
            # Meteor.users.update @_id,    
                
        'click .unfriend':->
            Meteor.users.update Meteor.userId(),
                $pull: friend_ids:@_id
   
   
   
   
    Template.user_member_button.helpers
        is_member: ->
            Meteor.user() and Meteor.user().member_ids and @_id in Meteor.user().member_ids
    Template.user_member_button.events
        'click .member':->
            Meteor.users.update Meteor.userId(),
                $addToSet: member_ids:@_id
            # Meteor.users.update @_id,    
                
        'click .unmember':->
            Meteor.users.update Meteor.userId(),
                $pull: member_ids:@_id

    Template.user_subscribed_button.helpers
        is_subscribed: ->
            Meteor.user() and Meteor.user().subscribed_ids and @_id in Meteor.user().subscribed_ids
    Template.user_subscribed_button.events
        'click .subscribed':->
            Meteor.users.update Meteor.userId(),
                $addToSet: subscribed_ids:@_id
            # Meteor.users.update @_id,    
                
        'click .unsubscribed':->
            Meteor.users.update Meteor.userId(),
                $pull: subscribed_ids:@_id

        # 'keyup .assign_earn': (e,t)->
        #     if e.which is 13
        #         post = t.$('.assign_earn').val().trim()
        #         # console.log post
        #         current_user = Meteor.users.findOne Router.current().params.user_id
        #         Docs.insert
        #             body:post
        #             model:'earn'
        #             assigned_user_id:current_user._id
        #             assigned_username:current_user.username

        #         t.$('.assign_earn').val('')
