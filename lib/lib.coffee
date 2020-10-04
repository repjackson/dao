@Docs = new Meteor.Collection 'docs'

@Tags = new Meteor.Collection 'tags'
@Tag_results = new Meteor.Collection 'tag_results'
@source_results = new Meteor.Collection 'source_results'
@domain_results = new Meteor.Collection 'domain_results'
@author_results = new Meteor.Collection 'author_results'
@results = new Meteor.Collection 'results'



Docs.before.insert (userId, doc)->
    # if Meteor.user()
    #     doc._author_id = Meteor.userId()
    #     doc._author_username = Meteor.user().username
    timestamp = Date.now()
    doc._timestamp = timestamp
    # doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")

    doc.app = 'dao'

    # date = moment(timestamp).format('Do')
    # weekdaynum = moment(timestamp).isoWeekday()
    # weekday = moment().isoWeekday(weekdaynum).format('dddd')

    # hour = moment(timestamp).format('h')
    # minute = moment(timestamp).format('m')
    # ap = moment(timestamp).format('a')
    # month = moment(timestamp).format('MMMM')
    # year = moment(timestamp).format('YYYY')

    # doc.points = 0
    # if Meteor.user()
    #     Meteor.users.update Meteor.userId(),
    #         $inc:points:1
    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    # date_array = [ap, weekday, month, date, year]
    # if _
    #     date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    #     # date_array = _.each(date_array, (el)-> console.log(typeof el))
    #     # console.log date_array
    #     doc._timestamp_tags = date_array
    # return
