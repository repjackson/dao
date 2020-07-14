if Meteor.isClient
    Router.route '/gift/:doc_id/edit', (->
        @layout 'layout'
        @render 'gift_edit'
        ), name:'gift_edit'
        
        
    Template.gift_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_gift_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'




    Template.gift_edit.helpers
        recipient: ->
            gift = Docs.findOne Router.current().params.doc_id
            if gift.recipient_id
                Meteor.users.findOne
                    _id: gift.recipient_id
        members: ->
            gift = Docs.findOne Router.current().params.doc_id
            if gift.recipient_ids
                Meteor.users.find 
                    levels: $in: ['member']
                    _id: $ne: gift.recipient_id
            else
                Meteor.users.find 
                    levels: $in: ['member']
        # subtotal: ->
        #     gift = Docs.findOne Router.current().params.doc_id
        #     gift.amount*gift.recipient_ids.length
        
        can_submit: ->
            gift = Docs.findOne Router.current().params.doc_id
            gift.amount and gift.recipient_id
    Template.gift_edit.events
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
    Template.gift_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'recipient_from_gift_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    Template.gift_edit.onRendered ->


    Template.gift_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_gift', @_id, =>
                    Router.go "/gift/#{@_id}/view"


    Template.gift_edit.helpers
    Template.gift_edit.events

if Meteor.isServer
    Meteor.methods
        send_gift: (gift_id)->
            gift = Docs.findOne gift_id
            recipient = Meteor.users.findOne gift.recipient_id
            gifter = Meteor.users.findOne gift._author_id

            console.log 'sending gift', gift
            Meteor.users.update recipient._id,
                $inc:
                    points: gift.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -gift.amount
            Docs.update gift_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update gift_id,
                $set:
                    submitted:true
