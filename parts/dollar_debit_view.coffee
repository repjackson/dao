if Meteor.isClient
    Router.route '/dollar_debits/', (->
        @layout 'layout'
        @render 'dollar_debits'
        ), name:'dollar_debits'
    

    Router.route '/dollar_debit/:doc_id/view', (->
        @layout 'layout'
        @render 'dollar_debit_view'
        ), name:'dollar_debit_view'

    Template.dollar_debit_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_dollar_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.dollar_debit_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'product_from_dollar_debit_id', (dollar_debit_id)->
        dollar_debit = Docs.findOne dollar_debit_id
        Docs.find 
            _id:dollar_debit.product_id