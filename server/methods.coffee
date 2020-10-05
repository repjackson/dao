Meteor.methods
    lookup_url: (url)->
        found = Docs.findOne url:url
        if found 
            Meteor.call 'call_watson',found._id,'url','url'
            return found
        else
            new_id = 
                Docs.insert 
                    model:'page'
                    url:url
            Meteor.call 'call_watson',new_id,'url','url'
            return Docs.findOne(new_id)
            
