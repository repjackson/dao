if Meteor.isClient
    # Router.route '/debits/', (->
    #     @layout 'layout'
    #     @render 'debits'
    #     ), name:'debits'
    

    Template.expense_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'finance_stat'
        
    Template.expense_stats.helpers
        fs: ->
            Docs.findOne model:'finance_stat'
    Template.expense_stats.events
        'click .recalc_finance_stats': ->
            Meteor.call 'calc_finance_stats', ->
                



if Meteor.isServer
    Meteor.publish 'product_from_debit_id', (debit_id)->
        debit = Docs.findOne debit_id
        Docs.find 
            _id:debit.product_id
            
    Meteor.methods
        calc_finance_stats: ()->
            fs = Docs.findOne model:'finance_stat'
            unless fs 
                Docs.insert 
                    model:'finance_stat'
            fs = Docs.findOne model:'finance_stat'
            
            total_expense_sum = 0
            
            expenses = 
                Docs.find 
                    model:'expense'
            for expense in expenses.fetch()
                total_expense_sum += expense.dollar_amount
        
            total_membership_sum = 0
            memberships = 
                Docs.find 
                    model:'expense'
                    membership:true
            for membership in memberships.fetch()
                total_membership_sum += membership.dollar_amount
        
            console.log 'total expenses', total_expense_sum
            Docs.update fs._id,
                $set:
                    total_expense_sum:total_expense_sum
                    total_expense_count:expenses.count()
                    membership_count:memberships.count()
                    total_membership_sum:total_membership_sum