if Meteor.isClient
    Router.route '/meal/:doc_id/view', (->
        @layout 'layout'
        @render 'meal_view'
        ), name:'meal_view'

    Template.meal_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

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


    Template.meal_view.helpers
    Template.meal_view.events
    Template.meal_view.onCreated ->
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
                Meteor.call 'buy_meal', charge, (err,res)=>
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

    Template.meal_view.onRendered ->

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


            Swal.fire({
                title: "buy #{@title}?"
                text: "this will charge you $#{@dollar_price}"
                icon: 'question'
                showCancelButton: true,
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
            meal_transactions: ->
                Docs.find
                    model:'transaction'
                    transaction_type:'shop_purchase'
                    meal_id: Router.current().params.doc_id



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


if Meteor.isClient
    Router.route '/meal/:doc_id/edit', (->
        @layout 'layout'
        @render 'meal_edit'
        ), name:'meal_edit'

    Template.meal_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.meal_edit.onRendered ->


    Template.meal_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_meal', @_id, =>
                    Router.go "/meal/#{@_id}/view"


    Template.meal_edit.helpers
    Template.meal_edit.events

if Meteor.isServer
    Meteor.methods
        send_meal: (meal_id)->
            meal = Docs.findOne meal_id
            target = Meteor.users.findOne meal.recipient_id
            gifter = Meteor.users.findOne meal._author_id

            console.log 'sending meal', meal
            Meteor.users.update target._id,
                $inc:
                    points: meal.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -meal.amount
            Docs.update meal_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
