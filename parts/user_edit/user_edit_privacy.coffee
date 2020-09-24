if Meteor.isClient
    Router.route '/user/:username/edit/privacy', (->
        @layout 'user_edit_layout'
        @render 'user_edit_privacy'
        ), name:'user_edit_privacy'

    Template.user_edit_privacy.onRendered ->

    Template.user_edit_privacy.events
        'click .logout_other_clients': -> 
            Meteor.logoutOtherClients ->
                $('body').toast({
                    class: 'success',
                    message: "logged out other clients"
                })

    
        'click .force_logout': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update current_user._id,
                $set:'services.resume.loginTokens':[]

    
        'click .add_five_credits': ->
            console.log Template.instance()
            if confirm 'add 5 credits?'
                Session.set('topup_amount',5)
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'wc top up'
                    amount: 500





            # Swal.fire({
            #     title: 'add 5 credits?'
            #     text: "this will charge you $5"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result)=>
            #     if result.value
            #         Session.set('topup_amount',5)
            #         Template.instance().checkout.open
            #             name: 'credit deposit'
            #             # email:Meteor.user().emails[0].address
            #             description: 'wc top up'
            #             amount: 5
            #
            #         # Meteor.users.update @_author_id,
            #         #     $inc:credit:@order_price
            #         Swal.fire(
            #             'topup initiated',
            #             ''
            #             'success'
            #         )
            # )
