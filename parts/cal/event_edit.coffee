if Meteor.isClient
    Router.route '/event/:doc_id/edit', (->
        @layout 'layout'
        @render 'event_edit'
        ), name:'event_edit'

    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'reservation'
    Template.event_edit.onRendered ->


    Template.event_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .select_room': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    room_id:@_id
                    room_title:@title

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_event', @_id, =>
                    Router.go "/event/#{@_id}/view"


    Template.event_edit.helpers
        room_button_class: ->
            event = Docs.findOne Router.current().params.doc_id
            if event.room_id is @_id
                'blue inverted'
            else 
                'basic'
    
        room_reservations: ->
            event = Docs.findOne Router.current().params.doc_id
            room = Docs.findOne _id:event.room_id
            Docs.find 
                model:'reservation'
                room_id:event.room_id 
                date:event.date
                
    
    
    
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