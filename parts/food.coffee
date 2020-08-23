if Meteor.isClient
    Template.registerHelper 'mealorder_meal', () ->
        Docs.findOne @meal_id

    Template.food.onCreated ->
        @autorun => Meteor.subscribe 'meal_from_mealorder_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'meal'
        @autorun => Meteor.subscribe 'model_docs', 'order'
        
    Template.food.onRendered ->

    Template.food.helpers
        orders: ->
            Docs.find 
                model:'order'
        
    Template.food.events
        'click .order': ->
            Docs.insert 
                model:'order'
            
    
        'click .cancel_order': ->
            event = @
            Swal.fire({
                title: "cancel order?"
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
                        title: 'order removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
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
        # remove_order: (doc_id)->
        #     Docs.remove doc_id