if Meteor.isClient
    Router.route '/rental/:doc_id/view', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'rental_tickets', Router.current().params.doc_id
        
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
                rental = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: rental.usd_price*100
                    rental_id:rental._id
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    rental_title:rental.title
                    # receipt_email: token.email
                Meteor.call 'buy_ticket', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'ticket purchased',
                            ''
                            'success'
                        # Meteor.users.update Meteor.userId(),
                        #     $inc: points:500
                        )
        )

    Template.rental_view.onRendered ->
        Docs.update Router.current().params.doc_id, 
            $inc: views: 1

    Template.rental_view.helpers 
        can_buy: ->
            now = Date.now()
            

    Template.rental_view.events
        'click .buy_for_points': ->
            Swal.fire({
                title: "buy ticket for #{@point_price}pts?"
                text: "#{@title}"
                icon: 'question'
                confirmButtonText: 'purchase'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.insert 
                        model:'transaction'
                        transaction_type:'ticket_purchase'
                        payment_type:'points'
                        is_points:true
                        point_amount:@point_price
                        rental_id:@_id
                    Meteor.users.update Meteor.userId(),
                        $inc:points:-@point_price
                    Meteor.users.update @_author_id, 
                        $inc:points:@point_price
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'ticket purchased',
                        showConfirmButton: false,
                        timer: 1500
                    )
            )
    
        'click .buy_for_usd': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'rental purchase'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: "buy ticket for $#{@usd_price}?"
                text: "for: #{@title}"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'purchase'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: @title
                        # email:Meteor.user().emails[0].address
                        description: 'ticket purchase'
                        amount: @usd_price*100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )




    Template.rental_view.onRendered ->
    Template.rental_card.events
        'click .pick_going': ->
            console.log 'going'
            Docs.update @data._id,
                $addToSet:
                    going_user_ids: Meteor.userId()
                $pull:
                    maybe_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_maybe': ->
            console.log 'maybe', Template.parent
            Docs.update @data._id,
                $addToSet:
                    maybe_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_not': ->
            Docs.update @data._id,
                $addToSet:
                    not_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    maybe_user_ids: Meteor.userId()
    
    Template.rental_view.events
        'click .pick_going': ->
            console.log 'going'
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    going_user_ids: Meteor.userId()
                $pull:
                    maybe_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_maybe': ->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    maybe_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_not': ->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    not_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    maybe_user_ids: Meteor.userId()
    
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_rental', @_id, =>
                    Router.go "/rental/#{@_id}/view"


    Template.rental_card.helpers
        going: ->
            rental = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:rental.going_user_ids
        maybe_going: ->
            rental = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:rental.maybe_user_ids
        not_going: ->
            rental = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:rental.not_user_ids
    Template.rental_view.helpers
        tickets_left: ->
            ticket_count = 
                Docs.find({ 
                    model:'transaction'
                    transaction_type:'ticket_purchase'
                    rental_id: Router.current().params.doc_id
                }).count()
            @max_attendees-ticket_count
        tickets: ->
            Docs.find 
                model:'transaction'
                transaction_type:'ticket_purchase'
                rental_id: Router.current().params.doc_id
        going: ->
            rental = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:rental.going_user_ids
        maybe_going: ->
            rental = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:rental.maybe_user_ids
        not_going: ->
            rental = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:rental.not_user_ids
    Template.rental_view.rentals

if Meteor.isServer
    Meteor.publish 'rental_tickets', (rental_id)->
        Docs.find
            model:'transaction'
            transaction_type:'ticket_purchase'
            rental_id:rental_id
#     Meteor.methods
        # send_rental: (rental_id)->
        #     rental = Docs.findOne rental_id
        #     target = Meteor.users.findOne rental.recipient_id
        #     gifter = Meteor.users.findOne rental._author_id
        #
        #     console.log 'sending rental', rental
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: rental.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -rental.amount
        #     Docs.update rental_id,
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
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'

    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_edit.onRendered ->


    Template.rental_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_rental', @_id, =>
                    Router.go "/rental/#{@_id}/view"


    Template.rental_edit.helpers

if Meteor.isServer
    Meteor.methods
        send_rental: (rental_id)->
            rental = Docs.findOne rental_id
            target = Meteor.users.findOne rental.recipient_id
            gifter = Meteor.users.findOne rental._author_id

            console.log 'sending rental', rental
            Meteor.users.update target._id,
                $inc:
                    points: rental.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -rental.amount
            Docs.update rental_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
