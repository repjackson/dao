if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_by_slug', Router.current().params.doc_slug
        @autorun => Meteor.subscribe 'author_by_doc_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'author_by_doc_slug', Router.current().params.doc_slug

    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'event_tickets', Router.current().params.doc_id
        
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
                event = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: event.usd_price*100
                    event_id:event._id
                    currency: 'usd'
                    source: token.id
                    input:'number'
                    # description: token.description
                    description: "One Becomeing One"
                    event_title:event.title
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
    
    Template.event_view.onRendered ->
        Docs.update Router.current().params.doc_id, 
            $inc: views: 1

    Template.event_view.helpers 
        can_buy: ->
            now = Date.now()
            

    Template.event_view.events
        'click .buy_for_points': ->
            # $('.ui.modal').modal('show')
            Swal.fire({
                title: "buy ticket for #{@point_price}pts?"
                text: "#{@title}"
                icon: 'question'
                input:'number'
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
                        event_id:@_id
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
            #     name: 'event purchase'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: "buy ticket for $#{@usd_price} or more!"
                text: "for: #{@title}"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'purchase'
                input:'number'
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




    
    Template.attendance.events
        'click .pick_maybe': ->
            event = Docs.findOne Router.current().params.doc_id
            Swal.fire({
                title: "mark yourself as maybe?"
                text: "for #{event.title}"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                confirmButtonColor: 'orange'
                # grow:'fullscreen'
                showClass:
                    popup: 'swal2-noanimation',
                    backdrop: 'swal2-noanimation'
                hideClass:
                    popup: '',
                    backdrop: ''
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.update Router.current().params.doc_id,
                        $addToSet:
                            maybe_user_ids: Meteor.userId()
                        $pull:
                            going_user_ids: Meteor.userId()
                            not_user_ids: Meteor.userId()
            )
    
        'click .pick_not': ->
            event = Docs.findOne Router.current().params.doc_id

            Swal.fire({
                title: "mark yourself as no?"
                text: "for #{event.title}"
                icon: 'error'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.update Router.current().params.doc_id,
                        $addToSet:
                            not_user_ids: Meteor.userId()
                        $pull:
                            going_user_ids: Meteor.userId()
                            maybe_user_ids: Meteor.userId()
            )


    Template.event_card.helpers
    Template.event_view.helpers
        tickets_left: ->
            ticket_count = 
                Docs.find({ 
                    model:'transaction'
                    transaction_type:'ticket_purchase'
                    event_id: Router.current().params.doc_id
                }).count()
            @max_attendees-ticket_count

    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'room'
    Template.event_edit.helpers
        rooms: ->
            Docs.find   
                model:'room'


if Meteor.isServer
    Meteor.publish 'event_tickets', (event_id)->
        Docs.find
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id:event_id
