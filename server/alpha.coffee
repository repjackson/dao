Meteor.publish 'alpha', ->
    Docs.find 
        model:'alpha'

Meteor.methods
    search_alpha: (query)->
        @unblock()
        console.log 'searching alpha for', query
        HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&format=plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            console.log response
            if err then console.log err
            else
                found_alpha_query = 
                    Docs.findOne 
                        model:'alpha'
                        query:query
                parsed = JSON.parse(response.content)
                
                if found_alpha_query
                    
                    Docs.update found_alpha_query._id,
                        $set:
                            response:parsed
                else
                    Docs.insert
                        model:'alpha'
                        query:query
                        response:parsed
                
                
                
            # else if response.data.data.dist > 1
            #     # console.log 'found data'
            #     # console.log 'data length', response.data.data.children.length
            #     _.each(response.data.data.children, (item)=>
            #         # console.log item.data
            #         unless item.domain is "OneWordBan"
            #             data = item.data
            #             len = 200
