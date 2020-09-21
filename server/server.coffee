# tsqp-gebk-xhpz-eobp-agle

Docs.allow
    insert: (user_id, doc) ->
        true
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        # else
        #     user_id is doc._author_id
    update: (user_id, doc) ->
        # user = Meteor.users.findOne user_id
        # console.log user_id
        # console.log doc._author_id
        true
        # if user_id is doc._author_id
        # else if user.roles and 'admin' in user.roles
        #     true
    remove: (user_id, doc) ->
        user = Meteor.users.findOne user_id
        if user.roles and 'admin' in user.roles
            true
        else
            user_id is doc._author_id


Meteor.users.allow
    insert: (user_id, doc, fields, modifier) ->
        # user_id
        true
        # if user_id and doc._id == user_id
        #     true
    update: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'dev' in user.roles
            true
        else
            if user_id and doc._id == user_id
                true
    remove: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'dev' in user.roles
            true
        # if userId and doc._id == userId
        #     true


Meteor.publish 'doc_by_title', (title)->
    # console.log title
    Docs.find
        title:title
        model:'wikipedia'


Meteor.publish 'docs', (
    query=''
    selected_tags
    # selected_authors
    # selected_upvoters
    # selected_sources
    )->
    match = {}
    match.model = $in:['post','wikipedia','reddit']
    
    # match.model = 'post'
    # if Meteor.user()
    #     match.downvoter_ids = $nin:[Meteor.userId()]
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0
        match.tags = $all:selected_tags
    #     sort_key = 'tags'
    # else
    #     sort_key = '_timestamp'
    # if selected_authors.length > 0
    #     match._author_username = $all:selected_authors
    # if selected_upvoters.length > 0
    #     match.upvoter_usernames = $all:selected_upvoters
    # if selected_sources.length > 0
    #     match.source = $all:selected_sources
    console.log match
    Docs.find match,
        limit:5
        sort:tags:1
                    
                    
Meteor.publish 'tags', (
    query=''
    selected_tags
    # selected_authors
    # selected_upvoters
    # selected_sources
    # limit=20
    )->
    self = @
    match = {}
    match.model = $in:['post','wikipedia','reddit']
    # match.model = 'post'
    
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    # if selected_tags.length > 0 
    match.tags = $all: selected_tags
    # else
    #     match.tags = $in:['dao']
    # if selected_authors.length > 0 then match._author_username = $all: selected_authors
    # if Meteor.user()
    #     match.downvoter_ids = $nin:[Meteor.userId()]
    # if selected_upvoters.length > 0
    #     match.upvoter_usernames = $all:selected_upvoters
    # if selected_sources.length > 0
    #     match.source = $all:selected_sources

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    # console.log 'filter: ', filter
    # console.log 'cloud: ', cloud
    tag_cloud.forEach (tag, i) ->
        self.added 'tag_results', Random.id(),
            name: tag.name
            count: tag.count
            index: i
   
    # author_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "_author_username": 1 }
    #     { $group: _id: "$_author_username", count: $sum: 1 }
    #     { $match: _id: $nin: selected_authors }
    #     { $sort: count: -1, _id: 1 }
    #     { $limit: 10 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    #     ]
    # # console.log 'filter: ', filter
    # # console.log 'cloud: ', cloud
    # author_cloud.forEach (author, i) ->
    #     self.added 'author_results', Random.id(),
    #         name: author.name
    #         count: author.count
    #         index: i
   
    # upvoter_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "upvoter_usernames": 1 }
    #     { $unwind: "$upvoter_usernames" }
    #     { $group: _id: "$upvoter_usernames", count: $sum: 1 }
    #     { $match: _id: $nin: selected_upvoters }
    #     { $sort: count: -1, _id: 1 }
    #     { $limit: 10 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    #     ]
    # # console.log 'filter: ', filter
    # # console.log 'cloud: ', cloud
    # upvoter_cloud.forEach (upvoter, i) ->
    #     self.added 'upvoter_results', Random.id(),
    #         name: upvoter.name
    #         count: upvoter.count
    #         index: i
   
    self.ready()
                    