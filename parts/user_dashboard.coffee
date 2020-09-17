# if Meteor.isClient
        
        
#     Template.user_dashboard.onCreated ->
#         @autorun -> Meteor.subscribe 'user_offers', Router.current().params.username
#         # @autorun -> Meteor.subscribe 'user_credits', Router.current().params.username
#         # @autorun -> Meteor.subscribe 'user_debits', Router.current().params.username
#         # @autorun -> Meteor.subscribe 'user_requests', Router.current().params.username
#         # @autorun -> Meteor.subscribe 'user_completed_requests', Router.current().params.username
#         # @autorun -> Meteor.subscribe 'user_orders', Router.current().params.username
#         # @autorun -> Meteor.subscribe 'model_docs', 'offer'
        
#     Template.user_dashboard.events
#         'click .user_credit_segment': ->
#             Router.go "/debit/#{@_id}/view"
            
#         'click .user_debit_segment': ->
#             Router.go "/debit/#{@_id}/view"
            
            
            
#     Template.votes_in.helpers
#         votes: ->
#             current_user = Meteor.users.findOne(username:Router.current().params.username)
#             Docs.find {
#                 model:'vote'
#                 _author_id: current_user._id
#             }, 
#                 limit: 10
#                 sort: _timestamp:-1
#     Template.user_debits.helpers
#         user_debits: ->
#             current_user = Meteor.users.findOne(username:Router.current().params.username)
#             Docs.find {
#                 model:'debit'
#                 _author_id: current_user._id
#             }, 
#                 limit: 10
#                 sort: _timestamp:-1
#     Template.user_credits.helpers
#         user_credits: ->
#             current_user = Meteor.users.findOne(username:Router.current().params.username)
#             Docs.find {
#                 model:'debit'
#                 recipient_id: current_user._id
#             }, 
#                 sort: _timestamp:-1
#                 limit: 10



# if Meteor.isServer
#     Meteor.publish 'user_debits', (username)->
#         user = Meteor.users.findOne username:username
#         Docs.find({
#             model:'debit'
#             _author_id:user._id
#         },{
#             limit:20
#             sort: _timestamp:-1
#         })
        
        
#     Meteor.publish 'user_event_tickets', (username)->
#         user = Meteor.users.findOne username:username
#         Docs.find({
#             model:'transaction'
#             transaction_type:'ticket_purchase'
#             _author_id:user._id
#         },{
#             limit:20
#             sort: _timestamp:-1
#         })
        
        
        
        