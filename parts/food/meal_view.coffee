if Meteor.isClient
    Template.meal_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'mealorder'
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
                meal = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: meal.dollar_price*100
                    meal_id:meal._id
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    meal_title:meal.title
                    # receipt_email: token.email
                Meteor.call 'buy_meal', charge, Router.current().params.doc_id, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'meal purchased',
                            ''
                            'success'
                        # Meteor.users.update Meteor.userId(),
                        #     $inc: points:500
                        )
        )
        
    Template.registerHelper 'mealorder_meal', () ->
        Docs.findOne @meal_id
    
        

    Template.meal_view.events
        'click .delete_meal': ->
            if confirm 'delete meal?'
                Docs.remove @_id

        'click .submit': ->
            # if confirm 'confirm?'
                # Meteor.call 'send_meal', @_id, =>
                #     Router.go "/meal/#{@_id}/view"

        'click .buy': ->
            if confirm "buy for #{@point_price} points?"
                Docs.insert 
                    model:'transaction'
                    transaction_type:'shop_purchase'
                    payment_type:'points'
                    is_points:true
                    point_amount:@point_price
                    meal_id:@_id
                Meteor.users.update Meteor.userId(),
                    $inc:points:-@point_price
                Meteor.users.update @_author_id, 
                    $inc:points:@point_price



    Template.meal_view.events
        'click .buy_for_usd': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'meal purchase'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()

            if Meteor.user().credit > @dollar_price
                Swal.fire({
                    title: "buy #{@title}?"
                    text: "this will charge you #{@dollar_price} credits"
                    icon: 'question'
                    showCancelButton: true
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result)=>
                    if result.value
                        # Session.set('topup_amount',5)
                        # Template.instance().checkout.open
                        Docs.insert 
                            model:'dollar_transaction'
                            product_id: Router.current().params.doc_id
                            dollar_amount: @dollar_price
                            target_user_id:@chef_id
                        Docs.insert
                            model:'mealorder'
                            meal_id: Router.current().params.doc_id
                            transaction_type:'1 tiffen'
                            dollar_amount:@dollar_price
                        Swal.fire(
                            'credit transfered',
                            ''
                            'success'
                        )
                )
            else
                Swal.fire({
                    title: "buy #{@title}?"
                    text: "this will charge you $#{@dollar_price}"
                    icon: 'question'
                    showCancelButton: true
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result)=>
                    if result.value
                        # Session.set('topup_amount',5)
                        # Template.instance().checkout.open
                        instance.checkout.open
                            name: @title
                            # email:Meteor.user().emails[0].address
                            description: 'meal purchase'
                            amount: @dollar_price*100
                
                        # Meteor.users.update @_author_id,
                        #     $inc:credit:@order_price
                        # Swal.fire(
                        #     'topup initiated',
                        #     ''
                        #     'success'
                        # )
                )

    Template.meal_view.helpers 
        mealorders: ->
            Docs.find
                model:'mealorder'



# if Meteor.isServer
#     Meteor.methods
        # send_meal: (meal_id)->
        #     meal = Docs.findOne meal_id
        #     target = Meteor.users.findOne meal.recipient_id
        #     gifter = Meteor.users.findOne meal._author_id
        #
        #     console.log 'sending meal', meal
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: meal.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -meal.amount
        #     Docs.update meal_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


