if Meteor.isClient
    Router.route '/badge/:doc_id/view', (->
        @layout 'layout'
        @render 'badge_view'
        ), name:'badge_view'

    Template.badge_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.badge_view.onRendered ->


    Template.badge_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_badge', @_id, =>
                    Router.go "/badge/#{@_id}/view"


    Template.badge_view.helpers
    Template.badge_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_badge: (badge_id)->
        #     badge = Docs.findOne badge_id
        #     target = Meteor.users.findOne badge.target_id
        #     sender = Meteor.users.findOne badge._author_id
        #
        #     console.log 'sending badge', badge
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: badge.amount
        #     Meteor.users.update sender._id,
        #         $inc:
        #             points: -badge.amount
        #     Docs.update badge_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true

    Template.badge_item.helpers


    Template.badge_item.events
