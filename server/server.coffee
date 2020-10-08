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
    )

Meteor.publish 'doc_count', (
    selected_tags
    view_mode
    )->
    match = {}
    # match.model = $in:['wikipedia']
    # match.model = 'wikipedia'
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['daoism']
        
    # switch view_mode
    #     when 
    switch view_mode 
        when 'image'
            match.model = 'reddit'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            match.model = 'reddit'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
            # match.domain = $in:['youtube.com','youtu.be','m.youtube.com','vimeo.com']
        when 'twitter'
            match.model = 'reddit'
            match.domain = $in:['twitter.com','mobile.twitter.com']
        when 'porn'
            match.model = 'porn'
        when 'stackexchange'
            match.model = 'stackexchange'
        else 
            match.model = $in:['wikipedia','reddit']

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
    toggle
    query=''
    skip
    )->
    match = {}
    console.log 'skip', skip
    # match.model = 'wikipedia'
    switch view_mode 
        when 'image'
            match.model = 'reddit'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            match.model = 'reddit'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
            # match.domain = $in:['youtube.com','youtu.be','m.youtube.com','vimeo.com']
        when 'twitter'
            match.model = 'reddit'
            match.domain = $in:['twitter.com','mobile.twitter.com']
        when 'porn'
            match.model = 'porn'
        when 'stackexchange'
            match.model = 'stackexchange'
        else 
            match.model = $in:['wikipedia','reddit','page']
    if selected_tags.length > 0
        match.tags = $all:selected_tags
        console.log 'doc match', match
        Docs.find match,
            limit:5
            skip:skip
            sort:
                points: -1
                views: -1
                _timestamp:-1
    else
        match.tags = $in:['daoism']
        # console.log match
        Docs.find match,
            limit:5
            skip:skip
            sort:
                points: -1
                ups:-1
                views: -1
                _timestamp:-1
                    
                    
Meteor.publish 'dtags', (
    selected_tags
    view_mode
    toggle
    query=''
    )->
    @unblock()
    self = @
    match = {}
    
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0
        console.log 'tags', selected_tags
        console.log 'view_mode', view_mode
        console.log 'query', query
    
        switch view_mode 
            when 'image'
                match.model = 'reddit'
                match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
            when 'video'
                match.model = 'reddit'
                match.domain = $in:['youtube.com','youtu.be','m.youtube.com','vimeo.com']
            when 'wikipedia'
                match.model = 'wikipedia'
                # match.domain = $in:['youtube.com','youtu.be','m.youtube.com','vimeo.com']
            when 'twitter'
                match.model = 'reddit'
                match.domain = $in:['twitter.com','mobile.twitter.com']
            when 'porn'
                match.model = 'porn'
            when 'stackexchange'
                match.model = 'stackexchange'
            else
                match.model = $in:['wikipedia','reddit']
        # match.model = $in:['wikipedia','reddit']
        if selected_tags.length > 0 
            match.tags = $all: selected_tags
        else if view_mode in ['reddit',null]
            match.tags = $in:['daoism']
        doc_count = Docs.find(match).count()
        console.log 'count',doc_count
        if query.length > 2
            match.title = {$regex:"#{query}"}
            
        # if query.length > 4
        #     console.log 'searching query', query
        #     # match.tags = {$regex:"#{query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        
        #     terms = Docs.find({
        #         model:'wikipedia'            
        #         title: {$regex:"#{query}", $options: 'i'}
                # title: {$regex:"#{query}"}
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
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # # console.log 'cloud: ', tag_cloud
        console.log 'tag match', match
        tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        self.ready()
        
        
                        
                        
