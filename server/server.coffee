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
        true
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



Meteor.publish 'chat', (title)->
    # console.log title
    # @unblock()
    Docs.find({
        model:'chat'
    }, 
        sort:_timestamp:-1
        limit:5
    )
Meteor.publish 'doc_by_title', (title)->
    # console.log title
    @unblock()
    Docs.find({
        title:title
        model:'wikipedia'
    },
        fields:
            title:1
            "watson.metadata":1
            max_emotion_name:1
            model:1
    )

Meteor.publish 'doc_count', (
    selected_tags
    view_mode
    emotion_mode
    )->
    match = {}
    console.log 'tags', selected_tags
    # match.model = $in:['wikipedia']
    # match.model = 'wikipedia'
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['love']
    
    if emotion_mode
        match.max_emotion_name = emotion_mode
        
    # switch view_mode
    #     when 
    switch view_mode 
        when 'image'
            match.model = 'reddit'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            match.model = 'reddit'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
            # match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'twitter'
            match.model = 'reddit'
            match.domain = $in:['twitter.com','mobile.twitter.com']
        when 'reddit'
            match.model = 'reddit'
            match.domain = $nin:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com','youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        else 
            match.model = $in:['wikipedia','reddit','alpha']

    Counts.publish this, 'result_counter', Docs.find(match)
    return undefined    # otherwise coffeescript returns a Counts.publish
                      # handle when Meteor expects a Mongo.Cursor object.


Meteor.methods
    zero: ->
        cur = Docs.find({
            model:'reddit'
            points:$ne:0
        }, limit:10)
        # Docs.update
        console.log cur.count()

    lookup_url: (url)->
        found = Docs.findOne url:url 
        if found
            return found
        else
            new_id = 
                Docs.insert
                    model:'page'
                    url:url
            Meteor.call 'call_watson', 'url', 'url'
            Docs.findOne new_id


Meteor.publish 'docs', (
    selected_tags
    view_mode
    emotion_mode
    toggle
    # query=''
    skip
    )->
    match = {}
    if emotion_mode
        match.max_emotion_name = emotion_mode

    if selected_tags.length > 0
        match.tags = $all:selected_tags
    # console.log 'skip', skip
    # match.model = 'wikipedia'
    switch view_mode 
        when 'image'
            match.model = 'reddit'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            match.model = 'reddit'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
            # match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'twitter'
            match.model = 'reddit'
            match.domain = $in:['twitter.com','mobile.twitter.com']
        when 'reddit'
            match.model = 'reddit'
            match.domain = $nin:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com','youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        else 
            match.model = $in:['wikipedia','reddit','alpha']
    # console.log 'doc match', match
    Docs.find match,
        limit:10
        skip:skip
        sort:
            points: -1
            ups:-1
            # views: -1
                    
                    
Meteor.publish 'dtags', (
    selected_tags
    view_mode
    emotion_mode
    toggle
    # query=''
    )->
    # @unblock()
    self = @
    match = {}
    console.log 'tags', selected_tags
    if emotion_mode
        match.max_emotion_name = emotion_mode

    # console.log 'emotion mode', emotion_mode
    # if selected_tags.length > 0
        # console.log 'view_mode', view_mode
        # console.log 'query', query
    
    switch view_mode 
        when 'reddit'
            match.model = 'reddit'
            match.domain = $nin:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com','youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'image'
            match.model = 'reddit'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            match.model = 'reddit'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
        when 'twitter'
            match.model = 'reddit'
            match.domain = $in:['twitter.com','mobile.twitter.com']
        else
            match.model = $in:['wikipedia','reddit','alpha']
            # match.model = $in:['wikipedia']
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['love']
    # else if view_mode in ['reddit',null]
    doc_count = Docs.find(match).count()
    console.log 'count',doc_count
    # if query.length > 3
    #     match.title = {$regex:"#{query}"}
    #     model:'wikipedia'
    # if query.length > 4
    #     console.log 'searching query', query
    #     # match.tags = {$regex:"#{query}", $options: 'i'}
    #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
    #     terms = Docs.find({
    #         model:'wikipedia'            
    #         title: {$regex:"#{query}", $options: 'i'}
    #         title: {$regex:"#{query}"}
    #     },
    #         # sort:
    #         #     count: -1
    #         limit: 10
    #     )
    #     terms.forEach (term, i) ->
    #         self.added 'results', Random.id(),
    #             name: term.title
    #             # count: term.count
    #             model:'tag'
    #     # self.ready()
    # else
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    # # console.log 'cloud: ', tag_cloud
    # console.log 'tag match', match
    tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'tag'
    self.ready()
    
        
                        
                        
