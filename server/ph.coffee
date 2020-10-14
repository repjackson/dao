Meteor.methods
    search_ph: (query)->
        @unblock()
        console.log 'searching ph for', query
        HTTP.get "http://www.pornhub.com/webmasters/search?search=#{query}&thumbsize=large",(err,response)=>
            # console.log response.data
            if err then console.log err
            else if response.data.videos.length > 1
                # console.log 'found data'
                # console.log 'data length', response.data.data.children.length
                _.each(response.data.videos[..10], (item)=>
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
    
