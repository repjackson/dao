if Meteor.isClient
    Router.route '/gift/:doc_id/edit', (->
        @layout 'layout'
        @render 'gift_edit'
        ), name:'gift_edit'

    Template.gift_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.gift_edit.onRendered ->
    Template.gift_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

    Template.gift_edit.helpers
    Template.gift_edit.events
