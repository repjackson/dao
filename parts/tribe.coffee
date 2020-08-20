if Meteor.isClient
    Template.tribe_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
        @autorun => Meteor.subscribe 'all_users'
        @autorun => Meteor.subscribe 'tribe_template_from_tribe_id', Router.current().params.doc_id

    Template.tribe_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'feature'

    Template.registerHelper 'is_member', ()->
        Meteor.userId() in @tribe_member_ids

    Template.tribe_view.onRendered ->
        @autorun => Meteor.subscribe 'tribe_template_from_tribe_id', Router.current().params.doc_id
    Template.tribe_edit.helpers
        enabled_features: ->
            tribe = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'feature'
                _id:$in:tribe.enabled_feature_ids
        disabled_features: ->
            tribe = Docs.findOne Router.current().params.doc_id
            if tribe.enabled_feature_ids
                Docs.find 
                    model:'feature'
                    _id:$nin:tribe.enabled_feature_ids
            else
                Docs.find 
                    model:'feature'
            
    Template.tribe_edit.events
        'click .enable_feature': ->
            console.log @
            Docs.update Router.current().params.doc_id,
                $addToSet: 
                    enabled_feature_ids:@_id
    
        'click .disable_feature': ->
            Docs.update Router.current().params.doc_id,
                $pull: 
                    enabled_feature_ids:@_id
    
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_tribe', @_id, =>
                    Router.go "/tribe/#{@_id}/view"

    Template.tribe_membership.events
        'click .switch': ->
            Meteor.call 'switch_tribe', @_id
        'click .join': ->
            Meteor.call 'join_tribe', @_id, ->
        'click .leave': ->
            Meteor.call 'leave_tribe', @_id, ->
        'click .request': ->
            Meteor.call 'request_tribe_membership', @_id, ->
                

if Meteor.isServer
    Meteor.publish 'tribe_template_from_tribe_id', (tribe_id)->
        tribe = Docs.findOne tribe_id
        Docs.find 
            model:'tribe_template'
            _id:tribe.template_id
    
    Meteor.methods
        join_tribe: (tribe_id)->
            tribe = Docs.findOne tribe_id
            Docs.update tribe_id, 
                $addToSet:
                    tribe_member_ids: Meteor.userId()
        
        leave_tribe: (tribe_id)->
            tribe = Docs.findOne tribe_id
            Docs.update tribe_id, 
                $pull:
                    tribe_member_ids: Meteor.userId()
                    
                    
        switch_tribe: (tribe_id)->
            Meteor.users.update Meteor.userId(),
                $set:current_tribe_id:tribe_id

if Meteor.isClient
    Template.tribe_edit.events
        'click .delete_item': ->
            if confirm 'delete tribe?'
                Meteor.call 'delete_tribe', @_id, ->

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_tribe', @_id, =>
                    Router.go "/tribe/#{@_id}/view"


    Template.tribe_edit.helpers
        unselected_stewards: ->
            Meteor.users.find 
                levels:$in:['steward']
    Template.tribe_edit.tribes
