# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (user_id, doc) ->
        false
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        # else
        #     user_id is doc._author_id
    update: (user_id, doc) ->
        # user = Meteor.users.findOne user_id
        # console.log user_id
        # console.log doc._author_id
        false
        # if user_id is doc._author_id
        # else if user.roles and 'admin' in user.roles
        #     true
    remove: (user_id, doc) ->
        false
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        #     true
        # else
        #     user_id is doc._author_id



Meteor.publish 'doc_by_title', (title)->
    # console.log title
    Docs.find
        title:title
        model:'wikipedia'


Meteor.publish 'doc_count', (
    selected_tags
    selected_domains
    # selected_authors
    # selected_subreddits
    selected_models
    view_mode
    )->
    match = {}
    # match.model = $in:['reddit','wikipedia','post','page']
    match.model = $in:['wikipedia']
    # match.model = 'wikipedia'
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['dao']

    # if selected_domains.length > 0 
    #     match.domain = $all: selected_domains
    # if selected_authors.length > 0 
    #     match.author = $all: selected_authors
    # if selected_subreddits.length > 0 
    #     match.subreddit = $all: selected_subreddits
    # if selected_models.length > 0 
    #     match.model = $all: selected_models
    Counts.publish this, 'result_counter', Docs.find(match)
    return undefined    # otherwise coffeescript returns a Counts.publish
                      # handle when Meteor expects a Mongo.Cursor object.


Meteor.publish 'docs', (
    selected_tags
    toggle
    query=''
    # selected_domains
    # selected_models
    view_mode
    )->
    match = {}
    # match.model = $in:['reddit','wikipedia','post','page']
    # match.model = $in:['reddit','wikipedia']
    match.model = 'wikipedia'
    # if selected_domains.length > 0 
    #     match.domain = $all: selected_domains
    # if selected_models.length > 0 
    #     match.model = $all: selected_models
    
    if view_mode is 'grid'
        limit = 8
    else if view_mode is 'list'
        limit = 10
    else if view_mode is 'single'
        limit = 3
    else
        limit = 5
    
    
    if selected_tags.length > 0
        match.tags = $all:selected_tags
        # console.log match
        Docs.find match,
            limit:limit
            sort:
                # points:-1
                ups:-1
                # _timestamp:-1
                # views:-1
    else
        match.tags = $in:['dao']
        # console.log match
        Docs.find match,
            limit:limit
            sort:
                _timestamp:-1
                # points:-1
                ups:-1
                    
                    
Meteor.publish 'dtags', (
    selected_tags
    toggle
    query=''
    # selected_domains
    # selected_models
    view_mode
    )->
    self = @
    match = {}
    # match.model = $in:['post','wikipedia','reddit','page']
    # match.model = $in:['wikipedia','reddit']
    # match.model = $in:['reddit']
    # match.model = $in:['reddit','wikipedia']
    match.model = 'wikipedia'
    
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['dao']
    # if selected_domains.length > 0 
    #     match.domain = $all: selected_domains
    # if selected_models.length > 0 
    #     match.model = $all: selected_models

    if view_mode is 'grid'
        limit = 10
    else if view_mode is 'list'
        limit = 10
    else if view_mode is 'single'
        limit = 1

    count = Docs.find(match).count()
    console.log count

    if query.length > 1
        console.log 'searching query', query
        # match.tags = {$regex:"#{query}", $options: 'i'}
        # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
        terms = Docs.find({
            # title: {$regex:"#{query}"}
            model:'wikipedia'            
            title: {$regex:"#{query}", $options: 'i'}
        },
            # sort:
            #     count: -1
            limit: 5
        )
        terms.forEach (term, i) ->
            self.added 'results', Random.id(),
                name: term.title
                # count: term.count
                model:'tag'

        
    else
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud: ', tag_cloud
        # console.log 'tag match', match
        tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        
        
        # domain_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "domain": 1 }
        #     # { $unwind: "$domain" }
        #     { $group: _id: "$domain", count: $sum: 1 }
        #     { $match: _id: $nin: selected_domains }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: count }
        #     { $limit: 5 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'cloud: ', domain_cloud
        # # console.log 'domain match', match
        # domain_cloud.forEach (domain, i) ->
        #     # self.added 'domain_results', Random.id(),
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
                # model:'domain'
       
    self.ready()
                    
                    