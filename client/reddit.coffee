# if Meteor.isClient
#     Template.reddit_view.onCreated ->
#         # @autorun -> Meteor.subscribe 'reddit_tips', Router.current().params.doc_id
#         # @autorun -> Meteor.subscribe 'reddit_votes', Router.current().params.doc_id
#         @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
#         # @autorun -> Meteor.subscribe 'me'
        
#         Session.setDefault 'view_reddit_section', 'content'
#     Template.reddit_edit.onRendered ->
#         Meteor.setTimeout ->
#             $('.ui.accordion').accordion()
#         , 2000
#     Template.reddit_view.onRendered ->
#         Meteor.call 'log_view', Router.current().params.doc_id
#         # Meteor.setTimeout ->
#         #     $('.ui.accordion').accordion()
#         # , 2000
#         Meteor.setTimeout ->
#             $('.ui.embed').embed();
#         , 1000
#         Meteor.call 'mark_read', Router.current().params.doc_id, ->
        
#     Template.reddit_card.onRendered ->
#         Meteor.setTimeout ->
#             $('.ui.embed').embed();
#         , 1000


#     Template.reddit_card.events
#         'click .view_reddit': ->
#             Router.go "/reddit/#{@_id}/view"

#     Template.reddit_view.events
#         'click .tip': ->
#             if Meteor.user()
#                 Meteor.call 'tip', @_id, ->
                    
#                 Meteor.call 'calc_reddit_stats', @_id, ->
#                 Meteor.call 'calc_user_stats', Meteor.userId(), ->
#                 $('body').toast({
#                     class: 'success'
#                     position: 'bottom right'
#                     message: "#{@title} tipped"
#                 })
#             else 
#                 Router.go '/login'
    
    
#     Template.one_reddit_view.events
#         'click .add_tag': ->
#             selected_tags.push @valueOf()
#             Meteor.call 'call_wiki', @valueOf(), ->
#             Meteor.call 'search_reddit', selected_tags.array(), ->
                
#             # Router.go '/'
    
    
    # Template.reddit_view.events
    #     'click .add_tag': ->
    #         # Meteor.call 'tip', @_id, ->
                
    #         # Meteor.call 'calc_reddit_stats', @_id, ->
    #         # Meteor.call 'calc_user_stats', Meteor.userId(), ->
    #         # $('body').toast({
    #         #     class: 'success'
    #         #     position: 'bottom right'
    #         #     message: "#{@title} tipped"
    #         # })
    #         selected_tags.push @valueOf()
    #         Meteor.call 'call_wiki', @valueOf(), ->
    #         Meteor.call 'search_reddit', selected_tags.array(), ->

    #         # Router.go '/'
    
    
    Template.reddit_card.events
        'click .add_tag': ->
            # Meteor.call 'tip', @_id, ->
                
            # Meteor.call 'calc_reddit_stats', @_id, ->
            # Meteor.call 'calc_user_stats', Meteor.userId(), ->
            # $('body').toast({
            #     class: 'success'
            #     position: 'bottom right'
            #     message: "#{@title} tipped"
            # })
            selected_tags.push @valueOf()
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', selected_tags.array(), ->

            # Router.go '/'
    
    

#     Template.reddit_view.helpers
#         tips: ->
#             Docs.find
#                 model:'tip'
        
#         votes: ->
#             Docs.find   
#                 model:'vote'
#                 parent_id:@_id
        
#         tippers: ->
#             Meteor.users.find
#                 _id:$in:@tipper_ids
        
#         tipper_tips: ->
#             # console.log @
#             Docs.find
#                 model:'tip'
#                 _author_id:@_id
        
#         can_claim: ->
#             if @claimed_user_id
#                 false
#             else 
#                 if @_author_id is Meteor.userId()
#                     false
#                 else
#                     true




# if Meteor.isServer
#     Meteor.publish 'reddit_tips', (reddit_id)->
#         Docs.find   
#             model:'tip'
#             reddit_id:reddit_id
    
#     Meteor.publish 'reddit_votes', (reddit_id)->
#         Docs.find   
#             model:'vote'
#             parent_id:reddit_id
    
    
# if Meteor.isClient
#     Template.reddit_edit.onCreated ->
#         @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


#     Template.reddit_edit.events
#         'click .delete_reddit': ->
#             Swal.fire({
#                 title: "delete reddit?"
#                 text: "cannot be undone"
#                 icon: 'question'
#                 confirmButtonText: 'delete'
#                 confirmButtonColor: 'red'
#                 showCancelButton: true
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Docs.remove @_id
#                     Swal.fire(
#                         position: 'top-end',
#                         icon: 'success',
#                         title: 'reddit removed',
#                         showConfirmButton: false,
#                         timer: 1000
#                     )
#                     Router.go "/"
#             )




#     Template.reddit_edit.helpers
#     Template.reddit_edit.events

# if Meteor.isServer
#     Meteor.methods
#         publish_reddit: (reddit_id)->
#             reddit = Docs.findOne reddit_id
#             # target = Meteor.users.findOne reddit.recipient_id
#             author = Meteor.users.findOne reddit._author_id

#             console.log 'publishing reddit', offer
#             Meteor.users.update author._id,
#                 $inc:
#                     points: -offer.price
#             Docs.update offer_id,
#                 $set:
#                     published:true
#                     published_timestamp:Date.now()
                    
                    
                    
                    