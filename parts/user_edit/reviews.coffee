if Meteor.isClient
    Router.route '/user/:username/edit/reviews', (->
        @layout 'user_edit_layout'
        @render 'reviews'
        ), name:'reviews'

    Template.reviews.onCreated ->

    Template.reviews.onRendered ->

    Template.reviews.events
        'click .add_five_credits': ->
