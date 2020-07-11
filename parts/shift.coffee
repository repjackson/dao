if Meteor.isClient
    Router.route '/shift/:doc_id/view', (->
        @layout 'layout'
        @render 'shift_view'
        ), name:'shift_view'
    Router.route '/shift/:doc_id/edit', (->
        @layout 'layout'
        @render 'shift_edit'
        ), name:'shift_edit'


    Template.shift_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shift_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.shift_item.helpers


    Template.shift_item.events

    Template.shift_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shift_view.onRendered ->


    Template.shift_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_shift', @_id, =>
                    Router.go "/shift/#{@_id}/view"


    Template.shift_view.helpers
    Template.shift_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_shift: (shift_id)->
        #     shift = Docs.findOne shift_id
        #     target = Meteor.users.findOne shift.target_id
        #     sender = Meteor.users.findOne shift._author_id
        #
        #     console.log 'sending shift', shift
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: shift.amount
        #     Meteor.users.update sender._id,
        #         $inc:
        #             points: -shift.amount
        #     Docs.update shift_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true
