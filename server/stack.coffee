# https://api.duckduckgo.com/?q=simpsons+characters&format=json&pretty=1
Meteor.methods
    search_stack: (query)->
        # @unblock()
        console.log 'searching ddg for', query
        # console.log 'type of query', typeof(query)
        site = 'stackoverflow'
        # HTTP.get "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=#{query}&site=#{site}",(err,response)=>
        # HTTP.get "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=meteor&site=stackoverflow",(err,response)=>
        HTTP.get "https://api.stackexchange.com/2.2/tags?order=desc&sort=popular&site=stackoverflow",(err,response)=>
            console.dir JSON.parse(response.content)
            # for item in response.content.items
            #     console.log tags
            # if err then console.log err
            # else
            #     parsed = JSON.parse(response.content)
            #     found = 
            #         Docs.findOne 
            #             model:'duck'
            #             query:query
            #     if found 
            #         found_id = found._id
            #         Docs.update found_id,
            #             $set:
            #                 content:parsed
            #     else
            #         found_id = 
            #             Docs.insert 
            #                 model:'duck'
            #                 query:query
            #                 content:parsed
                # console.log 'data hading', response.content.Heading
                # console.log 'data url', response.content.AbstractURL
                # for topic in response.content.RelatedTopics
                #     console.log 'related topic', topic
                    
                # console.log 'data length', response.AbstractURL
            #     # console.log 'found data'
