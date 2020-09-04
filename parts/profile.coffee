if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'

    @selected_love_tags = new ReactiveArray []

    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe('love_tags',
            Session.get('query')
            selected_love_tags.array()
            Router.current().params.username
            )
        @autorun -> Meteor.subscribe('love_docs',
            Session.get('query')
            selected_love_tags.array()
            Router.current().params.username
            )

    
    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
    
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.profile_nav_item')
                .popup()
        , 1000
        user = Meteor.users.findOne(username:Router.current().params.username)
        # Meteor.call 'calc_user_stats', user._id, ->
        Meteor.setTimeout ->
            if user
                Meteor.call 'calc_user_stats', user._id, ->
                Meteor.call 'calc_authored_tags', user._id, ->
                Meteor.call 'calc_upvoted_tags', user._id, ->
        , 2000


    Template.user_dashboard.events
        'click .select_tag': ->
            console.log @
            Meteor.call 'call_wiki', @name, ->
            Meteor.call 'search_reddit', @name, ->
                
            selected_tags.push @name
            Router.go '/'

    Template.user_dashboard.helpers
        love_results: ->
            love_results.find()
    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: -> Meteor.users.findOne username:Router.current().params.username

    Template.profile_layout.events
        'click a.select_term': ->
            $('.profile_yield')
                .transition('fade out', 200)
                .transition('fade in', 200)
    
        'click .refresh_user_stats': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            # Meteor.call 'calc_user_stats', user._id, ->
            # Meteor.call 'calc_user_stats', user._id, ->
            # Meteor.call 'calc_user_tags', user._id, ->
            Meteor.call 'calc_authored_tags', user._id, ->
            Meteor.call 'calc_upvoted_tags', user._id, ->

    Template.profile_layout.events
        'click .send': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            if Meteor.userId() is user._id
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        price:1
            else
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        price:1
                        seller_id: user._id
            Router.go "/debit/#{new_debit_id}/edit"


        'click .tip': ->
            # user = Meteor.users.findOne(username:@username)
            new_debit_id =
                Docs.insert
                    model:'dollar_debit'
            Router.go "/dollar_debit/#{new_debit_id}/edit"

        'click .request': ->
            user = Meteor.users.findOne(username:@username)
            if Meteor.userId() is user._id
                new_id =
                    Docs.insert
                        model:'request'
                        price:1
            else    
                new_id =
                    Docs.insert
                        model:'request'
                        buyer_id: user._id
                        price:1
            Router.go "/request/#{new_id}/edit"
    
        # 'click .calc_user_cloud': ->
        #     Meteor.call 'calc_user_cloud', Router.current().params.username, ->

        'click .logout': ->
            # Router.go '/login'
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false





