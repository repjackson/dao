if Meteor.isClient
    Router.route '/user/:username/orders', (->
        @layout 'profile_layout'
        @render 'user_orders'
        ), name:'user_orders'

    Template.user_orders.onCreated ->
        @autorun -> Meteor.subscribe 'user_orders', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'order'

    Template.user_orders.events
        'keyup .new_order': (e,t)->
            if e.which is 13
                val = $('.new_order').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'order'
                    body: val
                    target_user_id: target_user._id



    Template.user_orders.helpers
        orders: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'order'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_orders', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'order'
            _author_id:user._id
            
