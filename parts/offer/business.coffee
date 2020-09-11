if Meteor.isClient
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    
    Template.businesss.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'business'
    
    
    Template.businesss.events
        'click .add_business': ->
            new_id = 
                Docs.insert 
                    model:'business'
            Router.go "/business/#{new_id}/edit"
            
    Template.businesss.helpers
        businesss: ->
            Docs.find 
                model:'business'
                # complete:$ne:true
                # published:true

    Template.business_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id

    Template.business_card.events
        'click .business_card': ->
            Router.go "/business/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1

    Template.business_item.events
        'click .business_item': ->
            Router.go "/business/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1

    Template.business_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.business_view.onRendered ->


    Template.business_view.events
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
                            

    Template.business_view.helpers
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
        # send_business: (business_id)->
        #     business = Docs.findOne business_id
        #     target = Meteor.users.findOne business.recipient_id
        #     gifter = Meteor.users.findOne business._author_id
        #
        #     console.log 'sending business', business
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: business.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -business.amount
        #     Docs.update business_id,
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
    Template.business_edit.onRendered ->
    Template.business_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.business_edit.events
        'click .delete_business': ->
            Swal.fire({
                title: "delete business?"
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
                        title: 'business removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/m/business"
            )




    Template.business_edit.helpers
    Template.business_edit.events

if Meteor.isServer
    Meteor.methods
        publish_business: (business_id)->
            business = Docs.findOne business_id
            # target = Meteor.users.findOne business.recipient_id
            author = Meteor.users.findOne business._author_id

            console.log 'publishing business', business
            Meteor.users.update author._id,
                $inc:
                    points: -business.point_bounty
            Docs.update business_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
