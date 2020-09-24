if Meteor.isClient
    Router.route '/user/:username/credit', (->
        @layout 'profile_layout'
        @render 'user_credit'
        ), name:'user_credit'

    Template.user_credit.onCreated ->
        @autorun -> Meteor.subscribe 'received_dollar_debits', Router.current().params.username
        @autorun -> Meteor.subscribe 'sent_dollar_debits', Router.current().params.username
        @autorun => Meteor.subscribe 'user_topups', Router.current().params.username

    Template.user_credit.events
        'click .recalc_user_credit': ->
            Meteor.call 'recalc_user_credit', Router.current().params.username, ->
        'keyup .new_debit': (e,t)->
            if e.which is 13
                val = $('.new_debit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'debit'
                    body: val
                    target_user_id: target_user._id



    Template.user_credit.helpers
        received_dollar_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'dollar_debit'
                recipient_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        sent_dollar_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'dollar_debit'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'received_dollar_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'dollar_debit'
            recipient_id:user._id
    
    Meteor.publish 'sent_dollar_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'dollar_debit'
            _author_id:user._id



if Meteor.isClient
    Template.user_credit.onCreated ->
        @autorun => Meteor.subscribe 'user_transactions', Router.current().params.username

        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/wc_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) ->
                amount = parseInt(Session.get('topup_amount'))
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: amount*100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'credit_topup', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        Swal.fire(
                            'topup processed',
                            ''
                            'success'
                        Docs.insert
                            model:'topup'
                            amount:amount
                        Meteor.users.update Meteor.userId(),
                            $inc: credit:amount
                        )
        )

    Template.user_credit.onRendered ->

    Template.user_credit.events
        'click .add_five_credits': ->
            # console.log Template.instance()
            # if confirm 'add 5 credits?'
            Session.set('topup_amount',5)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'one top up'
                amount: 500


        'click .add_ten_credits': ->
            # console.log Template.instance()
            # if confirm 'add 10 credits?'
            Session.set('topup_amount',10)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'one top up'
                amount: 1000


        'click .add_twenty_credits': ->
            # console.log Template.instance()
            # if confirm 'add 20 credits?'
            Session.set('topup_amount',20)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'one top up'
                amount: 2000


        'click .add_fifty_credits': ->
            # console.log Template.instance()
            # if confirm 'add 50 credits?'
            Session.set('topup_amount',50)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'one top up'
                amount: 5000


        'click .add_hundred_credits': ->
            # console.log Template.instance()
            # if confirm 'add 100 credits?'
            Session.set('topup_amount',100)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'one top up'
                amount: 10000



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
            #             description: 'one top up'
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

    Template.user_credit.helpers
        user_topups: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'topup'
                _author_id: current_user._id
            }, sort:_timestamp:-1


if Meteor.isServer
    Meteor.publish 'user_topups', (username)->
        current_user = Meteor.users.findOne(username:username)
        Docs.find
            model:'topup'
            _author_id: current_user._id
    
    Meteor.methods 
        recalc_user_credit: (username)->
            user = Meteor.users.findOne username:username
            user_id = user._id
            # console.log classroom
            # student_stats_doc = Docs.findOne
            #     model:'student_stats'
            #     user_id: user_id
            #
            # unless student_stats_doc
            #     new_stats_doc_id = Docs.insert
            #         model:'student_stats'
            #         user_id: user_id
            #     student_stats_doc = Docs.findOne new_stats_doc_id

            topups = Docs.find({
                model:'topup'
                amount:$exists:true
                _author_id:user_id})
            topup_count = topups.count()
            total_topup_amount = 0
            for topup in topups.fetch()
                total_topup_amount += topup.amount

            console.log 'total topup amount', total_topup_amount

            # credits = Docs.find({
            #     model:'debit'
            #     amount:$exists:true
            #     recipient_id:user_id})
            # credit_count = credits.count()
            # total_credit_amount = 0
            # for credit in credits.fetch()
            #     total_credit_amount += credit.amount

            # console.log 'total credit amount', total_credit_amount
            # calculated_user_balance = total_credit_amount-total_debit_amount

            # # average_credit_per_student = total_credit_amount/student_count
            # # average_debit_per_student = total_debit_amount/student_count
            # flow_volume = Math.abs(total_credit_amount)+Math.abs(total_debit_amount)
            # points = total_credit_amount-total_debit_amount
            
            
            # if total_debit_amount is 0 then total_debit_amount++
            # if total_credit_amount is 0 then total_credit_amount++
            # # debit_credit_ratio = total_debit_amount/total_credit_amount
            # unless total_debit_amount is 1
            #     unless total_credit_amount is 1
            #         one_ratio = total_debit_amount/total_credit_amount
            #     else
            #         one_ratio = 0
            # else
            #     one_ratio = 0
                    
            # dc_ratio_inverted = 1/debit_credit_ratio

            # credit_debit_ratio = total_credit_amount/total_debit_amount
            # cd_ratio_inverted = 1/credit_debit_ratio

            # one_score = total_bandwith*dc_ratio_inverted

            Meteor.users.update user_id,
                $set:
                    topup_count: topup_count
                    total_topup_amount:total_topup_amount
                    credit: total_topup_amount
