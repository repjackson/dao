if Meteor.isClient
    Router.route '/dollar_debit/:doc_id/edit', (->
        @layout 'layout'
        @render 'dollar_debit_edit'
        ), name:'dollar_debit_edit'
        
        
    Template.dollar_debit_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_dollar_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) =>
                # amount = parseInt(Session.get('topup_amount'))
                dollar_debit = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: dollar_debit.dollar_amount*100
                    currency: 'usd'
                    source: token.id
                    # description: token.description
                    description: "One Becoming One"
                    # receipt_email: token.email
                Meteor.call 'send_tip', charge, Router.current().params.doc_id,(err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'tip sent',
                            ''
                            'success'
                        )
                        Router.go "/m/dollar_debit/#{dollar_debit._id}/view"
        )
        
    Template.dollar_debit_edit.onRendered ->


    Template.dollar_debit_edit.helpers
        recipient: ->
            dollar_debit = Docs.findOne Router.current().params.doc_id
            if dollar_debit.recipient_id
                Meteor.users.findOne
                    _id: dollar_debit.recipient_id
        members: ->
            dollar_debit = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
                username: $ne: Meteor.userId()
            }, {
                sort:dollars:-1
                })
        # subtotal: ->
        #     dollar_debit = Docs.findOne Router.current().params.doc_id
        #     dollar_debit.amount*dollar_debit.recipient_ids.length
        
        dollar_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().dollars
        
        can_submit: ->
            dollar_debit = Docs.findOne Router.current().params.doc_id
            dollar_debit.dollar_amount and dollar_debit.recipient_id
    Template.dollar_debit_edit.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    recipient_id:1
        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                t.$('.new_element').val('')
    
        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_element').focus()
            t.$('.new_element').val(element)
    
    
        # 'click .result': (e,t)->
        #     Meteor.call 'log_term', @title, ->
        #     selected_tags.push @title
        #     $('#search').val('')
        #     Meteor.call 'call_wiki', @title, ->
        #     Meteor.call 'calc_term', @title, ->
        #     Meteor.call 'omega', @title, ->
        #     Session.set('current_query', '')
        #     Session.set('searching', false)
    
        #     Meteor.call 'search_reddit', selected_tags.array(), ->
        #     # Meteor.setTimeout ->
        #     #     Session.set('dummy', !Session.get('dummy'))
        #     # , 7000

    
        'blur .edit_description': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            Docs.update Router.current().params.doc_id,
                $set:description:textarea_val
    
    
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            Docs.update Router.current().params.doc_id,
                $set:"#{@key}":val
    
    
        'blur .dollar_amount': (e,t)->
            # console.log @
            val = parseInt t.$('.dollar_amount').val()
            Docs.update Router.current().params.doc_id,
                $set:amount:val



        'click .cancel_dollar_debit': ->
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
            
        'click .submit': (e,t)->
            console.log Template.instance()
            dollar_debit = Docs.findOne Router.current().params.doc_id            
            instance = Template.instance()

            Swal.fire({
                # title: "buy ticket for $#{@usd_price} or more!"
                title: "send $#{dollar_debit.dollar_amount}?"
                text: "to #{dollar_debit.recipient().name()}"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    console.log @
                    instance.checkout.open
                        name: 'One Boulder One'
                        # email:Meteor.user().emails[0].address
                        description: "tip from #{@_author().name()} to #{@recipient().name()}"
                        # description: "tip from }"
                        amount: @dollar_amount*100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )


    Template.dollar_debit_edit.helpers
    Template.dollar_debit_edit.events

if Meteor.isServer
    Meteor.methods
        send_dollar_debit: (dollar_debit_id)->
            dollar_debit = Docs.findOne dollar_debit_id
            recipient = Meteor.users.findOne dollar_debit.recipient_id
            dollar_debiter = Meteor.users.findOne dollar_debit._author_id

            console.log 'sending dollar_debit', dollar_debit
            Meteor.users.update recipient._id,
                $inc:
                    dollars: dollar_debit.amount
            Meteor.users.update dollar_debiter._id,
                $inc:
                    dollars: -dollar_debit.amount
            Docs.update dollar_debit_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update dollar_debit_id,
                $set:
                    submitted:true
