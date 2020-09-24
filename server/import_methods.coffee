Meteor.methods
    search_ph: (query)->
        console.log 'searching for', query
        HTTP.get "http://www.pornhub.com/webmasters/search?search=#{query}&thumbsize=large",(err,response)=>
            # console.log response.data
            if err then console.log err
            else if response.data.videos.length > 1
                # console.log 'found data'
                # console.log 'data length', response.data.data.children.length
                _.each(response.data.videos, (item)=>
                    # console.log item
                    # data = item.data
                    # len = 200
                    added_tags = [query]
                    added_tags = _.flatten(added_tags)
                    # console.log 'added_tags', added_tags
                    # video =
                    #     reddit_id: data.id
                    #     url: data.url
                    #     domain: data.domain
                    #     comment_count: data.num_comments
                    #     permalink: data.permalink
                    #     title: data.title
                    #     # root: query
                    #     selftext: false
                    #     # thumbnail: false
                    #     tags: query
                    #     model:'reddit'
                    existing_vid = Docs.findOne url:item.url
                    if existing_vid
                        if Meteor.isDevelopment
                            console.log 'existing url', item.url, item.tags
                            console.log 'adding', query, 'to tags'
                        Meteor.call 'tagify_vid', existing_vid._id, ->
                        if typeof(existing_vid.tags) is 'string'
                            # console.log 'unsetting tags because string', existing_vid.tags
                            Doc.update
                                $unset: tags: 1
                        else if Array.isArray(query)
                                Docs.update existing_vid._id,
                                    $addToSet: tags: $each:query
                        else
                            Docs.update existing_vid._id,
                                $addToSet: tags: query
                        console.log 'existing doc', existing_vid.title
                    unless existing_vid
                        # console.log 'importing url', data.url
                        item.model = 'porn'
                        # item.tags = ['porn',query]
                        new_video_id = Docs.insert item
                        vid = Docs.findOne new_video_id
                        console.log 'tagging new vid ', vid.title
                        Meteor.call 'tagify_vid', new_video_id, (err,res)->
                            # console.log 'get post res', res
                # else
                #     console.log 'NO found data'
            )

    # _.each(response.data.data.children, (item)->
    #     # data = item.data
    #     # len = 200
    #     console.log item.data
    # )

    tagify_vid: (video_id)->
        if video_id 
            vid = Docs.findOne video_id
            dtags = []
            # console.log 'taggin?', vid
            # console.log Array.isArray(vid.tags)
            # unless Array.isArray(vid.tags)
            # console.log 'taggin?', vid
            for tag in vid.tags
                if tag.tag_name
                    dtags.push tag.tag_name.toLowerCase()
                    # tag_list.push tag.tag_name
            if vid.pornstars
                for person in vid.pornstars 
                    dtags.push person.pornstar_name.toLowerCase()
                    # pornstar_list.push person.pornstar_name
                for category in vid.categories 
                    dtags.push category.category.toLowerCase()
                    # category_list.push category.category
                # console.log 'dtags', dtags
            Docs.update vid._id,
                $set: 
                    tags:dtags
                    dtags:dtags
            # console.log 'result doc', Docs.findOne vid._id
            # else                 
            #     Docs.update vid._id,
            #         $set: 
            #             dtags:true
            #             tags:dtags
    tagify_vids: ()->
        cur = Docs.find({
            dtags: $exists: false
            model:'porn'
        },{limit:1000})
        for vid in cur.fetch()
            # vid = Docs.findOne id
            Meteor.call 'tagify_vid', vid._id
    




    search_reddit: (query)->
        console.log 'searching reddit for', query
        console.log 'type of query', typeof(query)
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&limit=20&include_facets=true",(err,response)=>
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
                        #     added_tags = query
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # added_tags = _.flatten(added_tags)
                        # console.log 'added_tags', added_tags
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            comment_count: data.num_comments
                            permalink: data.permalink
                            title: data.title
                            # root: query
                            selftext: false
                            # thumbnail: false
                            tags: query
                            model:'reddit'
                            source:'reddit'
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
                            Docs.update existing_doc._id,
                                $addToSet: tags: $each: query

                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                        unless existing_doc
                            # console.log 'importing url', data.url
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            # console.log 'calling watson on ', reddit_post.title
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                                # console.log 'get post res', res
                    else
                        console.log 'NO found data'
                )

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        #     console.log item.data
        # )


    get_reddit_post: (doc_id, reddit_id, root)->
        # console.log 'getting reddit post', doc_id, reddit_id
        HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
            if err then console.error err
            else
                rd = res.data.data.children[0].data
                # console.log rd
                result =
                    Docs.update doc_id,
                        $set:
                            rd: rd
                # console.log result
                # if rd.is_video
                #     # console.log 'pulling video comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                # else if rd.is_image
                #     # console.log 'pulling image comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                # else
                #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                #     # Meteor.call 'call_visual', doc_id, ->
                if rd.selftext
                    unless rd.is_video
                        # if Meteor.isDevelopment
                        #     console.log "self text", rd.selftext
                        Docs.update doc_id, {
                            $set:
                                body: rd.selftext
                        }, ->
                        #     Meteor.call 'pull_site', doc_id, url
                            # console.log 'hi'
                if rd.selftext_html
                    unless rd.is_video
                        Docs.update doc_id, {
                            $set:
                                html: rd.selftext_html
                        }, ->
                            # Meteor.call 'pull_site', doc_id, url
                            # console.log 'hi'
                if rd.url
                    unless rd.is_video
                        url = rd.url
                        # if Meteor.isDevelopment
                        #     console.log "found url", url
                        Docs.update doc_id, {
                            $set:
                                reddit_url: url
                                url: url
                        }, ->
                            # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                # update_ob = {}
                if rd.preview
                    if rd.preview.images[0].source.url
                        thumbnail = rd.preview.images[0].source.url
                else
                    thumbnail = rd.thumbnail
                Docs.update doc_id,
                    $set:
                        rd: rd
                        url: rd.url
                        # reddit_image:rd.preview.images[0].source.url
                        thumbnail: thumbnail
                        subreddit: rd.subreddit
                        rd_author: rd.author
                        is_video: rd.is_video
                        ups: rd.ups
                        # downs: rd.downs
                        over_18: rd.over_18
                    # $addToSet:
                    #     tags: $each: [rd.subreddit.toLowerCase()]
                # console.log Docs.findOne(doc_id)
 
    #   'https://en.wikipedia.org/w/api.php?action=opensearch&format=json&search=';
    #   'https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&format=json&titles=';

 
    # call_wiki: (query)->
    #     console.log 'calling wiki', query
    #     # term = query.split(' ').join('_')
    #     # term = query[0]
    #     term = query
    #     # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
    #     HTTP.get "https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&format=json&titles=#{term}",(err,response)=>
    #         console.log response.data
    #         # if err
    call_wiki: (query)->
        console.log 'calling wiki', query
        # term = query.split(' ').join('_')
        # term = query[0]
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&format=json&search=#{term}",(err,response)=>
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
                        Docs.update found_doc._id,
                            # $pull:
                            #     tags:'wikipedia'
                            $set:
                                title:found_doc.title.toLowerCase()
                        # console.log 'found wiki doc', found_doc
                        # Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                    else
                        new_wiki_id = Docs.insert
                            title:term.toLowerCase()
                            tags:[term.toLowerCase(),query.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1000000
                            url:url
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->
