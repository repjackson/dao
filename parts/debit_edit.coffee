if Meteor.isClient
    Router.route '/debit/:doc_id/edit', (->
        @layout 'layout'
        @render 'debit_edit'
        ), name:'debit_edit'
        
        
    Template.debit_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'




    Template.debit_edit.helpers
        recipient: ->
            debit = Docs.findOne Router.current().params.doc_id
            if debit.recipient_id
                Meteor.users.findOne
                    _id: debit.recipient_id
        members: ->
            debit = Docs.findOne Router.current().params.doc_id
            if debit.recipient_ids
                Meteor.users.find 
                    levels: $in: ['member']
                    _id: $ne: debit.recipient_id
            else
                Meteor.users.find 
                    levels: $in: ['member']
        # subtotal: ->
        #     debit = Docs.findOne Router.current().params.doc_id
        #     debit.amount*debit.recipient_ids.length
        
        can_submit: ->
            debit = Docs.findOne Router.current().params.doc_id
            debit.amount and debit.recipient_id
    Template.debit_edit.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    recipient_id:1
        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                t.$('.new_element').val('')
    
        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_element').focus()
            t.$('.new_element').val(element)
    
    
        'blur .edit_description': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            Docs.update Router.current().params.doc_id,
                $set:description:textarea_val
    
    
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            Docs.update Router.current().params.doc_id,
                $set:"#{@key}":val
    
    


if Meteor.isClient
    Template.debit_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'recipient_from_debit_id', Router.current().params.doc_id
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
            recipient = Meteor.users.findOne debit.recipient_id
            sender = Meteor.users.findOne debit._author_id

            console.log 'sending debit', debit
            Meteor.users.update recipient._id,
                $inc:
                    points: debit.amount
            Meteor.users.update sender._id,
                $inc:
                    points: -debit.amount
            Docs.update debit_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update debit_id,
                $set:
                    submitted:true
