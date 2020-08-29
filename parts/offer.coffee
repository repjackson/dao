if Meteor.isClient
    Router.route '/offer/:doc_id/view', (->
        @layout 'layout'
        @render 'offer_view'
        ), name:'offer_view'
    Router.route '/offer/:doc_id/edit', (->
        @layout 'layout'
        @render 'offer_edit'
        ), name:'offer_edit'

    Template.registerHelper 'sale_credit_price', () ->
        @credit_price + @credit_price/100
    


    Template.offer_view.onCreated ->
        @autorun -> Meteor.subscribe 'offer_orders', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/black_diamond.png'
            locale: 'auto'
            zipCode: true
            token: (token) =>
                # amount = parseInt(Session.get('topup_amount'))
                offer = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: offer.credit_price*100
                    offer_id:offer._id
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    offer_title:offer.title
                    # receipt_email: token.email
                Meteor.call 'buy_offer', charge, Router.current().params.doc_id, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'offer purchased',
                            ''
                            'success'
                        # Meteor.users.update Meteor.userId(),
                        #     $inc: points:500
                        )
        )


    Template.offer_view.events
        'click .buy': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'offer purchase'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()
            sale_credit_price = @credit_price + @credit_price/100

            if Meteor.user().points > @credit_price*100
                Swal.fire({
                    title: "buy #{@title}?"
                    text: "this will charge you #{sale_credit_price} credits"
                    icon: 'question'
                    showCancelButton: true
                    reverseButtons: true
                    confirmButtonColor: 'green'
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result)=>
                    if result.value
                        # Session.set('topup_amount',5)
                        # Template.instance().checkout.open
                        # Docs.insert 
                        #     model:'dollar_transaction'
                        #     product_id: Router.current().params.doc_id
                        #     dollar_amount: @credit_price
                        #     target_user_id:@chef_id
                        new_order_id = 
                            Docs.insert
                                model:'order'
                                title:@title
                                image_id:@image_id
                                
                                description:@description
                                seller_username:@_author_username
                                offer_id: Router.current().params.doc_id
                                price:@credit_price
                                tax:@credit_price/100
                                total_price:sale_credit_price
                        Docs.update @_id,
                            $inc:inventory:-1
                        Swal.fire(
                            position: 'top-end',
                            icon: 'success',
                            title: "#{@title} purchased",
                            showConfirmButton: false,
                            timer: 1000
                        )
                        Router.go "/order/#{new_order_id}/view"
                )
            else
                Swal.fire({
                    title: "buy #{@title}?"
                    text: "this will charge you $#{@credit_price}"
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
                            description: 'offer purchase'
                            amount: @credit_price*100
                
                        # Meteor.users.update @_author_id,
                        #     $inc:credit:@order_price
                        # Swal.fire(
                        #     'topup initiated',
                        #     ''
                        #     'success'
                        # )
                )
            
                            
        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: false
                    completed_by_user_id: null
                    status:'claimed'
                    completed_timestamp:null
            Meteor.users.update @claimed_user_id,
                $inc:points:-@point_bounty
                            

    Template.offer_view.helpers
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true
        orders: ->
            Docs.find 
                model:'order'
                offer_id: @_id




if Meteor.isServer
    Meteor.publish 'offer_orders', (offer_id)->
        Docs.find   
            model:'order'
            offer_id:offer_id
    
    
    Meteor.publish 'offers', (
        query=''
        selected_tags
        )->
        match = {model:'offer'}
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}

        if selected_tags.length > 0
            match.tags = $in:selected_tags
        Docs.find match

if Meteor.isClient
    Template.offer_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.offer_edit.events
        'click .delete_offer': ->
            Swal.fire({
                title: "delete offer?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'offer removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/offers"
            )




    Template.offer_edit.helpers
    Template.offer_edit.events

if Meteor.isServer
    Meteor.methods
        publish_offer: (offer_id)->
            offer = Docs.findOne offer_id
            # target = Meteor.users.findOne offer.recipient_id
            author = Meteor.users.findOne offer._author_id

            console.log 'publishing offer', offer
            Meteor.users.update author._id,
                $inc:
                    points: -offer.point_bounty
            Docs.update offer_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
                    
                    