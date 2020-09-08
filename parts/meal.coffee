if Meteor.isClient
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    Router.route '/meal/:doc_id/edit', (->
        @layout 'layout'
        @render 'meal_edit'
        ), name:'meal_edit'
    Router.route '/meal/:doc_id/view', (->
        @layout 'layout'
        @render 'meal_view'
        ), name:'meal_view'

    Template.meals.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'
    
    Template.meal_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
    
    Template.meal_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
    
    
    Router.route '/meals', (->
        @layout 'layout'
        @render 'meals'
        ), name:'meals'
    Template.meals.events
        'click .add_meal': ->
            new_id = 
                Docs.insert 
                    model:'meal'
            Router.go "/meal/#{new_id}/edit"
            
    Template.meals.helpers
        meals: ->
            Docs.find 
                model:'meal'
                complete:$ne:true
                published:true

    Template.meal_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id

    Template.meal_card.events
        'click .meal_card': ->
            Router.go "/meal/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1



   
    Template.meal_view.onRendered ->


    Template.meal_view.events
        'click .claim': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    claimed_user_id: Meteor.userId()
                    status:'claimed'
            
                            
        'click .unclaim': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    claimed_user_id: 1
                $set:
                    status:'unclaimed'
            
                            
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: true
                    completed_by_user_id:@claimed_user_id
                    status:'complete'
                    completed_timestamp:Date.now()
            Meteor.users.update @claimed_user_id,
                $inc:points:@point_bounty
                            
        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: false
                    completed_by_user_id: null
                    status:'claimed'
                    completed_timestamp:null
            Meteor.users.update @claimed_user_id,
                $inc:points:-@point_bounty
                            

    Template.meal_view.helpers
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true



# if Meteor.isServer
#     Meteor.methods
        # send_meal: (meal_id)->
        #     meal = Docs.findOne meal_id
        #     target = Meteor.users.findOne meal.recipient_id
        #     gifter = Meteor.users.findOne meal._author_id
        #
        #     console.log 'sending meal', meal
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: meal.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -meal.amount
        #     Docs.update meal_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Template.meal_edit.onRendered ->


    Template.meal_edit.events
        'click .delete_meal': ->
            Swal.fire({
                title: "delete meal?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'meal removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/meals"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish meal?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_meal', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'meal published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish meal?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_meal', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'meal unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )


    Template.meal_edit.helpers
    Template.meal_edit.events

if Meteor.isServer
    Meteor.methods
        publish_meal: (meal_id)->
            meal = Docs.findOne meal_id
            # target = Meteor.users.findOne meal.recipient_id
            author = Meteor.users.findOne meal._author_id

            console.log 'publishing meal', meal
            Meteor.users.update author._id,
                $inc:
                    points: -meal.point_bounty
            Docs.update meal_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
        unpublish_meal: (meal_id)->
            meal = Docs.findOne meal_id
            # target = Meteor.users.findOne meal.recipient_id
            author = Meteor.users.findOne meal._author_id

            console.log 'unpublishing meal', meal
            Meteor.users.update author._id,
                $inc:
                    points: meal.point_bounty
            Docs.update request_id,
                $set:
                    published:false
                    published_timestamp:null
                    
                    
