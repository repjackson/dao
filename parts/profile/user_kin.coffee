if Meteor.isClient
    Template.user_kin.onCreated ->
        @autorun => Meteor.subscribe 'user_kin', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_kin.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Router.current().params.username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             recipient_id: target_user._id



    Template.user_kin_small.helpers
        user_kin: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1

    Template.user_kin.helpers
        user_kin: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'user_kin', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'debit'
            recipient_id:user._id