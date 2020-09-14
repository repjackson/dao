if Meteor.isClient
    Template.debit_edit.onCreated ->
        @autorun => Meteor.subscribe 'seller_from_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        
    Template.debit_edit.onRendered ->

    Router.route '/debit/:doc_id/edit', (->
        @layout 'layout'
        @render 'debit_edit'
        ), name:'debit_edit'
        
    Router.route '/debit/:doc_id/view', (->
        @layout 'layout'
        @render 'debit_view'
        ), name:'debit_view'
        

    Template.debit_edit.helpers
        point_max: ->
            Meteor.user().points
        
        can_submit: ->
            debit = Docs.findOne Router.current().params.doc_id
            debit.price and debit.seller_id
    Template.debit_edit.events
        'blur .point_price': (e,t)->
            # console.log @
            val = parseInt t.$('.point_price').val()
            Docs.update Router.current().params.doc_id,
                $set:price:val


        'click .cancel_debit': ->
            Swal.fire({
                title: "confirm cancel?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'red'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Router.go '/'
            )
            
        'click .submit': ->
            # Swal.fire({
            #     title: "confirm send #{@price}pts?"
            #     text: ""
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonColor: 'green'
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            #     reverseButtons: true
            # }).then((result)=>
            #     if result.value
            Meteor.call 'send_debit', @_id, =>
                # Swal.fire(
                #     title:"#{@price} sent"
                #     icon:'success'
                #     showConfirmButton: false
                #     position: 'top-end',
                #     timer: 1000
                # )
                Meteor.call 'calc_user_stats', @seller_id, ->
                Meteor.call 'calc_user_stats', @buyer_id, ->

                Router.go "/debit/#{@_id}/view"
            # )


    Template.debit_edit.helpers
    Template.debit_edit.events

if Meteor.isServer
    Meteor.methods
        send_debit: (debit_id)->
            debit = Docs.findOne debit_id
            seller = Meteor.users.findOne debit.seller_id
            debiter = Meteor.users.findOne debit._author_id

            console.log 'sending debit', debit
            Meteor.call 'calc_one_stats', seller._id, ->
            Meteor.call 'calc_one_stats', debit._author_id, ->
    
            Docs.update debit_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
                    status:'complete'
                    
            return
            
            
            
if Meteor.isClient
    Template.debit_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
                    