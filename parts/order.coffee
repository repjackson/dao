if Meteor.isClient
    Template.registerHelper 'order_offer', () -> Docs.findOne @offer_id

    Template.registerHelper 'order_tax', () -> @purchase_price/100
    Router.route '/order/:doc_id/view', (->
        @layout 'layout'
        @render 'order_view'
        ), name:'order_view'


    Template.order_view.onCreated ->
        @autorun => Meteor.subscribe 'offer_from_order_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        
    Template.order_view.onRendered ->

    Template.order_view.events
        'click .cancel_order': ->
            event = @
            Swal.fire({
                title: "cancel order?"
                # text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'confirm'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'return'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'order canceled',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Docs.update @offer_id,
                        $inc:inventory:1
                    Router.go "/offer/#{@offer_id}/view"
            )

        'click .mark_delivery_started': ->
            event = @
            Swal.fire({
                title: "start delivery?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'confirm'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.update @_id, 
                        $set:
                            delivery_started: true
                            delivery_start_timestamp:Date.now()
                            status:'delivery started'
                    Swal.fire(
                        position: 'top-start',
                        icon: 'success',
                        title: 'delivery started',
                        showConfirmButton: false,
                        timer: 1000
                    )
            )
        
        
        'click .mark_delivery_ended': ->
            event = @
            Swal.fire({
                title: "mark delivery ended?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'confirm'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.update @_id, 
                        $set:
                            delivery_ended: true
                            delivery_end_timestamp:Date.now()
                            seller_complete:true
                            status:'seller complete'
                    Swal.fire(
                        position: 'top-start',
                        icon: 'success',
                        title: 'delivery marked complete',
                        showConfirmButton: false,
                        timer: 1000
                    )
            )
        
        
        'click .mark_delivery_accepted': ->
            event = @
            Swal.fire({
                title: "mark delivery accepted?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'confirm'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.update @_id, 
                        $set:
                            delivery_accepted: true
                            delivery_accepted_timestamp:Date.now()
                            buyer_complete:true
                            order_complete:true
                            status:'complete'
                    Swal.fire(
                        position: 'top-start',
                        icon: 'success',
                        title: 'delivery marked complete',
                        showConfirmButton: false,
                        timer: 1000
                    )
            )
        
        
        
        'click .submit_order': ->
            Docs.update @_id,
                $set:submitted:true

        'click .unsubmit_order': ->
            Docs.update @_id,
                $set:submitted:false


if Meteor.isServer
    Meteor.publish 'offer_from_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find 
            _id:order.offer_id
            
            
    Meteor.methods
        # remove_reservation: (doc_id)->
        #     Docs.remove doc_id
        

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
        if username is 'dao'
            Docs.find({
                model:'order'
            },{
                limit:20
                sort: _timestamp:-1
            })
        else
            Docs.find({
                model:'order'
                _author_id:user._id
            },{
                limit:20
                sort: _timestamp:-1
            })
        