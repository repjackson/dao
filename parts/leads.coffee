if Meteor.isClient
    Template.user_leads.onCreated ->
        @autorun => Meteor.subscribe 'user_leads', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'lead'

    Template.user_leads.events
        'keyup .new_lead': (e,t)->
            if e.which is 13
                val = $('.new_lead').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'lead'
                    body: val
                    target_user_id: target_user._id
                val = $('.new_lead').val('')

        'click .submit_lead': (e,t)->
            val = $('.new_lead').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'lead'
                body: val
                target_user_id: target_user._id
            val = $('.new_lead').val('')



    Template.user_leads.helpers
        user_leads: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'lead'
                # target_user_id: target_user._id



if Meteor.isServer
    Meteor.publish 'user_leads', (username)->
        Docs.find
            model:'lead'
