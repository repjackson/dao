if Meteor.isClient
    Router.route '/events/', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'
    Router.route '/event/:doc_id/view', (->
        @layout 'layout'
        @render 'event_view'
        ), name:'event_view'

    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.events.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'event'
    Template.events.events
        'click .add_event': ->
            new_id = 
                Docs.insert
                    model:'event'
            Router.go "/event/#{new_id}/edit"
    Template.events.helpers
        next_events: ->
            Docs.find {model:'event'}, 
                sort:
                    start_datetime:-1

    Template.event_view.onRendered ->
    Template.event_item.events
        'click .pick_going': ->
            console.log 'going'
            Docs.update @_id,
                $addToSet:
                    going_user_ids: Meteor.userId()
                $pull:
                    maybe_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_maybe': ->
            Docs.update @_id,
                $addToSet:
                    maybe_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_not': ->
            Docs.update @_id,
                $addToSet:
                    not_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    maybe_user_ids: Meteor.userId()
    
    Template.event_view.events
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
                Meteor.call 'send_event', @_id, =>
                    Router.go "/event/#{@_id}/view"


    Template.event_item.helpers
        going: ->
            event = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:event.going_user_ids
        maybe_going: ->
            event = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:event.maybe_user_ids
        not_going: ->
            event = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:event.not_user_ids
    Template.event_view.helpers
        going: ->
            event = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:event.going_user_ids
        maybe_going: ->
            event = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:event.maybe_user_ids
        not_going: ->
            event = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:event.not_user_ids
    Template.event_view.events

# if Meteor.isServer
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
