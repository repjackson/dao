Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    @autorun => Meteor.subscribe 'all_users'

Template.nav.onRendered ->
    Meteor.setTimeout ->
        # $('.menu .item')
        #     .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                exclusive:true
                duration:150
                scrollLock:false
            })
            .sidebar('attach events', '.toggle_sidebar')
    , 1000
    Meteor.setTimeout ->
        $('.ui.right.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                exclusive:true
                duration:150
                scrollLock:false
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 1000

Template.right_sidebar.events
    'click .logout': ->
        Session.set 'logging_out', true
        Meteor.logout ->
            Session.set 'logging_out', false
            Router.go '/login'
            

Template.nav.helpers
        
Template.nav.events
    'click .debit': ->
        new_debit_id =
            Docs.insert
                model:'debit'
                buyer_id:Meteor.userId()
                buyer_username:Meteor.user().username
                status:'started'
        Router.go "/debit/#{new_debit_id}/edit"
    'click .request': ->
        new_request_id =
            Docs.insert
                model:'request'
                buyer_id:Meteor.userId()
                buyer_username:Meteor.user().username
        Router.go "/request/#{new_request_id}/edit"
    'click .offer': ->
        new_offer_id =
            Docs.insert
                model:'offer'
                seller_id:Meteor.userId()
                seller_username:Meteor.user().username
        Router.go "/offer/#{new_offer_id}/edit"

        
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
        
        
Template.nav.helpers
        
Template.left_sidebar.events
    # 'click .toggle_sidebar': ->
    #     $('.ui.sidebar')
    #         .sidebar('setting', 'transition', 'push')
    #         .sidebar('toggle')
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
                
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_gift_id =
            Docs.insert
                model:'gift'
                recipient_id: @_id
        Router.go "/debit/#{new_gift_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"

        