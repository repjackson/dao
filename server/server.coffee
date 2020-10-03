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


Meteor.publish 'docs', (
    selected_tags
    toggle
    # query=''
    )->
    match = {}
    match.model = $in:['reddit']
    # match.model = 'wikipedia'
    
    # match.model = 'post'
    # if Meteor.user()
    #     match.downvoter_ids = $nin:[Meteor.userId()]
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0
        match.tags = $all:selected_tags
        # console.log match
        Docs.find match,
            limit:3
            sort:
                # points:-1
                ups:-1
                # _timestamp:-1
                # views:-1
    else
        match.tags = $in:['dao']
        # console.log match
        Docs.find match,
            limit:3
            sort:
                _timestamp:-1
                # points:-1
                ups:-1
                    
                    
Meteor.publish 'dtags', (
    # query=''
    selected_tags
    toggle
    )->
    self = @
    match = {}
    # match.model = $in:['post','wikipedia','reddit','porn']
    # match.model = $in:['reddit']
    match.model = $in:['reddit','wikipedia']
    # match.model = 'wikipedia'
    
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['dao']

    count = Docs.find(match).count()
    console.log count


    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: count }
        { $limit: 6 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    # console.log 'cloud: ', tag_cloud
    # console.log 'tag match', match
    tag_cloud.forEach (tag, i) ->
        self.added 'tag_results', Random.id(),
            name: tag.name
            count: tag.count
            index: i
   
    self.ready()
                    
                    