if Meteor.isClient
    Router.route '/user/:username/edit/levels', (->
        @layout 'user_edit_layout'
        @render 'user_edit_levels'
        ), name:'user_edit_levels'

    Template.user_edit_levels.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'


    Template.user_edit_levels.onCreated ->
        @autorun => Meteor.subscribe 'user_edit_levels', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'picture'

    Template.user_edit_levels.events
        'keyup .new_picture': (e,t)->
            if e.which is 13
                val = $('.new_picture').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'picture'
                    body: val
                    target_user_id: target_user._id



    Template.user_edit_levels.helpers
        user_edit_levels: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'picture'
                target_user_id: target_user._id

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_edit_levels', (username)->
        Docs.find
            model:'picture'
