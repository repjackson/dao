if Meteor.isClient
    Router.route '/meal/:doc_id/edit', (->
        @layout 'layout'
        @render 'meal_edit'
        ), name:'meal_edit'

    Template.meal_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.meal_edit.onRendered ->


    Template.meal_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id
        
        'click .new_meal_plan': ->
            new_id = 
                Docs.insert 
                    model:'meal_plan'
            Router.go "/m/meal_plan/#{new_id}/edit"

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_meal', @_id, =>
                    Router.go "/meal/#{@_id}/view"


    Template.meal_edit.helpers
    Template.meal_edit.events
