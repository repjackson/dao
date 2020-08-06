if Meteor.isClient
    Router.route '/discussion/:doc_id/view', (->
        @layout 'layout'
        @render 'discussion_view'
        ), name:'discussion_view'

    Template.discussion_view.onCreated ->
        @autorun => Meteor.subscribe 'discussion_tickets', Router.current().params.doc_id
        

    Template.discussion_view.onRendered ->



    Template.discussion_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.discussion_view.onRendered ->
    Template.discussion_item.events
        # 'click .pick_going': ->
        #     console.log 'going'
        #     Docs.update @_id,
        #         $addToSet:
        #             going_user_ids: Meteor.userId()
        #         $pull:
        #             maybe_user_ids: Meteor.userId()
        #             not_user_ids: Meteor.userId()
    
        # 'click .pick_maybe': ->
        #     Docs.update @_id,
        #         $addToSet:
        #             maybe_user_ids: Meteor.userId()
        #         $pull:
        #             going_user_ids: Meteor.userId()
        #             not_user_ids: Meteor.userId()
    
        # 'click .pick_not': ->
        #     Docs.update @_id,
        #         $addToSet:
        #             not_user_ids: Meteor.userId()
        #         $pull:
        #             going_user_ids: Meteor.userId()
        #             maybe_user_ids: Meteor.userId()
    
    Template.discussion_view.events
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
                Meteor.call 'send_discussion', @_id, =>
                    Router.go "/discussion/#{@_id}/view"


    Template.discussion_item.helpers
        
        going: ->
            discussion = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:discussion.going_user_ids
        maybe_going: ->
            discussion = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:discussion.maybe_user_ids
        not_going: ->
            discussion = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:discussion.not_user_ids
    Template.discussion_view.helpers
        tickets_left: ->
            ticket_count = 
                Docs.find({ 
                    model:'transaction'
                    transaction_type:'ticket_purchase'
                    discussion_id: Router.current().params.doc_id
                }).count()
            @max_attendees-ticket_count
        tickets: ->
            Docs.find 
                model:'transaction'
                transaction_type:'ticket_purchase'
                discussion_id: Router.current().params.doc_id
        going: ->
            discussion = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:discussion.going_user_ids
        maybe_going: ->
            discussion = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:discussion.maybe_user_ids
        not_going: ->
            discussion = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:discussion.not_user_ids

if Meteor.isServer
    Meteor.publish 'discussion_tickets', (discussion_id)->
        Docs.find
            model:'transaction'
            transaction_type:'ticket_purchase'
            discussion_id:discussion_id
#     Meteor.methods
        # send_discussion: (discussion_id)->
        #     discussion = Docs.findOne discussion_id
        #     target = Meteor.users.findOne discussion.recipient_id
        #     gifter = Meteor.users.findOne discussion._author_id
        #
        #     console.log 'sending discussion', discussion
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: discussion.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -discussion.amount
        #     Docs.update discussion_id,
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
    Router.route '/discussion/:doc_id/edit', (->
        @layout 'layout'
        @render 'discussion_edit'
        ), name:'discussion_edit'

    Template.discussion_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.discussion_edit.onRendered ->


    Template.discussion_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_discussion', @_id, =>
                    Router.go "/discussion/#{@_id}/view"


    Template.discussion_edit.helpers

if Meteor.isServer
    Meteor.methods
        send_discussion: (discussion_id)->
            discussion = Docs.findOne discussion_id
            target = Meteor.users.findOne discussion.recipient_id
            gifter = Meteor.users.findOne discussion._author_id

            console.log 'sending discussion', discussion
            Meteor.users.update target._id,
                $inc:
                    points: discussion.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -discussion.amount
            Docs.update discussion_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
