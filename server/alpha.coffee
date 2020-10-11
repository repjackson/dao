Meteor.publish 'alpha', (selected_tags)->
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
Meteor.methods
    call_alpha: (query)->
        @unblock()
        console.log 'searching alpha for', query
        found_alpha = 
            Docs.findOne 
                model:'alpha'
                query:query
        if found_alpha
            # console.log 'skipping existing alpha for ', query, found_alpha
            return found_alpha
        else
            console.log 'creating new alpha for ', query
            new_query_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    tags:[query]
                    
            HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&format=html,image,plaintext,sound&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
                # console.log response
                if err then console.log err
                else
                    parsed = JSON.parse(response.content)
                    Docs.update new_query_id,
                        $set:
                            response:parsed    
    chat_alpha: (chat)->
        @unblock()
        console.log 'chatting alpha for', query
        found_chat = 
            Docs.findOne 
                model:'chat'
                body:chat
        if found_alpha
            # console.log 'skipping existing alpha for ', query, found_alpha
            return found_alpha
        else
            console.log 'creating new alpha for ', query
            new_query_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    tags:[query]
                    
            HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{chat}",(err,response)=>
                # console.log response
                if err then console.log err
                else
                    parsed = JSON.parse(response.content)
                    Docs.update new_query_id,
                        $set:
                            response:parsed