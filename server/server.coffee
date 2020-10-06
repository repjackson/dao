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
    Docs.find({
        title:title
        model:'wikipedia'
    },
        fields:
            title:1
            "watson.metadata":1
    )

Meteor.publish 'doc_count', (
    selected_tags
    # selected_domains
    # selected_authors
    # selected_subreddits
    # selected_models
    # view_mode
    )->
    match = {}
    match.model = $in:['reddit','wikipedia','post','page']
    # match.model = $in:['wikipedia']
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
    )->
    match = {}
    # match.model = 'wikipedia'
    match.model = $in:['wikipedia','reddit']
    
    if selected_tags.length > 0
        match.tags = $all:selected_tags
        # console.log match
        Docs.find match,
            limit:5
            sort:
                _timestamp:-1
    else
        match.tags = $in:['life']
        # console.log match
        Docs.find match,
            limit:5
            sort:
                ups:-1
                _timestamp:-1
                    
                    
Meteor.publish 'dtags', (
    selected_tags
    toggle
    query=''
    )->
    self = @
    match = {}
    match.model = $in:['wikipedia','reddit']
    
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['life']

    count = Docs.find(match).count()
    # console.log count

    # if query.length > 1
    #     console.log 'searching query', query
    #     # match.tags = {$regex:"#{query}", $options: 'i'}
    #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
    #     terms = Docs.find({
    #         # title: {$regex:"#{query}"}
    #         model:'wikipedia'            
    #         title: {$regex:"#{query}", $options: 'i'}
    #     },
    #         # sort:
    #         #     count: -1
    #         limit: 5
    #     )
    #     terms.forEach (term, i) ->
    #         self.added 'results', Random.id(),
    #             name: term.title
    #             # count: term.count
    #             model:'tag'

        
    # else
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: count }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    # console.log 'cloud: ', tag_cloud
    # console.log 'tag match', match
    tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'tag'
    
    
    self.ready()
                    
                    
Meteor.methods
    call_wiki: (query)->
        console.log 'calling wiki', query
        # term = query.split(' ').join('_')
        # term = query[0]
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&generator=searchformat=json&search=#{term}",(err,response)=>
            if err
                console.log 'error finding wiki article for ', query
            else
                console.log response.data[1]
                for term,i in response.data[1]
                    # console.log 'term', term
                    # console.log 'i', i
                    # console.log 'url', response.data[3][i]
                    url = response.data[3][i]
    
                #     # console.log response
                #     # console.log 'response'
    
                    found_doc =
                        Docs.findOne
                            url: url
                            model:'wikipedia'
                    if found_doc
                        # console.log 'found wiki doc for term', term
                        # console.log 'found wiki doc for term', term, found_doc
                        # Docs.update found_doc._id,
                        #     # $pull:
                        #     #     tags:'wikipedia'
                        #     $set:
                        #         title:found_doc.title.toLowerCase()
                        # console.log 'found wiki doc', found_doc.title
                        unless found_doc.watson
                            Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                    else
                        new_wiki_id = Docs.insert
                            title:term.toLowerCase()
                            tags:[term.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1
                            url:url
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->
