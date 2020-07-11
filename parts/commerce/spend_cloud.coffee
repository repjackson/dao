if Meteor.isClient
    Template.gift_cloud.events
        'click .set_today': -> Session.set('date_setting','today')
        'click .set_yesterday': -> Session.set('date_setting','yesterday')
        'click .set_this_month': -> Session.set('date_setting','set_this_month')
        'click .set_all_time': -> Session.set('date_setting','all_time')
        'click .unselect_tag': ->
            selected_tags.remove @valueOf()
            console.log selected_tags.array()
            if selected_tags.array().length is 1
                Meteor.call 'call_wiki', selected_tags.array(), ->
                Meteor.call 'calc_term', @title, ->

            if selected_tags.array().length > 0
                Meteor.call 'search_reddit', selected_tags.array(), ->
                    Session.set('dummy', !Session.get('dummy'))

        'click .select_location_tag': ->
            selected_location_tags.push @title
        'click .unselect_location_tag': ->
            selected_location_tags.remove @valueOf()
            # console.log selected_tags.array()

        'click .clear_selected_tags': ->
            Session.set('current_query','')
            selected_tags.clear()
        # 'keyup #search': _.throttle((e,t)->
        'keydown #search': (e,t)->
            query = $('#search').val()
            # Session.set('current_query', query)
            # if query.length > 0
            #     Session.set('searching', true)
            # else
            #     Session.set('searching', false)
            Session.set('current_query', query)
            # if query.length > 0
            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    selected_tags.push search
                    console.log 'search', search

                    $('#search').val('')
                    Session.set('current_query', '')
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 6000
        # , 200)
        'click .reconnect': -> Meteor.reconnect()

        'click .toggle_tag': (e,t)-> selected_tags.push @valueOf()
        'click .toggle_author': (e,t)-> selected_authors.push @author
        'click .toggle_location_tag': (e,t)-> selected_location_tags.push @location_tag

        'keyup .add_tag': (e,t)->
            # Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.which is 13
                tag = $(e.currentTarget).closest('.add_tag').val().trim().toLowerCase()
                console.log 'tag', tag
                # search = $('#search').val()
                if tag.length > 0
                    # selected_tags.push search
                    Docs.update @_id,
                        $addToSet:
                            tags:tag
                            user_tags:tag
                    $(e.currentTarget).closest('.add_tag').val('')
                    # # console.log 'search', search
                    Meteor.call 'call_wiki', tag, =>
                        Meteor.call 'log_term', tag, ->

        # 'click .vote_up': (e,t)->
        #     Docs.update @_id,
        #         $inc:points:1
        #
        #
        # 'click .vote_down': (e,t)->
        #     Docs.update @_id,
        #         $inc:points:-1

        'click .print_me': (e,t)->
            console.log @


    Template.gift_cloud.helpers
        curent_date_setting: -> Session.get('date_setting')

        is_loading: -> Session.get('is_loading')

        tag_result_class: ->
            # ec = omega.emotion_color
            # console.log @
            # console.log omega.total_doc_result_count
            total_doc_result_count = Docs.find({}).count()
            console.log total_doc_result_count
            percent = @count/total_doc_result_count
            # console.log 'percent', percent
            # console.log typeof parseFloat(@relevance)
            # console.log typeof (@relevance*100).toFixed()
            whole = parseInt(percent*10)+1
            # console.log 'whole', whole

            # if whole is 0 then "#{ec} f5"
            if whole is 0 then "f5"
            else if whole is 1 then "f11"
            else if whole is 2 then "f12"
            else if whole is 3 then "f13"
            else if whole is 4 then "f14"
            else if whole is 5 then "f15"
            else if whole is 6 then "f16"
            else if whole is 7 then "f17"
            else if whole is 8 then "f18"
            else if whole is 9 then "f19"
            else if whole is 10 then "f20"


        connection: ->
            # console.log Meteor.status()
            Meteor.status()
        connected: -> Meteor.status().connected

        location_tag_results: ->
            Location_tag_results.find({},
                limit:10
                sort:
                    count:-1
            )
        selected_location_tags: -> selected_location_tags.array()


        gift_tag_results: ->
            # console.log Session.get('current_query')
            # if Session.get('current_query')
            if Session.get('searching')
                console.log 'current query', Session.get('current_query')
                # if Session.get('current_query').length > 0
                Terms.find({},
                    limit:5
                    sort:
                        count:-1
                )
            else
                # doc_count = Docs.find().count()
                # console.log 'doc count', doc_count
                # if doc_count < 3
                #     Tags.find({count: $lt: doc_count})
                # else
                Tags.find({})

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        selected_tags: -> selected_tags.array()

        selected_tags_plural: -> selected_tags.array().length > 1

        searching: -> Session.get('searching')

        one_post: -> Docs.find().count() is 1

        two_posts: -> Docs.find().count() is 2
        three_posts: -> Docs.find().count() is 3
        four_posts: -> Docs.find().count() is 4
        # five_posts: -> Docs.find().count() is 5
        # six_posts: -> Docs.find().count() is 6
        # seven_posts: -> Docs.find().count() is 7
        # eight_posts: -> Docs.find().count() is 8
        # nine_posts: -> Docs.find().count() is 9
        # ten_posts: -> Docs.find().count() is 10
        # more_than_ten: -> Docs.find().count() > 10
        more_than_four: -> Docs.find().count() > 4
        one_result: ->
            Docs.find().count() is 1

        docs: ->
            # if selected_tags.array().length > 0
            cursor =
                Docs.find {
                    model:['reddit','wikipedia']
                },
                    sort:
                        points:-1
                        ups:-1
                    # limit:10
            # console.log cursor.fetch()
            cursor

        term: ->
            # console.log @
            Terms.findOne
                title:@valueOf()

        home_subs_ready: ->
            Template.instance().subscriptionsReady()
        #
        # home_subs_ready: ->
        #     if Template.instance().subscriptionsReady()
        #         Session.set('global_subs_ready', true)
        #     else
        #         Session.set('global_subs_ready', false)
