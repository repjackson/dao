if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    
    Router.route '/settings', (->
        @layout 'layout'
        @render 'settings'
        ), name:'settings'

    Template.settings.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
   
    Template.settings.onRendered ->


    Template.settings.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_project', @_id, =>
                    Router.go "/project/#{@_id}/view"

