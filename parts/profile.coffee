if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:username/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:username/contact', (->
        @layout 'profile_layout'
        @render 'user_contact'
        ), name:'user_contact'


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
                Meteor.call 'recalc_one_stats', user._id, ->
        , 2000


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
            Meteor.call 'recalc_one_stats', user._id, ->
            Meteor.call 'calc_user_tags', user._id, ->
    
    Template.profile_layout.events
        'click .send': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            if Meteor.userId() is user._id
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        amount:1
            else
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        amount:1
                        recipient_id: user._id
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
                        amount:1
            else    
                new_id =
                    Docs.insert
                        model:'request'
                        recipient_id: user._id
                        amount:1
            Router.go "/request/#{new_id}/edit"
    
        # 'click .recalc_user_cloud': ->
        #     Meteor.call 'recalc_user_cloud', Router.current().params.username, ->

        'click .logout': ->
            # Router.go '/login'
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false





if Meteor.isServer
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


        # recalc_user_act_stats: (user_id)->
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


        # recalc_user_cloud: (user_id)->
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



        recalc_one_stats: (user_id)->
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
                amount:$exists:true
                _author_id:user_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            console.log 'total debit amount', total_debit_amount

            fulfilled_requests = Docs.find({
                model:'request'
                point_bounty:$exists:true
                claimed_user_id:user_id
                complete:true
            })
            fulfilled_count = fulfilled_requests.count()
            total_fulfilled_amount = 0
            for fulfilled in fulfilled_requests.fetch()
                total_fulfilled_amount += fulfilled.point_bounty
            
            
            requested = Docs.find({
                model:'request'
                point_bounty:$exists:true
                _author_id:user_id
                published:true
            })
            authored_count = requested.count()
            total_request_amount = 0
            for request in requested.fetch()
                total_request_amount += request.point_bounty
            
            
            credits = Docs.find({
                model:'debit'
                amount:$exists:true
                recipient_id:user_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            console.log 'total credit amount', total_credit_amount
            calculated_user_balance = total_credit_amount-total_debit_amount

            # average_credit_per_student = total_credit_amount/student_count
            # average_debit_per_student = total_debit_amount/student_count
            flow_volume = Math.abs(total_credit_amount)+Math.abs(total_debit_amount)
            flow_volumne =+ total_fulfilled_amount
            flow_volumne =+ total_request_amount
            
            
            points = total_credit_amount-total_debit_amount+total_fulfilled_amount-total_request_amount
            # points =+ total_fulfilled_amount
            # points =- total_request_amount
            
            if total_debit_amount is 0 then total_debit_amount++
            if total_credit_amount is 0 then total_credit_amount++
            # debit_credit_ratio = total_debit_amount/total_credit_amount
            unless total_debit_amount is 1
                unless total_credit_amount is 1
                    one_ratio = total_debit_amount/total_credit_amount
                else
                    one_ratio = 0
            else
                one_ratio = 0
                    
            # dc_ratio_inverted = 1/debit_credit_ratio

            # credit_debit_ratio = total_credit_amount/total_debit_amount
            # cd_ratio_inverted = 1/credit_debit_ratio

            # one_score = total_bandwith*dc_ratio_inverted

            Meteor.users.update user_id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    flow_volume: flow_volume
                    points:points
                    one_ratio: one_ratio
                    total_fulfilled_amount:total_fulfilled_amount
                    fulfilled_count:fulfilled_count