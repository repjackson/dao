Meteor.methods
    log_view: (doc_id)->
        Docs.update doc_id,
            $inc:views:1

    

    # import_tests: ->
    #     # myobject = HTTP.get(Meteor.absoluteUrl("/public/tests.json")).data;
    #     myjson = JSON.parse(Assets.getText("tests.json"));
    #     console.log myjson
    # add_message: (body,classroom_id)->
    #     new_message_id = Docs.insert
    #         body: body
    #         model: 'message'
    #         classroom_id: classroom_id
    #         read_ids:[Meteor.userId()]
    #         tags: ['chat', 'message']

    #     chat_doc = Docs.findOne _id: classroom_id
    #     message_doc = Docs.findOne new_message_id
    #     message_author = Meteor.users.findOne message_doc.author_id

        # message_link = "https://www.joyful-giver.com/chat"

        # this.unblock()

        # offline_ids = []
        # for participant_id in chat_doc.participant_ids
        #     user = Meteor.users.findOne participant_id
        #     if user.status.online is true
        #     else
        #         offline_ids.push user._id


        # for offline_id in offline_ids
        #     offline_user = Meteor.users.findOne offline_id

        #     Email.send
        #         to: " #{offline_user.profile.first_name} #{offline_user.profile.last_name} <#{offline_user.emails[0].address}>",
        #         from: "Joyful Giver Admin <no-reply@joyful-giver.com>",
        #         subject: "New Message from #{message_author.profile.first_name} #{message_author.profile.last_name}",
        #         html:
        #             "<h4>#{message_author.profile.first_name} just sent the following message while you were offline: </h4>
        #             #{body} <br><br>

        #             Click <a href=#{message_link}> here to view.</a><br><br>
        #             You can unsubscribe from this chat in the Actions panel.
        #             "

                # html:
                #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
                #     #{text} <br>
                #     In chat with tags: #{chat_doc.tags}. \n
                #     In chat with description: #{chat_doc.description}. \n
                #     \n
                #     Click <a href="/view/#{_id}"
                # "
        # return new_message_id


    add_user: (username)->
        options = {}
        options.username = username
        options.levels = ['explorer']

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'


    change_username:  (user_id, new_username) ->
        user = Meteor.users.findOne user_id
        Accounts.setUsername(user._id, new_username)
        return "Updated Username to #{new_username}."


    add_email: (user_id, new_email) ->
        Accounts.addEmail(user_id, new_email);
        Accounts.sendVerificationEmail(user_id, new_email)
        return "updated Email to #{new_email}"

    remove_email: (user_id, email)->
        # user = Meteor.users.findOne username:username
        Accounts.removeEmail user_id, email


    verify_email: (user_id, email)->
        user = Meteor.users.findOne user_id
        console.log 'sending verification', user.username
        Accounts.sendVerificationEmail(user_id, email)

    validate_email: (email) ->
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        test_result = re.test String(email)
        console.log email
        console.log test_result
        test_result

    notify_message: (message_id)->
        message = Docs.findOne message_id
        if message
            to_user = Meteor.users.findOne message.to_user_id
    
            message_link = "https://www.oneriverside.app/user/#{to_user.username}/messages"
    
        	Email.send({
                to:["<#{to_user.emails[0].address}>"]
                from:"relay@dao.af"
                subject:"One message from #{message._author_username}"
                html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
                    "<br><h4>view your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
            })

    checkout_students: ()->
        now = Date.now()
        # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()
        checkedin_sessions = Docs.find(
            model:'healthclub_session',
            active:true
            garden_key:$ne:true
            ).fetch()


        for session in checkedin_sessions
            # checkedin_doc =
            #     Docs.findOne
            #         user_id:student._id
            #         model:'healthclub_checkin'
            #         active:true
            diff = now-session._timestamp
            minute_difference = diff/1000/60
            if minute_difference>60
                # Meteor.users.update(student._id,{$set:healthclub_checkedin:false})
                Docs.update session._id,
                    $set:
                        active:false
                        logout_timestamp:Date.now()
                # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()



    lookup_user: (username_query, role_filter)->
        if role_filter
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                roles:$in:[role_filter]
                },{
                    limit:10
                    fields:
                        _id:1
                        username:1
                        profile_image_id:1
                    }).fetch()
        else
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                },{
                    fields:
                        _id:1
                        username:1
                        profile_image_id:1
                    limit:10
                    }).fetch()
    # lookup_user: (username_query, role_filter)->
    #     if role_filter
    #         Meteor.users.find({
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             roles:$in:[role_filter]
    #             },{limit:10}).fetch()
    #     else
    #         Meteor.users.find({
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             },{limit:10}).fetch()


    lookup_doc: (guest_name, model_filter)->
        Docs.find({
            model:model_filter
            guest_name: {$regex:"#{guest_name}", $options: 'i'}
            },{limit:10}).fetch()


    lookup_earn_list: (title)->
        Docs.find({
            model:'earn_list'
            title: {$regex:"#{title}", $options: 'i'}
            }).fetch()

    # lookup_username: (username_query)->
    #     found_users =
    #         Docs.find({
    #             model:'person'
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             }).fetch()
    #     found_users

    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people


    set_password: (user_id, new_password)->
        Accounts.setPassword(user_id, new_password)


    keys: (specific_key)->
        start = Date.now()

        if specific_key
            cursor = Docs.find({
                "#{specific_key}":$exists:true
                _keys:$exists:false
                }, { fields:{_id:1} })
        else
            cursor = Docs.find({
                _keys:$exists:false
            }, { fields:{_id:1}, limit:1000 })

        found = cursor.count()

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

        stop = Date.now()

        diff = stop - start

    key: (doc_id)->
        doc = Docs.findOne doc_id
        keys = _.keys doc
        console.log 'keying', doc_id, doc.title
        light_fields = _.reject( keys, (key)-> key.startsWith '_' )

        Docs.update doc._id,
            $set:_keys:light_fields


    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()




    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id


    add_seller_username: ->
        cur = 
            Docs.find(
                seller_id:$exists:true
                seller_username:$exists:false
            )
        console.log cur.count()
        # old_count = Docs.find({"#{old}":$exists:true}).count()
        # new_count = Docs.find({"#{newk}":$exists:true}).count()
        # result = Docs.update({recipient_id:$exists:true}, {$rename:"recipient_id":"seller_id"}, {multi:true})
        for doc in cur.fetch()
            seller = 
                Meteor.users.findOne doc.seller_id
            if seller
                Docs.update doc._id,
                    $set:seller_username:seller.username
                # console.log seller
    update_debits: (old, newk)->
        cur = 
            Docs.find(
                model:'debit'
                # recipient_id:$exists:true
                # buyer_id:$exists:false
                # amount:$exists:true
                title:$exists:false
            )
        console.log cur.count()
        # old_count = Docs.find({"#{old}":$exists:true}).count()
        # new_count = Docs.find({"#{newk}":$exists:true}).count()
        # result = Docs.update({buyer_id:$exists:false}, {$rename:"recipient_id":"seller_id"}, {multi:true})
        # result = Docs.update({recipient_id:$exists:true}, {$rename:"recipient_id":"seller_id"})
        # result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        # cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cur.fetch()
            Docs.update doc._id,
                $rename:
                    # amount:"price"
                    description:"title"

        # for doc in cur.fetch()
        #     buyer = 
        #         Meteor.users.findOne doc._author_id
        #     if buyer
        #         Docs.update doc._id,
        #             $set:
        #                 buyer_id:buyer._id
        #                 buyer_username:buyer.username




    send_enrollment_email: (user_id, email)->
        user = Meteor.users.findOne(user_id)
        console.log 'sending enrollment email to username', user.username
        Accounts.sendEnrollmentEmail(user_id)

    calc_user_tags: (user_id)->
        debit_tags = Meteor.call 'omega', user_id, 'debit'
        # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
        # console.log res
        # console.log 'res from async agg'
        Meteor.users.update user_id, 
            $set:
                debit_tags:debit_tags

        credit_tags = Meteor.call 'omega', user_id, 'credit'
        # console.log res
        # console.log 'res from async agg'
        Meteor.users.update user_id, 
            $set:
                credit_tags:credit_tags


    omega: (user_id, direction)->
        user = Meteor.users.findOne user_id
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        match.model = 'debit'
        if direction is 'debit'
            match._author_id = user_id
        if direction is 'credit'
            match.recipient_id = user_id

        # console.log 'found debits', Docs.find(match).count()
        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        # limit = 10
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
                # printed = console.log(agg.toArray())
                # console.log(agg.toArray())
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null    
            
            
    calc_authored_tags: (user_id)->
        authored_tags = Meteor.call 'aomega', user_id
        # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
        # console.log 'authored tags', authored_tags
        # console.log 'res from async agg'
        Meteor.users.update user_id, 
            $set:
                authored_tags:authored_tags


    aomega: (user_id)->
        user = Meteor.users.findOne user_id
        console.log 'finding authored posts for ', user_id
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        match.model = 'post'
        match._author_id = user_id
        
        # console.log 'found authored posts', Docs.find(match).count()
        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        # limit = 10
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                # console.log(agg.toArray())
                agg.toArray()
                # printed = console.log(agg.toArray())
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null    
            
    calc_upvoted_tags: (user_id)->
        upvoted_tags = Meteor.call 'uomega', user_id
        # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
        # console.log 'upvoted tags', upvoted_tags
        # console.log 'res from async agg'
        upvoted_count = 
            Docs.find(
                model:'vote'
                _author_id:Meteor.userId()
            ).count()
        console.log upvoted_count
        
        Meteor.users.update user_id, 
            $set:
                upvoted_tags:upvoted_tags
                upvoted_count:upvoted_count


    uomega: (user_id)->
        user = Meteor.users.findOne user_id
        # console.log 'finding upvoted posts for ', user_id
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        match.model = 'post'
        match.upvoter_ids = $in:[user_id]
        
        # console.log 'found upvoted posts', Docs.find(match).count()
        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        # limit = 10
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                # console.log(agg.toArray())
                agg.toArray()
                # printed = console.log(agg.toArray())
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null    
            
            
    calc_credit_tags: (user_id)->
        credit_tags = Meteor.call 'credit_omega', user_id
        # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
        # console.log 'upvoted tags', upvoted_tags
        # console.log 'res from async agg'
        Meteor.users.update user_id, 
            $set:
                credit_tags:credit_tags


    credit_omega: (user_id)->
        user = Meteor.users.findOne user_id
        # console.log 'finding upvoted posts for ', user_id
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        match.model = 'debit'
        match.seller_id = user_id
        
        # console.log 'found credited posts', Docs.find(match).count()
        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        # limit = 10
        # console.log 'credit omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                # console.log(agg.toArray())
                agg.toArray()
                # printed = console.log(agg.toArray())
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null
            
            
                        
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
       
        votes = Docs.find({
            model:'vote'
            points:$exists:true
            _author_id:user_id})
        vote_count = votes.count()
        total_vote_cost = 0
        for vote in votes.fetch()
            absolute = Math.abs(vote.points)
            total_vote_cost += absolute

        console.log 'total vote cost', total_vote_cost
       
       
       
        imported_points = Docs.find({
            model:'post'
            imported_points:$exists:true
            _author_id:user_id})
        imported_count = imported_points.count()
        total_imported_points = 0
        for imported in imported_points.fetch()
            total_imported_points += imported.imported_points

        console.log 'total imported points', total_imported_points
       
       
       
        # authored_posts = Docs.find({
        #     model:'post'
        #     _author_id:user_id})
        # authored_count = authored_posts.count()
        # total_authored_points = 0
        # for post in authored_posts.fetch()
        #     total_authored_points += post.points

        # console.log 'total authored points', total_authored_points
        
        
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



        # comments = Docs.find({
        #     model:'comment'
        #     _author_id:Meteor.userId()
        # })
        # comment_count = comments.count()
        # total_comment_cost = 0
        # # for comment in comments.fetch()
        # #     total_comment_price += comment.price

        # console.log 'total credit price', total_credit_price
        
        
        # calculated_user_balance = total_credit_price-total_debit_price-comment_count

        # average_credit_per_student = total_credit_price/student_count
        # average_debit_per_student = total_debit_price/student_count
        # flow_volume = Math.abs(total_credit_price)+Math.abs(total_debit_price)
        # flow_volume += total_fulfilled_price
        # flow_volume += total_request_cost
        
        
        # tipped_cur = 
        #     Docs.find
        #         model:'tip'
        #         _author_id:user_id
        # tipped_count = tipped_cur.count()
        
        # received_tips_cur = 
        #     Docs.find
        #         model:'tip'
        #         _author_id:user_id
            
        # received_tips_count = received_tips_cur.count()
        
        
        topups = 
            Docs.find
                model:'topup'
                _author_id:user_id
        
        total_topup_price = 0        
        for topup in topups.fetch()
            total_topup_price += topup.amount*100
            console.log 'adding', topup.amount
        # points = total_credit_price-total_debit_price+total_fulfilled_price-total_request_cost+total_topup_price-comment_count-(tipped_count*11)+(received_tips_count*10)
        # points = total_credit_price-total_debit_price+total_topup_price-comment_count-(tipped_count*11)+(received_tips_count*10)-total_vote_cost
        points = total_credit_price-total_debit_price+total_topup_price-total_vote_cost
        # points = total_credit_price-total_debit_price+total_fulfilled_price-total_request_cost
        # points += total_fulfilled_price
        # points =- total_request_cost
        
        if total_debit_price is 0 then total_debit_price++
        if total_credit_price is 0 then total_credit_price++
        # debit_credit_ratio = total_debit_price/total_credit_price
        # unless total_debit_price is 1
        #     unless total_credit_price is 1
        #         one_ratio = total_debit_price/total_credit_price
        #     else
        #         one_ratio = 0
        # else
        #     one_ratio = 0
                
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
                # flow_volume: flow_volume
                points:points
                total_imported_points:total_imported_points
                # one_ratio: one_ratio
                # total_authored_points:total_authored_points    
                # total_fulfilled_price:total_fulfilled_price
                # fulfilled_count:fulfilled_count
                # tipped_count:tipped_count
                # received_tips_count:received_tips_count
                # comment_count:comment_count
                
                
                            