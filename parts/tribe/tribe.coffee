if Meteor.isClient
    Template.tribe_card.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000

    Template.tribe_edit.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
    Template.tribe_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
        Meteor.call 'mark_read', Router.current().params.doc_id, ->

    Template.tribe_card.events
        'click .view_tribe': ->
            Router.go "/tribe/#{@_id}/view"

    
    # Template.one_tribe_view.events
    #     'click .add_tag': ->
    #         selected_tags.push @valueOf()
    #         Meteor.call 'call_wiki', @valueOf(), ->
    #         Meteor.call 'search_reddit', selected_tags.array(), ->
                
    #         # Router.go '/'
    
    Template.join.helpers
        is_member: ->
            Meteor.userId() in @member_ids
    
    Template.join.events 
        'click .join':->
            Docs.update 
                $addToSet:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
        'click .leave':->
            Docs.update 
                $pull:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
        





if Meteor.isServer
    Meteor.methods 
                    
                    
    Meteor.publish 'tribe_posts', (tribe_id)->
        Docs.find   
            model:'post'
            tribe_id:tribe_id
    
    Meteor.publish 'tribe_tips', (tribe_id)->
        Docs.find   
            model:'tip'
            tribe_id:tribe_id
    
    Meteor.publish 'tribe_votes', (tribe_id)->
        Docs.find   
            model:'vote'
            parent_id:tribe_id
    
    
if Meteor.isClient
    Template.tribe_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.tribe_edit.events
        'click .delete_tribe': ->
            Swal.fire({
                title: "delete tribe?"
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
                        title: 'tribe removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )




    Template.tribe_edit.helpers
    Template.tribe_edit.events

if Meteor.isServer
    Meteor.methods
        publish_tribe: (tribe_id)->
            tribe = Docs.findOne tribe_id
            # target = Meteor.users.findOne tribe.recipient_id
            author = Meteor.users.findOne tribe._author_id

            console.log 'publishing tribe', offer
            Meteor.users.update author._id,
                $inc:
                    points: -offer.price
            Docs.update offer_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
                    
                    