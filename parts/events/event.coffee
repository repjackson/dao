if Meteor.isClient
    Router.route '/event/:doc_id/view', (->
        @layout 'layout'
        @render 'event_view'
        ), name:'event_view'
        
    Router.route '/events', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'
        
        
        
        
    # Router.route '/e/:doc_slug/', (->
    #     @layout 'layout'
    #     @render 'event_view'
    #     ), name:'event_view_by_slug'
        
    # Template.registerHelper 'current_event', () ->
    #     if Router.current().params.doc_id
    #         Docs.findOne
    #             _id:Router.current().params.doc_id
    #     else
    #         Docs.findOne
    #             model:'event'
    #             slug:Router.current().params.doc_slug
            
    Template.registerHelper 'going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.going_user_ids
    Template.registerHelper 'maybe_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.maybe_user_ids
    Template.registerHelper 'not_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.not_user_ids

    Template.registerHelper 'event_tickets', () ->
        Docs.find 
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id: Router.current().params.doc_id

        
    Template.events.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'event'
        
    Template.events.events
        'click .add_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
                    published:false
            Router.go "/event/#{new_id}/edit"
            
            
    Template.events.helpers
        events: ->
            # console.log moment().format()
            Docs.find {
                model:'event'
                published:true
                start_datetime:$lt:moment().format()
            }, 
                sort:start_datetime:-1
    
    
    
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




    
    Template.attendance.events
        'click .pick_maybe': ->
            event = Docs.findOne Router.current().params.doc_id
            Swal.fire({
                title: "mark yourself as maybe?"
                text: "for #{event.title}"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                confirmButtonColor: 'green'
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
                confirmButtonColor: 'green'
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

    Template.event_view.events

if Meteor.isServer
    Meteor.publish 'event_tickets', (event_id)->
        Docs.find
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id:event_id
            
    # Meteor.publish 'doc_by_slug', (slug)->
    #     Docs.find
    #         slug:slug
            
    # Meteor.publish 'author_by_doc_id', (doc_id)->
    #     doc_by_id =
    #         Docs.findOne doc_id
    #     doc_by_slug =
    #         Docs.findOne slug:doc_id
    #     if doc_by_id
    #         Meteor.users.findOne 
    #             _id:doc_by_id._author_id
    #     else
    #         Meteor.users.findOne 
    #             _id:doc_by_slug._author_id
            
            
    # Meteor.publish 'author_by_doc_slug', (slug)->
    #     doc = 
    #         Docs.findOne
    #             slug:slug
    #     Meteor.users.findOne 
    #         _id:doc._author_id


#     Meteor.methods
        # send_event: (event_id)->
        #     event = Docs.findOne event_id
        #     target = Meteor.users.findOne event.recipient_id
        #     gifter = Meteor.users.findOne event._author_id
        #
        #     console.log 'sending event', event
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: event.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -event.amount
        #     Docs.update event_id,
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
    Router.route '/event/:doc_id/edit', (->
        @layout 'layout'
        @render 'event_edit'
        ), name:'event_edit'

    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.event_edit.onRendered ->


    Template.event_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_event', @_id, =>
                    Router.go "/event/#{@_id}/view"


    Template.event_edit.helpers
    Template.event_edit.events

if Meteor.isServer
    Meteor.methods
        send_event: (event_id)->
            event = Docs.findOne event_id
            target = Meteor.users.findOne event.recipient_id
            gifter = Meteor.users.findOne event._author_id

            console.log 'sending event', event
            Meteor.users.update target._id,
                $inc:
                    points: event.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -event.amount
            Docs.update event_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
