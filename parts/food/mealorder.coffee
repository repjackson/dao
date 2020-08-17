if Meteor.isClient
    Template.registerHelper 'mealorder_meal', () ->
        Docs.findOne @meal_id



    Template.mealorder_view.onCreated ->
        @autorun => Meteor.subscribe 'meal_from_mealorder_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'meal'
        
    Template.mealorder_view.onRendered ->

    Template.mealorder_view.events
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


if Meteor.isServer
    Meteor.publish 'meal_from_mealorder_id', (mealorder_id)->
        mealorder = Docs.findOne mealorder_id
        Docs.find 
            _id:mealorder.meal_id
            
            
    Meteor.methods
        # remove_reservation: (doc_id)->
        #     Docs.remove doc_id