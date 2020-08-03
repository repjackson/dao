if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'

    Template.home.onRendered ->
        $('.progress').progress({
              percent: 22
        });
    
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'latest_debits'
        
        @autorun => Meteor.subscribe 'model_docs', 'request'
        @autorun => Meteor.subscribe 'model_docs', 'shift'
        @autorun => Meteor.subscribe 'model_docs', 'comment'
        @autorun => Meteor.subscribe 'model_docs', 'event'
        @autorun => Meteor.subscribe 'model_docs', 'post'
        @autorun => Meteor.subscribe 'model_docs', 'global_stats'
        @autorun => Meteor.subscribe 'all_users'
        @autorun -> Meteor.subscribe('home_tag_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )
        @autorun -> Meteor.subscribe('home_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )
        @autorun => Meteor.subscribe 'model_docs', 'home_doc'

    Template.home.helpers
        viewing_finance_details: -> Session.get('view_finance_details')
        featured_products: ->
            Docs.find
                model:'product'
        home_doc: ->
            Docs.findOne 
                model:'home_doc'
        stats_doc: ->
            Docs.findOne 
                model:'global_stats'
        can_debit: ->
            Meteor.user().points > 0
        stewards: ->
            Meteor.users.find
                levels:$in:['steward']
        latest_debits: ->
            Docs.find {
                model:'debit'
                submitted:true
            },
                sort:
                    _timestamp: -1
                limit:10
        latest_posts: ->
            Docs.find {
                model:'post'
            },
                sort:
                    _timestamp: -1
                limit:10
        latest_requests: ->
            Docs.find {
                model:'request'
            },
                sort:
                    _timestamp: -1
                limit:10
        next_events: ->
            Docs.find {
                model:'event'
            },
                sort:
                    _timestamp: -1
                limit:10
        next_shifts: ->
            Docs.find {
                model:'shift'
            },
                sort:
                    _timestamp: -1
                limit:10
        debits: ->
            Docs.find
                model:'debit'
        members: ->
            Meteor.users.find({},
                sort:points:1)
    Template.home.events
        'click .view_debit': ->
            Router.go "/debit/#{@_id}/view"
        'click .view_request': ->
            Router.go "/request/#{@_id}/view"
    
        'click .toggle_finance_details': ->
            Session.set('view_finance_details', !Session.get('view_finance_details'))

        'click .refresh_stats': ->
            Meteor.call 'calc_global_stats'
        'click .debit': ->
            new_debit_id =
                Docs.insert
                    model:'debit'
            Router.go "/debit/#{new_debit_id}/edit"
        'click .request': ->
            new_request_id =
                Docs.insert
                    model:'request'
            Router.go "/request/#{new_request_id}/edit"

        'keydown .find_username': (e,t)->
            # email = $('submit_email').val()
            if e.which is 13
                email = $('.submit_email').val()
                if email.length > 0
                    Docs.insert
                        model:'email_signup'
                        email_address:email
                    $('body')
                      .toast({
                        class: 'success'
                        position: 'top right'
                        message: "#{email} added to list"
                      })
                    $('.submit_email').val('')




    # Template.home_card.events
    #     'click .record_home': ->
    #         Meteor.users.update Meteor.userId(),
    #             $inc: points:-@points
    #         $('body').toast({
    #             class: 'info',
    #             message: "#{@points} spent"
    #         })
    #         Docs.insert
    #             model:'home_item'
    #             parent_id: @_id
