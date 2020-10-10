Meteor.methods
    search_alpha: (query)->
        @unblock()
        console.log 'searching alpha for', query
        # console.log 'type of query', typeof(query)
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&format=plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            console.log response
            if err then console.log err
            else
                found_alpha_query = 
                    Docs.findOne 
                        model:'alpha'
                        query:query
                if found_alpha_query
                    Docs.update found_alpha_query._d
                
                
                
            # else if response.data.data.dist > 1
            #     # console.log 'found data'
            #     # console.log 'data length', response.data.data.children.length
            #     _.each(response.data.data.children, (item)=>
            #         # console.log item.data
            #         unless item.domain is "OneWordBan"
            #             data = item.data
            #             len = 200