if Meteor.isServer
    Meteor.publish 'love_docs', (
        query=''
        selected_tags
        target_username
        )->
            
        target_user = Meteor.users.findOne username:target_username    
            
        match = {}
        match.model = 'post'
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0
            match.tags = $all:selected_tags
        # if selected_authors.length > 0
        #     match._author_username = $all:selected_authors
        # match._author_id = $in:[Meteor.userId(), target_user._id]
        match.upvoter_ids = $all:[Meteor.userId(), target_user._id]
        console.log match
        Docs.find match,
            limit:20
            sort:points:-1
                        
                        
    Meteor.publish 'love_tags', (
        query=''
        selected_tags
        target_username
        limit=20
        )->
        self = @
        match = {}
        # match.model = $in:['post','alpha']
        match.model = 'post'
        
        target_user = Meteor.users.findOne username:target_username    

        
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # match._author_id = $in:[Meteor.userId(), target_user._id]
        match.upvoter_ids = $all:[Meteor.userId(), target_user._id]

        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        tag_cloud.forEach (tag, i) ->
            self.added 'love_results', Random.id(),
                name: tag.name
                count: tag.count
                index: i
       
        self.ready()
                            
    Meteor.methods
        # calc_test_sessions: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     now = Date.now()
        #     console.log now
        #     past_24_hours = now-(24*60*60*1000)
        #     past_week = now-(7*24*60*60*1000)
        #     past_month = now-(30*7*24*60*60*1000)
        #     console.log past_24_hours
        #     all_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             }).count()
        #     todays_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_24_hours
        #             }).count()
        #     weeks_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_week
        #             }).count()
        #     months_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_month
        #             }).count()
        #     console.log 'all session count', all_sessions_count
        #     console.log 'today sessions count', todays_sessions_count
        #     Meteor.users.update user_id,
        #         $set:
        #             all_sessions_count:all_sessions_count
        #             todays_sessions_count: todays_sessions_count
        #             weeks_sessions_count: weeks_sessions_count
        #             months_sessions_count: months_sessions_count

        #     # this_week = moment().startOf('isoWeek')
        #     # this_week = moment().startOf('isoWeek')


        # calc_user_act_stats: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     test_session_cursor =
        #         Docs.find
        #             model:'test_session'
        #             _author_id: user_id
        #     site_test_cursor =
        #         Docs.find(
        #             model:'test'
        #         )
        #     site_test_count = site_test_cursor.count()
        #     answered_tests = 0
        #     for test in site_test_cursor.fetch()
        #         user_test_session =
        #             Docs.findOne
        #                 model:'test_session'
        #                 test_id: test._id
        #                 _author_id:username
        #         if user_test_session
        #             answered_tests++
        #     console.log 'answered tests', answered_tests
        #     global_section_percent = 0

        #     session_count = test_session_cursor.count()
        #     for section in ['english', 'math', 'science', 'reading']
        #         section_test_cursor =
        #             Docs.find {
        #                 model:'test'
        #                 tags: $in: [section]
        #             }
        #         section_count = section_test_cursor.count()
        #         section_tests = section_test_cursor.fetch()
        #         section_test_ids = []
        #         for section_test in section_tests
        #             section_test_ids.push section_test._id

        #         # console.log section
        #         # console.log section_test_ids
        #         user_section_test_sessions =
        #             Docs.find {
        #                 model:'test_session'
        #                 test_id: $in: section_test_ids
        #                 _author_id: user_id
        #             }
        #         # console.log user_section_test_sessions.fetch()
        #         user_section_test_session_count = user_section_test_sessions.count()
        #         total_section_average = 0
        #         for test_session in user_section_test_sessions.fetch()
        #             if test_session.correct_percent
        #                 total_section_average += parseInt(test_session.correct_percent)
        #         user_section_average = total_section_average/user_section_test_session_count
        #         # console.log 'user section average', section, user_section_average
        #         if user_section_average
        #             Meteor.users.update user_id,
        #                 $set:
        #                     "#{section}_average": user_section_average.toFixed()
        #             global_section_percent += user_section_average
        #         else
        #             Meteor.users.update user_id,
        #                 $set:
        #                     "#{section}_average": 0
        #     site_percent_complete = parseInt((answered_tests/site_test_count)*100)
        #     global_section_average = global_section_percent/4



        #     Meteor.users.update user_id,
        #         $set:
        #             session_count:session_count
        #             site_percent_complete:site_percent_complete
        #             global_section_average:global_section_average.toFixed()


        #     section_average_ranking =
        #         Meteor.users.find(
        #             {},
        #             sort:
        #                 global_section_average: -1
        #             fields:
        #                 username: 1
        #         ).fetch()
        #     section_average_ranking_ids = _.pluck section_average_ranking, '_id'

        #     console.log 'section average ranking', section_average_ranking
        #     console.log 'section average ranking ids', section_average_ranking_ids
        #     my_rank = _.indexOf(section_average_ranking_ids, user_id)+1
        #     console.log 'my rank', my_rank
        #     Meteor.users.update user_id,
        #         $set:
        #             global_section_average_rank:my_rank


        #     # average_english_percent
        #     # average_math_percent
        #     # average_science_percent
        #     # average_reading_percent


        # calc_user_cloud: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     test_session_cursor =
        #         Docs.find
        #             model:'test_session'
        #             _author_id: user_id
        #             right_tags: $exists: true
        #     all_right_tags = []
        #     all_wrong_tags = []
        #     right_tag_list = []
        #     wrong_tag_list = []
        #     right_tag_cloud = []
        #     wrong_tag_cloud = []

        #     for test_session in test_session_cursor.fetch()
        #         for right_tag in test_session.right_tags
        #             unless right_tag in right_tag_list
        #                 right_tag_list.push right_tag
        #             all_right_tags.push right_tag
        #             tag_object = _.findWhere(right_tag_cloud, {tag: right_tag})
        #             # console.log tag_object
        #             if tag_object
        #                 index_of_tag = _.indexOf(right_tag_cloud, tag_object)
        #                 # console.log 'index of tag', index_of_tag
        #                 tag_count = tag_object.count
        #                 # console.log tag_count
        #                 # console.log 'inc', tag_count++
        #                 right_tag_cloud[index_of_tag] = {
        #                     tag:right_tag
        #                     count:tag_count+1
        #                 }
        #             else
        #                 tag_object = {
        #                     tag:right_tag
        #                     count: 1
        #                 }
        #                 right_tag_cloud.push tag_object
        #         for wrong_tag in test_session.wrong_tags
        #             unless wrong_tag in wrong_tag_list
        #                 wrong_tag_list.push wrong_tag
        #             all_wrong_tags.push wrong_tag
        #             tag_object = _.findWhere(wrong_tag_cloud, {tag: wrong_tag})
        #             # console.log tag_object
        #             if tag_object
        #                 index_of_tag = _.indexOf(wrong_tag_cloud, tag_object)
        #                 # console.log 'index of tag', index_of_tag
        #                 tag_count = tag_object.count
        #                 # console.log tag_count
        #                 # console.log 'inc', tag_count++
        #                 wrong_tag_cloud[index_of_tag] = {
        #                     tag:wrong_tag
        #                     count:tag_count+1
        #                 }
        #             else
        #                 tag_object = {
        #                     tag:wrong_tag
        #                     count: 1
        #                 }
        #                 wrong_tag_cloud.push tag_object
        #     # console.log right_tag_cloud
        #     right_tag_cloud =  _.sortBy(right_tag_cloud, 'count')
        #     wrong_tag_cloud = _.sortBy(wrong_tag_cloud, 'count')
        #     right_tag_cloud = right_tag_cloud.reverse()
        #     wrong_tag_cloud = wrong_tag_cloud.reverse()
        #     right_tag_cloud = right_tag_cloud[..10]
        #     wrong_tag_cloud = wrong_tag_cloud[..10]
        #     # right_tag_cloud = _.countBy(all_right_tags, (tag)-> tag)
        #     # wrong_tag_cloud = _.countBy(all_wrong_tags, (tag)-> tag)

        #     Meteor.users.update user_id,
        #         $set:
        #             right_tag_list:right_tag_list
        #             wrong_tag_list:wrong_tag_list
        #             right_tag_cloud:right_tag_cloud
        #             wrong_tag_cloud:wrong_tag_cloud



        calc_user_stats: (user_id)->
            user = Meteor.users.findOne user_id
            unless user
                user = Meteor.users.findOne username
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

            debits = Docs.find({
                model:'debit'
                price:$exists:true
                _author_id:user_id})
            debit_count = debits.count()
            total_debit_price = 0
            for debit in debits.fetch()
                total_debit_price += debit.price

            console.log 'total debit price', total_debit_price
           
           
           
            authored_posts = Docs.find({
                model:'post'
                _author_id:user_id})
            authored_count = authored_posts.count()
            total_authored_points = 0
            for post in authored_posts.fetch()
                total_authored_points += post.points

            console.log 'total authored points', total_authored_points
            
            
            upvoted_posts = Docs.find({
                model:'post'
                upvoter_ids:$in:[user_id]})
            upvoted_count = upvoted_posts.count()
            total_upvoted_points = 0
            for post in upvoted_posts.fetch()
                total_upvoted_points += post.points

            console.log 'total upvoted points', total_upvoted_points

            # fulfilled_requests = Docs.find({
            #     model:'request'
            #     price:$exists:true
            #     claimed_user_id:user_id
            #     complete:true
            # })
            # fulfilled_count = fulfilled_requests.count()
            # total_fulfilled_price = 0
            # for fulfilled in fulfilled_requests.fetch()
            #     total_fulfilled_price += fulfilled.price
            
            
            # requested = Docs.find({
            #     model:'request'
            #     price:$exists:true
            #     _author_id:user_id
            #     published:true
            # })
            # authored_count = requested.count()
            # total_request_cost = 0
            # for request in requested.fetch()
            #     total_request_cost += request.price
            
            
            credits = Docs.find({
                model:'debit'
                price:$exists:true
                seller_id:user_id})
            credit_count = credits.count()
            total_credit_price = 0
            for credit in credits.fetch()
                total_credit_price += credit.price
            console.log 'total credit price', total_credit_price



            comments = Docs.find({
                model:'comment'
                _author_id:Meteor.userId()
            })
            comment_count = comments.count()
            total_comment_cost = 0
            # for comment in comments.fetch()
            #     total_comment_price += comment.price

            console.log 'total credit price', total_credit_price
            
            
            # calculated_user_balance = total_credit_price-total_debit_price-comment_count

            # average_credit_per_student = total_credit_price/student_count
            # average_debit_per_student = total_debit_price/student_count
            flow_volume = Math.abs(total_credit_price)+Math.abs(total_debit_price)
            # flow_volume += total_fulfilled_price
            # flow_volume += total_request_cost
            
            
            tipped_cur = 
                Docs.find
                    model:'tip'
                    _author_id:user_id
            tipped_count = tipped_cur.count()
            
            received_tips_cur = 
                Docs.find
                    model:'tip'
                    _author_id:user_id
                
            received_tips_count = received_tips_cur.count()
            
            
            topups = 
                Docs.find
                    model:'topup'
                    _author_id:user_id
            
            total_topup_price = 0        
            for topup in topups.fetch()
                total_topup_price += topup.amount*100
                console.log 'adding', topup.amount
            # points = total_credit_price-total_debit_price+total_fulfilled_price-total_request_cost+total_topup_price-comment_count-(tipped_count*11)+(received_tips_count*10)
            points = total_credit_price-total_debit_price+total_topup_price-comment_count-(tipped_count*11)+(received_tips_count*10)
            # points = total_credit_price-total_debit_price+total_fulfilled_price-total_request_cost
            # points += total_fulfilled_price
            # points =- total_request_cost
            
            if total_debit_price is 0 then total_debit_price++
            if total_credit_price is 0 then total_credit_price++
            # debit_credit_ratio = total_debit_price/total_credit_price
            unless total_debit_price is 1
                unless total_credit_price is 1
                    one_ratio = total_debit_price/total_credit_price
                else
                    one_ratio = 0
            else
                one_ratio = 0
                    
            # dc_ratio_inverted = 1/debit_credit_ratio

            # credit_debit_ratio = total_credit_price/total_debit_price
            # cd_ratio_inverted = 1/credit_debit_ratio

            # one_score = total_bandwith*dc_ratio_inverted

            Meteor.users.update user_id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_price: total_credit_price
                    total_debit_price: total_debit_price
                    flow_volume: flow_volume
                    points:points
                    credit:points/100
                    one_ratio: one_ratio
                    total_authored_points:total_authored_points    
                    # total_fulfilled_price:total_fulfilled_price
                    # fulfilled_count:fulfilled_count
                    tipped_count:tipped_count
                    received_tips_count:received_tips_count
                    comment_count:comment_count