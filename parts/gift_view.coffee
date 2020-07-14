if Meteor.isClient
    Router.route '/gift/:doc_id/view', (->
        @layout 'layout'
        @render 'gift_view'
        ), name:'gift_view'

    Template.gift_view.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_gift_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.gift_view.onRendered ->


