Meteor.publish 'gift_tag_results', (
    selected_tags
    selected_location_tags
    selected_authors
    )->
    # console.log 'dummy', dummy
    console.log 'selected tags', selected_tags
    # console.log 'query', query

    self = @
    match = {}

    match.model = 'gift'
    # console.log 'query length', query.length
    # if query
    # if query and query.length > 1
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


    if selected_tags.length > 0
        match.tags = $all: selected_tags
    console.log 'match for gift tags', match


    # agg_doc_count = Docs.find(match).count()
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        # { $match: count: $lt: agg_doc_count }
        # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    tag_cloud.forEach (tag, i) =>
        console.log 'queried tag ', tag
        self.added 'tags', Random.id(),
            title: tag.name
            count: tag.count
            # category:key
            # index: i
    # console.log doc_tag_cloud.count()

    # # agg_doc_count = Docs.find(match).count()
    location_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        # { $unwind: "$location_tag" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        { $match: _id: $nin: selected_location_tags }
        # { $match: count: $lt: agg_doc_count }
        # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    location_tag_cloud.forEach (location_tag, i) =>
        # console.log 'queried location_tag ', location_tag
        # console.log 'key', key
        self.added 'location_tag_results', Random.id(),
            title: location_tag.name
            count: location_tag.count
            # category:key
            # index: i
    # console.log doc_tag_cloud.count()


    self.ready()

Meteor.publish 'gift_results', (
    selected_tags
    selected_location_tags=[]
    selected_authors=[]
    # date_setting
    )->
    # console.log 'got selected tags', selected_tags
    # else
    self = @
    match = {model:'gift'}
    # if selected_tags.length > 0
    # console.log date_setting
    # if date_setting
    #     if date_setting is 'today'
    #         now = Date.now()
    #         day = 24*60*60*1000
    #         yesterday = now-day
    #         # console.log yesterday
    #         match._timestamp = $gt:yesterday

    if selected_tags.length > 0
        # if selected_tags.length is 1
        #     console.log 'looking single doc', selected_tags[0]
        #     found_doc = Docs.findOne(title:selected_tags[0])
        #
        #     match.title = selected_tags[0]
        # else
        match.tags = $all: selected_tags
    if selected_location_tags.length > 0
        match.location_tags = $all: selected_location_tags

    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            points:-1
            ups:-1
        limit:10
