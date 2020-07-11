if Meteor.isClient
    Router.route '/earn/:doc_id/edit', (->
        @layout 'layout'
        @render 'earn_edit'
        ), name:'earn_edit'

    Template.earn_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.earn_edit.onRendered ->
    Template.earn_edit.events
    Template.earn_edit.helpers
