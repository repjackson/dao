if Meteor.isClient
    Router.route '/item/:doc_id/view', (->
        @layout 'layout'
        @render 'gift_view'
        ), name:'gift_view'
    Template.gift_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
