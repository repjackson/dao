if Meteor.isClient
    Router.route '/user/:username/edit/membership', (->
        @layout 'user_edit_layout'
        @render 'user_edit_membership'
        ), name:'user_edit_membership'


    Template.user_edit_membership.onCreated ->
        @autorun => Meteor.subscribe 'user_edit_membership', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'picture'
        @autorun => Meteor.subscribe 'model_docs', 'transaction'

    Template.user_edit_membership.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_membership.helpers
        user_edit_membership: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'picture'
                target_user_id: target_user._id

        transactions: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                transaction_type:'membership'
                _author_id: target_user._id
            }, 
                sort:
                    _timestamp:-1
                    
                    
    Template.user_edit_membership.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/homestar_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) =>
                # amount = parseInt(Session.get('topup_amount'))
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: 25000
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'buy_membership', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'membership purchased',
                            ''
                            'success'
                        Docs.insert
                            model:'transaction'
                            transaction_type:'membership'
                            amount:250
                        Meteor.users.update Meteor.userId(),
                            $inc: points:500
                        )
        )

    Template.user_edit_membership.onRendered ->

    Template.user_edit_membership.events
        'click .pay_membership': ->
            console.log Template.instance()
            # if confirm 'add 5 credits?'
            # Session.set('topup_amount',5)
            # Template.instance().checkout.open
            #     name: 'Riverside Membership'
            #     # email:Meteor.user().emails[0].address
            #     description: 'monthly'
            #     amount: 250


            instance = Template.instance()


            Swal.fire({
                title: 'buy membership?'
                text: "this will charge you $250"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'Riverside Membership'
                        # email:Meteor.user().emails[0].address
                        description: 'monthly'
                        amount: 250
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )

if Meteor.isServer
    Meteor.publish 'user_edit_membership', (username)->
        Docs.find
            model:'picture'
