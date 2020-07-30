if Meteor.isClient
    Router.route '/debits/', (->
        @layout 'layout'
        @render 'debits'
        ), name:'debits'
    

    Router.route '/debit/:doc_id/view', (->
        @layout 'layout'
        @render 'debit_view'
        ), name:'debit_view'

    Template.debit_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.debit_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'product_from_debit_id', (debit_id)->
        debit = Docs.findOne debit_id
        Docs.find 
            _id:debit.product_id