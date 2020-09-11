if Meteor.isClient
    # Router.route '/e/:doc_slug/', (->
    #     @layout 'layout'
    #     @render 'event_view'
    #     ), name:'event_view_by_slug'
        
    Template.registerHelper 'facilitator', () ->    
        Meteor.users.findOne @facilitator_id
    Template.registerHelper 'fac', () ->    
        Meteor.users.findOne @facilitator_id
   
    Template.registerHelper 'my_ticket', () ->    
        event = Docs.findOne @_id
        Docs.findOne
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id:@_id
            _author_id:Meteor.userId()
   
    Template.registerHelper 'event_room', () ->
        event = Docs.findOne @_id
        Docs.findOne 
            _id:event.room_id

    Template.registerHelper 'going', () ->
        event = Docs.findOne @_id
        event_tickets = 
            Docs.find(
                model:'transaction'
                transaction_type:'ticket_purchase'
                event_id: @_id
                ).fetch()
        going_user_ids = []
        for ticket in event_tickets
            going_user_ids.push ticket._author_id
        Meteor.users.find 
            _id:$in:going_user_ids
            
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

        
    

if Meteor.isServer
    Meteor.publish 'future_events', ()->
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find {
            model:'event'
            published:true
            date:$gt:moment().subtract(1,'days').format("YYYY-MM-DD")
        }, 
            sort:date:1
    
    Meteor.publish 'events', (
        viewing_room_id
        viewing_past
        viewing_published
        )->
            
        match = {model:'event'}
        if viewing_room_id
            match.room_id = viewing_room_id
        if viewing_past
            match.date = $gt:moment().subtract(1,'days').format("YYYY-MM-DD")
            
        match.published = viewing_published    
            
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find match, 
            sort:date:1
    

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


