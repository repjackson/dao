if Meteor.isClient
    Router.route '/add', (->
        @layout 'layout'
        @render 'add'
        ), name:'add'

    Template.add.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.add.onRendered ->


    Template.add.events
        'click .add_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
            Router.go "/event/#{new_id}/edit"
            
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_event', @_id, =>
                    Router.go "/event/#{@_id}/view"


    Template.add.helpers
    Template.add.events
