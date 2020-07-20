if Meteor.isClient
    Router.route '/badges/', (->
        @layout 'layout'
        @render 'badges'
        ), name:'badges'
    
    Router.route '/badge/:doc_id/view', (->
        @layout 'layout'
        @render 'badge_view'
        ), name:'badge_view'

    Template.badge_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
    Template.badges.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'badge'
    Template.badges.events
        'click .add_badge': ->
            new_id = 
                Docs.insert
                    model:'badge'
            Router.go "/badge/#{new_id}/edit"
    
    
    Template.badges.helpers
        badges: ->
            Docs.find 
                model:'badge'
   
    Template.badge_view.onRendered ->


    Template.badge_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_badge', @_id, =>
                    Router.go "/badge/#{@_id}/view"


    Template.badge_view.helpers
    Template.badge_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_badge: (badge_id)->
        #     badge = Docs.findOne badge_id
        #     target = Meteor.users.findOne badge.recipient_id
        #     gifter = Meteor.users.findOne badge._author_id
        #
        #     console.log 'sending badge', badge
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: badge.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -badge.amount
        #     Docs.update badge_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Router.route '/badge/:doc_id/edit', (->
        @layout 'layout'
        @render 'badge_edit'
        ), name:'badge_edit'

    Template.badge_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.badge_edit.onRendered ->


    Template.badge_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_badge', @_id, =>
                    Router.go "/badge/#{@_id}/view"


    Template.badge_edit.helpers
    Template.badge_edit.events

if Meteor.isServer
    Meteor.methods
        publish_badge: (badge_id)->
            badge = Docs.findOne badge_id
            target = Meteor.users.findOne badge.recipient_id
            author = Meteor.users.findOne badge._author_id

            console.log 'sending badge', badge
            Meteor.users.update target._id,
                $inc:
                    points: badge.amount
            Meteor.users.update author._id,
                $inc:
                    points: -badge.amount
            Docs.update badge_id,
                $set:
                    published:true
                    published_timestamp:Date.now()