if Meteor.isClient
    Router.route '/user/:username/credits', (->
        @layout 'profile_layout'
        @render 'user_credits'
        ), name:'user_credits'

    Template.user_credits.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'


    Template.user_credits.onCreated ->
        @autorun => Meteor.subscribe 'user_credits', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'credit'

    Template.user_credits.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Router.current().params.username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             target_user_id: target_user._id



    Template.user_credits.helpers
        user_credits: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                target_user_id: target_user._id
            },
                sort:_timestamp:-1


        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_credits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'debit'
            target_id:user._id
