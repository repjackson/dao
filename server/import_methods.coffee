Meteor.methods
    search_reddit: (query)->
        # console.log 'searching reddit for', query
        # console.log 'type of query', typeof(query)
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&limit=100&include_facets=false",(err,response)=>
            # console.log response.data
            if err then console.log err
            else if response.data.data.dist > 1
                # console.log 'found data'
                # console.log 'data length', response.data.data.children.length
                _.each(response.data.data.children, (item)=>
                    # console.log item.data
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # if typeof(query) is String
                        #     console.log 'is STRING'
                        #     added_tags = [query]
                        # else
                        added_tags = query
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.subreddit.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # added_tags = _.flatten(added_tags)
                        # console.log 'added_tags', added_tags
                        # console.log 'ups?', data.ups
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            # comment_count: data.num_comments
                            permalink: data.permalink
                            ups: data.ups
                            title: data.title
                            # root: query
                            # selftext: false
                            # thumbnail: false
                            tags: query
                            model:'reddit'
                            # source:'reddit'
                        # console.log 'reddit post', reddit_post
                        existing_doc = Docs.findOne url:data.url
                        if existing_doc
                            # if Meteor.isDevelopment
                                # console.log 'skipping existing url', data.url
                                # console.log 'adding', query, 'to tags'
                            # console.log 'type of tags', typeof(existing_doc.tags)
                            # if typeof(existing_doc.tags) is 'string'
                            #     # console.log 'unsetting tags because string', existing_doc.tags
                            #     Doc.update
                            #         $unset: tags: 1
                            # console.log 'existing ', reddit_post.title
                            Docs.update existing_doc._id,
                                $addToSet: tags: $each: query

                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                        unless existing_doc
                            # console.log 'importing url', data.url
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                            # console.log 'get post res', res
                    else
                        console.log 'NO found data'
                )

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        #     console.log item.data
        # )

    call_wiki: (query)->
        # console.log 'calling wiki', query
        # term = query.split(' ').join('_')
        # term = query[0]
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&format=json&search=#{term}",(err,response)=>
            if err
                console.log 'error finding wiki article for ', query
            else
                # console.log response.data[1]
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
                            tags:[term.toLowerCase(),query.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1
                            url:url
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->
