if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    Template.registerHelper 'badgers', () ->
        # badge = Docs.findOne Router.current().params.doc_id
        if @badger_ids
            Meteor.users.find   
                _id:$in:@badger_ids
    
    Router.route '/rental/:doc_id/view', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'

    
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'

    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    
    Template.registerHelper 'honey_rentalrs', () ->
        rental = Docs.findOne Router.current().params.doc_id
        if rental.honey_rentalr_ids
            Meteor.users.find   
                _id:$in:rental.honey_rentalr_ids

    Router.route '/rentals', (->
        @layout 'layout'
        @render 'rentals'
        ), name:'rentals'

    Template.rentals.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'rental'
   
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
   
    Template.rental_view.onRendered ->


    Template.rental_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_rental', @_id, =>
                    Router.go "/rental/#{@_id}/view"


    Template.rentals.events
        'click .add_rental': ->
            new_id = 
                Docs.insert 
                    model:'rental'
            Router.go "/rental/#{new_id}/edit"
    Template.rentals.helpers
        rentals: ->
            Docs.find   
                model:'rental'
    
    Template.rental_view.helpers
    Template.rental_view.events
    

# if Meteor.isServer
#     Meteor.methods
        # send_rental: (rental_id)->
        #     rental = Docs.findOne rental_id
        #     target = Meteor.users.findOne rental.recipient_id
        #     gifter = Meteor.users.findOne rental._author_id
        #
        #     console.log 'sending rental', rental
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: rental.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -rental.amount
        #     Docs.update rental_id,
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

    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.rental_edit.onRendered ->


    Template.rental_edit.events
        'click .delete_item': ->
            if confirm 'delete rental?'
                Docs.remove @_id
                Router.go "/m/rental"

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_rental', @_id, =>
                    Router.go "/rental/#{@_id}/view"

        'click .add_rentalr': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    rentalr_ids: @_id

        'click .remove_rentalr': ->
            Docs.update Router.current().params.doc_id, 
                $pull: 
                    rentalr_ids: @_id
        
        'click .add_honey_rentalr': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    honey_rentalr_ids: @_id

        'click .remove_honey_rentalr': ->
            Docs.update Router.current().params.doc_id, 
                $pull: 
                    honey_rentalr_ids: @_id

    Template.rental_edit.helpers
        unselected_rentalrs: ->
            rental = Docs.findOne Router.current().params.doc_id
            if @rentalr_ids
                Meteor.users.find({
                    _id:$nin:@rentalr_ids
                })
            else
                Meteor.users.find({
                })
        unselected_honey_rentalrs: ->
            rental = Docs.findOne Router.current().params.doc_id
            Meteor.users.find {},
                limit:10
                sort:points:-1
                _id:$nin:rental.honey_rentalr_ids

if Meteor.isServer
    Meteor.methods
        # reward_badge: (badge_id, target_id)->
        #     badge = Docs.findOne badge_id
        #     target = Meteor.users.findOne target_id

        #     console.log 'rewarding badge', badge
        #     Meteor.users.update target._id,
        #         $addToSet:
        #             rewarded_badge_ids: badge._id
