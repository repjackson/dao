@Docs = new Meteor.Collection 'docs'

@results = new Meteor.Collection 'results'


# Meteor.methods
#     check_url: (str)->
#         pattern = new RegExp('^(https?:\\/\\/)?'+ # protocol
#         '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ # domain name
#         '((\\d{1,3}\\.){3}\\d{1,3}))'+ # OR ip (v4) address
#         '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ # port and path
#         '(\\?[;&a-z\\d%_.~+=-]*)?'+ # query string
#         '(\\#[-a-z\\d_]*)?$','i') # fragment locator
#         return !!pattern.test(str)

            


Docs.before.insert (userId, doc)->
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
    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    # date_array = [ap, weekday, month, date, year]
    # if _
    #     date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    #     # date_array = _.each(date_array, (el)-> console.log(typeof el))
    #     # console.log date_array
    #     doc._timestamp_tags = date_array
    return
