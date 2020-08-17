if Meteor.isClient
    Template.registerHelper 'mealorder_event', () ->
        Docs.findOne @event_id



    Template.mealorder_view.onCreated ->
        @autorun => Meteor.subscribe 'event_from_mealorder_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.mealorder_view.onRendered ->

    Template.mealorder_view.events
        'click .cancel_reservation': ->
            event = @
            # Swal.fire({
            #     title: "cancel reservation?"
            #     # text: "cannot be undone"
            #     icon: 'question'
            #     confirmButtonText: 'confirm cancelation'
            #     confirmButtonColor: 'red'
            #     showCancelButton: true
            #     cancelButtonText: 'return'
            #     reverseButtons: true
            # }).then((result)=>
            #     if result.value
            #         console.log @
            #             Meteor.call 'remove_reservation', @_id, =>
            #                 Swal.fire(
            #                     position: 'top-end',
            #                     icon: 'success',
            #                     title: 'reservation removed',
            #                     showConfirmButton: false,
            #                     timer: 1500
            #                 )
            #                 Router.go "/event/#{event}/view"
            #         )
            # )_



if Meteor.isServer
    Meteor.publish 'event_from_mealorder_id', (mealorder_id)->
        mealorder = Docs.findOne mealorder_id
        Docs.find 
            _id:mealorder.event_id
            
            
    Meteor.methods
        # remove_reservation: (doc_id)->
        #     Docs.remove doc_id