if Meteor.isClient
    Router.route '/debit/:doc_id/view', (->
        @layout 'layout'
        @render 'debit_view'
        ), name:'debit_view'

    Template.debit_view.onCreated ->
        @autorun => Meteor.subscribe 'target_from_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.debit_view.onRendered ->


    Template.debit_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_debit', @_id, =>
                    Router.go "/debit/#{@_id}/view"


    Template.debit_view.helpers
    Template.debit_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_debit: (debit_id)->
        #     debit = Docs.findOne debit_id
        #     target = Meteor.users.findOne debit.target_id
        #     sender = Meteor.users.findOne debit._author_id
        #
        #     console.log 'sending debit', debit
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: debit.amount
        #     Meteor.users.update sender._id,
        #         $inc:
        #             points: -debit.amount
        #     Docs.update debit_id,
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
    Router.route '/debit/:doc_id/edit', (->
        @layout 'layout'
        @render 'debit_edit'
        ), name:'debit_edit'

    Template.debit_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'target_from_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    Template.debit_edit.onRendered ->


    Template.debit_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_debit', @_id, =>
                    Router.go "/debit/#{@_id}/view"


    Template.debit_edit.helpers
    Template.debit_edit.events

if Meteor.isServer
    Meteor.methods
        send_debit: (debit_id)->
            debit = Docs.findOne debit_id
            target = Meteor.users.findOne debit.target_id
            sender = Meteor.users.findOne debit._author_id

            console.log 'sending debit', debit
            Meteor.users.update target._id,
                $inc:
                    points: debit.amount
            Meteor.users.update sender._id,
                $inc:
                    points: -debit.amount
            Docs.update debit_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
