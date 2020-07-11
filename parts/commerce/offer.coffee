if Meteor.isClient
    Router.route '/offer/:doc_id/view', (->
        @layout 'layout'
        @render 'offer_view'
        ), name:'offer_view'

    Template.offer_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.offer_view.onRendered ->


    Template.offer_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_offer', @_id, =>
                    Router.go "/offer/#{@_id}/view"


    Template.offer_view.helpers
    Template.offer_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_offer: (offer_id)->
        #     offer = Docs.findOne offer_id
        #     target = Meteor.users.findOne offer.target_id
        #     sender = Meteor.users.findOne offer._author_id
        #
        #     console.log 'sending offer', offer
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: offer.amount
        #     Meteor.users.update sender._id,
        #         $inc:
        #             points: -offer.amount
        #     Docs.update offer_id,
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
    Router.route '/offer/:doc_id/edit', (->
        @layout 'layout'
        @render 'offer_edit'
        ), name:'offer_edit'

    Template.offer_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.offer_edit.onRendered ->


    Template.offer_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_offer', @_id, =>
                    Router.go "/offer/#{@_id}/view"


    Template.offer_edit.helpers
    Template.offer_edit.events

if Meteor.isServer
    Meteor.methods
        send_offer: (offer_id)->
            offer = Docs.findOne offer_id
            target = Meteor.users.findOne offer.target_id
            sender = Meteor.users.findOne offer._author_id

            console.log 'sending offer', offer
            Meteor.users.update target._id,
                $inc:
                    points: offer.amount
            Meteor.users.update sender._id,
                $inc:
                    points: -offer.amount
            Docs.update offer_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
