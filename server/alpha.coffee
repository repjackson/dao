Meteor.publish 'alpha', ->
    Docs.find 
        model:'alpha'

Meteor.methods
    call_alpha: (query)->
        @unblock()
        console.log 'searching alpha for', query
        found_alpha_query = 
            Docs.findOne 
                model:'alpha'
                query:query
        if found_alpha_query
            return found_alpha_query
        else
            console.log 'creating new alpha for ', query
            new_query_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    
            HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&format=plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
                console.log response
                if err then console.log err
                else
                    parsed = JSON.parse(response.content)
                    Docs.update new_query_id,
                        $set:
                            response:parsed