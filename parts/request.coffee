if Meteor.isClient
    Router.route '/requests/', (->
        @layout 'layout'
        @render 'requests'
        ), name:'requests'
    
    Router.route '/request/:doc_id/view', (->
        @layout 'layout'
        @render 'request_view'
        ), name:'request_view'

    Template.request_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.request_view.onRendered ->


    Template.request_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_request', @_id, =>
                    Router.go "/request/#{@_id}/view"


    Template.request_view.helpers
    Template.request_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_request: (request_id)->
        #     request = Docs.findOne request_id
        #     target = Meteor.users.findOne request.recipient_id
        #     gifter = Meteor.users.findOne request._author_id
        #
        #     console.log 'sending request', request
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: request.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -request.amount
        #     Docs.update request_id,
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
    Router.route '/request/:doc_id/edit', (->
        @layout 'layout'
        @render 'request_edit'
        ), name:'request_edit'

    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.request_edit.onRendered ->


    Template.request_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_request', @_id, =>
                    Router.go "/request/#{@_id}/view"


    Template.request_edit.helpers
    Template.request_edit.events

if Meteor.isServer
    Meteor.methods
        send_request: (request_id)->
            request = Docs.findOne request_id
            target = Meteor.users.findOne request.recipient_id
            gifter = Meteor.users.findOne request._author_id

            console.log 'sending request', request
            Meteor.users.update target._id,
                $inc:
                    points: request.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -request.amount
            Docs.update request_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
