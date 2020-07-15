Future = Npm.require('fibers/future')

Meteor.methods
    STRIPE_single_charge: (charge, user) ->
        # console.log 'charge', charge
        # console.log 'user', user
        if Meteor.isDevelopment
            Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
        else
            Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
        # account = Meteor.users.findOne(data.church)
        # #console.log(data)
        # console.log '------------------------------------------------------'
        # console.log account
        # if !account.stripe
        #     retVal = error:
        #         error: 'Donation Failed'
        #         message: 'Not ready for donations, please contact your Organization.'
        #     return retVal
        # console.log account.stripe
        charge_card = new Future
        # fee_addition = 0
        # if account.profile.isJGFeesApply
        #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
        # else
        #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
        # #console.log(fee_addition);
        charge_data =
            amount: charge.amount
            currency: 'usd'
            source: charge.source
            description: "credit topup"
            # destination: account.stripe.stripeId
        Stripe.charges.create charge_data, (error, result) ->
            if error
                charge_card.return error: error
            else
                charge_card.return result: result
            return
        new_charge = charge_card.wait()
        console.log new_charge
        new_charge


    strip_credit_topup: (charge) ->
        console.log 'charge', charge
        # console.log 'user', user
        if Meteor.isDevelopment
            Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
        else
            Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
        charge_card = new Future
        # fee_addition = 0
        # if account.profile.isJGFeesApply
        #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
        # else
        #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
        # #console.log(fee_addition);
        charge_data =
            amount: charge.amount
            currency: 'usd'
            source: charge.source
            description: "credit topup"
            # destination: account.stripe.stripeId
        Stripe.charges.create charge_data, (error, result) ->
            if error
                charge_card.return error: error
            else
                charge_card.return result: result
            return
        new_charge = charge_card.wait()
        console.log new_charge
        new_charge
        
        
    buy_membership: (charge) ->
        console.log 'charge', charge
        # console.log 'user', user
        if Meteor.isDevelopment
            Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
        else
            Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
        charge_card = new Future
        # fee_addition = 0
        # if account.profile.isJGFeesApply
        #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
        # else
        #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
        # #console.log(fee_addition);
        charge_data =
            amount: charge.amount
            currency: 'usd'
            source: charge.source
            description: "riverside membership"
            # destination: account.stripe.stripeId
        Stripe.charges.create charge_data, (error, result) ->
            if error
                charge_card.return error: error
            else
                charge_card.return result: result
            return
        new_charge = charge_card.wait()
        console.log new_charge
        new_charge        