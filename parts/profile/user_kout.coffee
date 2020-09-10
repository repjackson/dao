if Meteor.isClient
    Router.route '/user/:username/kout', (->
        @layout 'profile_layout'
        @render 'user_kout'
        ), name:'user_kout'

    Template.user_kout.onCreated ->
        # @autorun -> Meteor.subscribe 'user_model_docs', 'debit', Router.current().params.username
        @autorun => Meteor.subscribe 'user_kout', Router.current().params.username
        @autorun -> Meteor.subscribe('tags',
            Session.get('query')
            selected_tags.array()
            selected_authors.array()
            selected_upvoters.array()
            selected_sources.array()
            )
        @autorun -> Meteor.subscribe('docs',
            Session.get('query')
            selected_tags.array()
            selected_authors.array()
            selected_upvoters.array()
            selected_sources.array()
            )

    Template.user_kout.events
        'keyup .new_debit': (e,t)->
            if e.which is 13
                val = $('.new_debit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'debit'
                    body: val
                    target_user_id: target_user._id



    Template.user_kout.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:1
                limit:20

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_kout', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'debit'
            _author_id: user._id
        }, 
            limit:100
            sort:_timestamp:-1