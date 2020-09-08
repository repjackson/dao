if Meteor.isClient
    Router.route '/user/:username/offers', (->
        @layout 'profile_layout'
        @render 'user_offers'
        ), name:'user_offers'

    Template.user_offers.onCreated ->
        @autorun -> Meteor.subscribe 'user_offers', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_offers', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'offer'

    Template.user_offers.events
        'keyup .new_offer': (e,t)->
            if e.which is 13
                val = $('.new_offer').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'offer'
                    body: val
                    target_user_id: target_user._id



    Template.user_offers.helpers
        offers: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'offer'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_offers', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'offer'
            _author_id:user._id
            
