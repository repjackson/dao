if Meteor.isClient
    Router.route '/user/:username/edit/delivery', (->
        @layout 'user_edit_layout'
        @render 'user_edit_delivery'
        ), name:'user_edit_delivery'


    Template.user_edit_delivery.onCreated ->
        @autorun => Meteor.subscribe 'user_delivery_orders'
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_delivery.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_delivery.helpers
        delivery_orders: ->
            Docs.find
                model:'delivery_order'


    Template.user_edit_delivery.onCreated ->
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
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: 1100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'buy_delivery', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'delivery purchased',
                            ''
                            'success'
                        # Docs.insert
                        #     model:'transaction'
                        #     transaction_type:'delivery'
                        #     amount:1100
                        )
        )

    Template.user_edit_delivery.onRendered ->

    Template.user_edit_delivery.events
        'click .buy_ethel_tiffen': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside delivery'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy Ethel delivery?'
                text: "this will charge you $11"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'buy Ethel Tiffen'
                        # email:Meteor.user().emails[0].address
                        description: 'monthly'
                        amount: 1100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )
            
        'click .buy_nicole_tiffen': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside delivery'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy delivery?'
                text: "this will charge you $11"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'Nicole Tiffen'
                        # email:Meteor.user().emails[0].address
                        description: ''
                        amount: 1100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )


    Template.delivery.events
        'click submit_order': ->
            console.log 'hi'
            if confirm 'submit?'
                Docs.update @_id, 
                    $set:submitted:true


if Meteor.isServer
    Meteor.publish 'user_delivery_orders', (username)->
        Docs.find
            model:'delivery_order'
            _author_id: Meteor.userId()
