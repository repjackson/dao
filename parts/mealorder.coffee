if Meteor.isClient
    Template.registerHelper 'order_meal', () ->
        Docs.findOne @meal_id



    Template.order_view.onCreated ->
        @autorun => Meteor.subscribe 'meal_from_order_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'meal'
        
    Template.order_view.onRendered ->

    Template.order_view.events
        'click .cancel_order': ->
            event = @
            Swal.fire({
                title: "cancel reservation?"
                # text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'confirm cancelation'
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
                        title: 'reservation removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/m/meal/#{@meal_id}/view"
            )

        'click .submit_order': ->
            Docs.update @_id,
                $set:submitted:true

        'click .unsubmit_order': ->
            Docs.update @_id,
                $set:submitted:false


if Meteor.isServer
    Meteor.publish 'meal_from_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find 
            _id:order.meal_id
            
            
    Meteor.methods
        # remove_reservation: (doc_id)->
        #     Docs.remove doc_id