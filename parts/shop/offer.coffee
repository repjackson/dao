if Meteor.isClient
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    
    Template.offers.events
        'click .add_offer': ->
            new_id = 
                Docs.insert 
                    model:'offer'
            Router.go "/m/offer/#{new_id}/edit"
            
    Template.offers.helpers
        offers: ->
            Docs.find 
                model:'offer'
                complete:$ne:true
                published:true

    Template.offer_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id

    Template.offer_card.events
        'click .offer_card': ->
            Router.go "/m/offer/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1

    Template.offer_item.events
        'click .offer_item': ->
            Router.go "/m/offer/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1


    Template.offer_view.onRendered ->


    Template.offer_view.events
        'click .claim': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    claimed_user_id: Meteor.userId()
                    status:'claimed'
            
                            
        'click .unclaim': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    claimed_user_id: 1
                $set:
                    status:'unclaimed'
            
                            
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: true
                    completed_by_user_id:@claimed_user_id
                    status:'complete'
                    completed_timestamp:Date.now()
            Meteor.users.update @claimed_user_id,
                $inc:points:@point_bounty
                            
        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: false
                    completed_by_user_id: null
                    status:'claimed'
                    completed_timestamp:null
            Meteor.users.update @claimed_user_id,
                $inc:points:-@point_bounty
                            

    Template.offer_view.helpers
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true



# if Meteor.isServer
#     Meteor.methods
        # send_offer: (offer_id)->
        #     offer = Docs.findOne offer_id
        #     target = Meteor.users.findOne offer.recipient_id
        #     gifter = Meteor.users.findOne offer._author_id
        #
        #     console.log 'sending offer', offer
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: offer.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -offer.amount
        #     Docs.update offer_id,
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
    Template.offer_edit.onRendered ->


    Template.offer_edit.events
        'click .delete_offer': ->
            Swal.fire({
                title: "delete offer?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'offer removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/m/offer"
            )




    Template.offer_edit.helpers
    Template.offer_edit.events

if Meteor.isServer
    Meteor.methods
        publish_offer: (offer_id)->
            offer = Docs.findOne offer_id
            # target = Meteor.users.findOne offer.recipient_id
            author = Meteor.users.findOne offer._author_id

            console.log 'publishing offer', offer
            Meteor.users.update author._id,
                $inc:
                    points: -offer.point_bounty
            Docs.update offer_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
                    
                    