if Meteor.isClient
    Router.route '/offers', (->
        @layout 'layout'
        @render 'offers'
        ), name:'offers'

    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    Template.offers.onCreated ->
        @autorun => Meteor.subscribe 'offers',
            selected_tags.array()
    
    Template.offers.events
        'click .add_offer': ->
            new_id = 
                Docs.insert 
                    model:'offer'
            Router.go "/m/offer/#{new_id}/edit"
            
    Template.offers.helpers
        offers: ->
            Docs.find {
                model:'offer'
                },
                    sort:_timestamp:-1
                # complete:$ne:true
                # published:true

    Template.offer_item.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id

    Template.offer_item.events
        'click .offer_item': ->
            Router.go "/m/offer/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1


    Template.offer_view.onCreated ->
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

            if Meteor.user().credit > @credit_price
                Swal.fire({
                    title: "buy #{@title}?"
                    text: "this will charge you #{@credit_price} credits"
                    icon: 'question'
                    showCancelButton: true
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
                        Docs.insert
                            model:'order'
                            offer_id: Router.current().params.doc_id
                            purchase_price:@credit_price
                        Swal.fire(
                            'credit transfered',
                            ''
                            'success'
                        )
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



if Meteor.isServer
    Meteor.publish 'offers', (selected_tags)->
        
        match = {model:'offer'}
        if selected_tags.length > 0
            match.tags = $in:selected_tags
        Docs.find match
#     Meteor.methods
        # send_offer: (offer_id)->
        #     offer = Docs.findOne offer_id
        #     target = Meteor.users.findOne offer.recipient_id
        #     gifter = Meteor.users.findOne offer._author_id
        #
        #     console.log 'sending offer', offer
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: offer.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -offer.amount
        #     Docs.update offer_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Template.offer_edit.onRendered ->


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
                    Router.go "/m/offer"
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
                    
                    
                    
                    