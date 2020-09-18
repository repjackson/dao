Router.route '/add', (->
    @layout 'layout'
    @render 'add'
    ), name:'add'



Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    # @autorun => Meteor.subscribe 'all_users'
    # @autorun => Meteor.subscribe 'model_docs', 'tribe'
    # @autorun => Meteor.subscribe 'model_docs', 'model'

# Template.nav.onRendered ->
#     Meteor.setTimeout ->
#         $('.menu .item')
#             .popup(
#                 invert:true
#                 )
#         $('.ui.left.sidebar')
#             .sidebar({
#                 context: $('.bottom.segment')
#                 transition:'overlay'
#                 exclusive:true
#                 duration:100
#                 scrollLock:false
#             })
#             .sidebar('attach events', '.toggle_sidebar')
#     , 2000
#     Meteor.setTimeout ->
#         $('.ui.right.sidebar')
#             .sidebar({
#                 context: $('.bottom.segment')
#                 transition:'overlay'
#                 exclusive:true
#                 duration:100
#                 scrollLock:false
#             })
#             .sidebar('attach events', '.toggle_rightbar')
#     , 2000

Template.nav.events
#     'click .logout': ->
#         Session.set 'logging_out', true
#         Meteor.logout ->
#             Session.set 'logging_out', false
#             Router.go '/login'
    
    'click .toggle_nightmode': ->
        if Meteor.user().invert_class is 'invert'
            Meteor.users.update Meteor.userId(),
                $set:invert_class:''
        else
            Meteor.users.update Meteor.userId(),
                $set:invert_class:'invert'



    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .toggle_dev': ->
        if 'dev' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'dev'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'dev'

    'click .view_profile': ->
        Meteor.call 'calc_user_points', Meteor.userId()
        
Template.nav.events
    'click .debit': ->
        new_debit_id =
            Docs.insert
                model:'debit'
                buyer_id:Meteor.userId()
                buyer_username:Meteor.user().username
                status:'started'
        Router.go "/debit/#{new_debit_id}/edit"
    'click .post': ->
        new_post_id =
            Docs.insert
                model:'post'
                source:'self'
                # buyer_id:Meteor.userId()
                # buyer_username:Meteor.user().username
        Router.go "/post/#{new_post_id}/edit"