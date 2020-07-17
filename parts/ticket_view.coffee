if Meteor.isClient
    Router.route '/tickets/', (->
        @layout 'layout'
        @render 'tickets'
        ), name:'tickets'
    

    Router.route '/ticket/:doc_id/view', (->
        @layout 'layout'
        @render 'ticket_view'
        ), name:'ticket_view'

    Template.ticket_view.onCreated ->
        @autorun => Meteor.subscribe 'event_from_ticket_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.ticket_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'event_from_ticket_id', (ticket_id)->
        ticket = Docs.findOne ticket_id
        Docs.find 
            _id:ticket.event_id