Meteor.publish 'user_from_username', (username)->
    # console.log 'pulling doc'
    Meteor.users.find
        username:username
        
Meteor.publish 'user_model_docs', (model,username)->
    # console.log 'pulling doc'
    user = Meteor.users.findOne username:username
    Docs.find
        model:model
        _author_id:user._id

Meteor.publish 'recipient_from_gift_id', (gift_id)->
    # console.log 'pulling doc'
    gift = Docs.findOne gift_id
    Meteor.users.find
        _id:gift.target_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    # console.log 'pulling doc'
    doc = Docs.findOne doc_id
    Meteor.users.find
        _id:doc._author_id

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find
        _id:user_id

Meteor.publish 'doc_comments', (doc_id)->
    Docs.find
        model:'comment'
        parent_id:doc_id


Meteor.publish 'children', (model, parent_id)->
    match = {}
    Docs.find
        model:model
        parent_id:parent_id

Meteor.publish 'current_doc', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id



Meteor.publish 'my_received_messages', ->
    Docs.find 
        model:'message'
        recipient_id:Meteor.userId()
Meteor.publish 'my_sent_messages', ->
    Docs.find 
        model:'message'
        _author_id:Meteor.userId()

Meteor.publish 'alerts', ->
    Docs.find
        model:'alert'
        to_user_id:Meteor.userId()
        read:$ne:true


Meteor.publish 'model_docs', (model)->
    # console.log 'pulling doc'
    match = {model:model}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'admin' in Meteor.user().roles
    #         match.app = 'stand'
    # else
        # match.app = 'stand'
    Docs.find match

Meteor.publish 'latest_debits', ()->
    # console.log 'pulling doc'
    match = {model:'debit'}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'admin' in Meteor.user().roles
    #         match.app = 'stand'
    # else
        # match.app = 'stand'
    Docs.find match,
        sort:_timestamp:-1
        limit:25


Meteor.publish 'all_users', ()->
    Meteor.users.find()



Meteor.publish 'doc', (doc_id)->
    found_doc = Docs.findOne doc_id
    if found_doc
        Docs.find doc_id
    else
        Meteor.users.find doc_id




Meteor.publish 'me', ()->
    if Meteor.user()
        Meteor.users.find Meteor.userId()
    else
        []


Meteor.publish 'tag_results', (
    # doc_id
    selected_tags
    searching
    query
    dummy
    )->
    # console.log 'dummy', dummy
    console.log 'selected tags', selected_tags
    console.log 'query', query

    self = @
    match = {}

    match.model = $in: ['debit']
    # console.log 'query length', query.length
    # if query
    # if query and query.length > 1
    if query.length > 1
        console.log 'searching query', query
        # #     # match.tags = {$regex:"#{query}", $options: 'i'}
        # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        # #
        terms = Terms.find({
            # title: {$regex:"#{query}"}
            title: {$regex:"#{query}", $options: 'i'}
            app:'stand'
        },
            sort:
                count: -1
            limit: 5
        )
        # console.log terms.fetch()
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_tags }
        #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 42 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]

    else
        # unless query and query.length > 2
        # if selected_tags.length > 0 then match.tags = $all: selected_tags
        # console.log date_setting
        # if date_setting
        #     if date_setting is 'today'
        #         now = Date.now()
        #         day = 24*60*60*1000
        #         yesterday = now-day
        #         console.log yesterday
        #         match._timestamp = $gt:yesterday


        # debit = Docs.findOne doc_id
        if selected_tags.length > 0
            # match.tags = $all: debit.tags
            match.tags = $all: selected_tags
            # else
            #     # unless selected_domains.length > 0
            #     #     unless selected_subreddits.length > 0
            #     #         unless selected_subreddits.length > 0
            #     #             unless selected_emotions.length > 0
            #     match.tags = $all: ['dao']
            # console.log 'match for tags', match
            # if selected_subreddits.length > 0
            #     match.subreddit = $all: selected_subreddits
            # if selected_domains.length > 0
            #     match.domain = $all: selected_domains
            # if selected_emotions.length > 0
            #     match.max_emotion_name = $all: selected_emotions
            console.log 'match for tags', match
    
    
            agg_doc_count = Docs.find(match).count()
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $match: _id: $nin: selected_tags }
                { $match: count: $lt: agg_doc_count }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }
    
            tag_cloud.forEach (tag, i) =>
                # console.log 'queried tag ', tag
                # console.log 'key', key
                self.added 'tags', Random.id(),
                    title: tag.name
                    count: tag.count
                    # category:key
                    # index: i
            # console.log doc_tag_cloud.count()

        self.ready()

Meteor.publish 'doc_results', (
    selected_tags
    selected_subreddits
    selected_domains
    selected_authors
    selected_emotions
    date_setting
    )->
    # console.log 'got selected tags', selected_tags
    # else
    self = @
    match = {model:$in:['reddit','wikipedia']}
    # if selected_tags.length > 0
    # console.log date_setting
    if date_setting
        if date_setting is 'today'
            now = Date.now()
            day = 24*60*60*1000
            yesterday = now-day
            # console.log yesterday
            match._timestamp = $gt:yesterday

    if selected_tags.length > 0
        # if selected_tags.length is 1
        #     console.log 'looking single doc', selected_tags[0]
        #     found_doc = Docs.findOne(title:selected_tags[0])
        #
        #     match.title = selected_tags[0]
        # else
        match.tags = $all: selected_tags
    else
        # unless selected_domains.length > 0
        #     unless selected_subreddits.length > 0
        #         unless selected_subreddits.length > 0
        #             unless selected_emotions.length > 0
        match.tags = $all: ['dao']
    if selected_domains.length > 0
        match.domain = $all: selected_domains

    if selected_subreddits.length > 0
        match.subreddit = $all: selected_subreddits
    if selected_emotions.length > 0
        match.max_emotion_name = $all: selected_emotions

    # else
    #     match.tags = $nin: ['wikipedia']
    #     sort = '_timestamp'
    #     # match. = $ne:'wikipedia'
    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            points:-1
            ups:-1
        limit:10
