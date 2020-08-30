if Meteor.isClient
    Router.route '/user/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    
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
        'click .unfriend':->
            Meteor.users.update Meteor.userId(),
                $pull: friend_ids:@_id

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
