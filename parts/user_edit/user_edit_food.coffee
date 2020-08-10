if Meteor.isClient
    Router.route '/user/:username/edit/food', (->
        @layout 'user_edit_layout'
        @render 'user_edit_food'
        ), name:'user_edit_food'


    Template.user_edit_food.onCreated ->
        @autorun => Meteor.subscribe 'user_food_orders'
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_food.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_food.helpers
        food_orders: ->
            Docs.find
                model:'food_order'


    Template.user_edit_food.onCreated ->
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
                    amount: 11
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'buy_food', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'food purchased',
                            ''
                            'success'
                        # Docs.insert
                        #     model:'transaction'
                        #     transaction_type:'food'
                        #     amount:1100
                        )
        )

    Template.user_edit_food.onRendered ->

    Template.user_edit_food.events
        'click .buy_ethel_tiffen': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside food'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy Ethel food?'
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
            #     name: 'Riverside food'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy food?'
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

if Meteor.isServer
    Meteor.publish 'user_food_orders', (username)->
        
        Docs.find
            model:'food_order'
            _author_id: Meteor.userId()
