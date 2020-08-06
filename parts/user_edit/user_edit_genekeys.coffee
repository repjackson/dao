if Meteor.isClient
    Router.route '/user/:username/edit/genekeys', (->
        @layout 'user_edit_layout'
        @render 'user_edit_genekeys'
        ), name:'user_edit_genekeys'

    Template.user_edit_genekeys.onRendered ->

    Template.user_edit_genekeys.events
