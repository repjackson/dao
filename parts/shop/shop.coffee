if Meteor.isClient
    Router.route '/product/:doc_id/view', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'

    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.product_view.events
        'click .delete_product': ->
            if confirm 'delete product?'
                Docs.remove @_id

        'click .submit': ->
            # if confirm 'confirm?'
                # Meteor.call 'send_product', @_id, =>
                #     Router.go "/product/#{@_id}/view"

        'click .buy': ->
            if confirm "buy for #{@point_price} points?"
                Docs.insert 
                    model:'transaction'
                    transaction_type:'shop_purchase'
                    payment_type:'points'
                    is_points:true
                    point_amount:@point_price
                    product_id:@_id
                Meteor.users.update Meteor.userId(),
                    $inc:points:-@point_price
                Meteor.users.update @_author_id, 
                    $inc:points:@point_price


    Template.product_view.helpers
    Template.product_view.events
    Template.product_view.onCreated ->
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
                product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: product.usd_price*100
                    product_id:product._id
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    product_title:product.title
                    # receipt_email: token.email
                Meteor.call 'buy_product', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'product purchased',
                            ''
                            'success'
                        # Meteor.users.update Meteor.userId(),
                        #     $inc: points:500
                        )
        )

    Template.product_view.onRendered ->

    Template.product_view.events
        'click .buy_for_usd': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'product purchase'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: "buy #{@title}?"
                text: "this will charge you $#{@usd_price}"
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
                        description: 'product purchase'
                        amount: @usd_price*100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )

        Template.product_view.helpers 
            product_transactions: ->
                Docs.find
                    model:'transaction'
                    transaction_type:'shop_purchase'
                    product_id: Router.current().params.doc_id



# if Meteor.isServer
#     Meteor.methods
        # send_product: (product_id)->
        #     product = Docs.findOne product_id
        #     target = Meteor.users.findOne product.recipient_id
        #     gifter = Meteor.users.findOne product._author_id
        #
        #     console.log 'sending product', product
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: product.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -product.amount
        #     Docs.update product_id,
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
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'

    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.product_edit.onRendered ->


    Template.product_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_product', @_id, =>
                    Router.go "/product/#{@_id}/view"


    Template.product_edit.helpers
    Template.product_edit.events

if Meteor.isServer
    Meteor.methods
        send_product: (product_id)->
            product = Docs.findOne product_id
            target = Meteor.users.findOne product.recipient_id
            gifter = Meteor.users.findOne product._author_id

            console.log 'sending product', product
            Meteor.users.update target._id,
                $inc:
                    points: product.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -product.amount
            Docs.update product_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
