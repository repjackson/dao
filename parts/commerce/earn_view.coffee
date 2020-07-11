if Meteor.isClient
    Router.route '/earn/:doc_id/view', (->
        @layout 'layout'
        @render 'earn_view'
        ), name:'earn_view'

    Template.earn_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
