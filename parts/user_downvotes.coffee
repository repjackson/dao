if Meteor.isClient
    Router.route '/user/:username/downvotes', (->
        @layout 'profile_layout'
        @render 'user_downvotes'
        ), name:'user_downvotes'


    Template.user_downvotes.onCreated ->
        @autorun => Meteor.subscribe 'user_downvotes', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_downvotes.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Router.current().params.username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             _author_id: target_user._id



    Template.user_downvotes_small.helpers
        user_downvotes: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'vote'
                _author_id: target_user._id
            },
                sort:_timestamp:-1

    Template.user_downvotes.helpers
        user_downvotes: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'vote'
                _author_id: target_user._id
            },
                sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'user_downvotes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'vote'
            points:$lt:0
            _author_id:user._id