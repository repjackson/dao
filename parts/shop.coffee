if Meteor.isClient
    Router.route '/shop/', (->
        @layout 'layout'
        @render 'products'
        ), name:'products'
    Router.route '/product/:doc_id/view', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'

    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.products.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.products.events
        'click .add_event': ->
            new_id = 
                Docs.insert
                    model:'event'
            Router.go "/event/#{new_id}/edit"
    Template.products.helpers
        next_events: ->
            Docs.find {model:'event'}, 
                sort:
                    start_datetime:-1

    Template.product_view.onRendered ->
    Template.product_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_event', @_id, =>
                    Router.go "/event/#{@_id}/view"


    Template.product_view.helpers
    Template.product_view.events

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


# if Meteor.isClient
#     Router.route '/event/:doc_id/edit', (->
#         @layout 'layout'
#         @render 'event_edit'
#         ), name:'event_edit'

#     Template.event_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.event_edit.onRendered ->


#     Template.event_edit.events
#         'click .delete_item': ->
#             if confirm 'delete item?'
#                 Docs.remove @_id

#         'click .submit': ->
#             Docs.update Router.current().params.doc_id,
#                 $set:published:true
#             if confirm 'confirm?'
#                 Meteor.call 'send_event', @_id, =>
#                     Router.go "/event/#{@_id}/view"


#     Template.event_edit.helpers
#     Template.event_edit.events

# if Meteor.isServer
#     Meteor.methods
#         send_event: (event_id)->
#             event = Docs.findOne event_id
#             target = Meteor.users.findOne event.recipient_id
#             gifter = Meteor.users.findOne event._author_id

#             console.log 'sending event', event
#             Meteor.users.update target._id,
#                 $inc:
#                     points: event.amount
#             Meteor.users.update gifter._id,
#                 $inc:
#                     points: -event.amount
#             Docs.update event_id,
#                 $set:
#                     submitted:true
#                     submitted_timestamp:Date.now()



#             Docs.update Router.current().params.doc_id,
#                 $set:
#                     submitted:true
