Template.youtube_edit.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000

Template.youtube_view.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000


Template.youtube_edit.events
    'blur .youtube_id': (e,t)->
        parent = Template.parentData()
        val = t.$('.youtube_id').val()
        doc = Docs.findOne parent._id
        Docs.update parent._id,
            $set:"#{@key}":val

Template.clear_value.events
    'click .clear_value': ->
        if confirm "Clear #{@title} field?"
            if @direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
            else if user
                Meteor.users.update parent._id,
                    $unset:"#{@key}":1

Template.number_edit.events
    'blur .edit_number': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = parseInt t.$('.edit_number').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val
Template.time_edit.events
    'blur .edit_time': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.edit_time').val()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.datetime_edit.events
    'blur .edit_datetime': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.edit_datetime').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val





Template.date_edit.events
    'blur .edit_date': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.edit_date').val()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val




Template.html_edit.onRendered ->
    @editor = SUNEDITOR.create((document.getElementById('sample') || 'sample'),{
        # codeMirror: CodeMirror
        height:'200px'
        buttonList: [
            [
                'undo' 
                'redo'
                'font' 
                'fontSize' 
                'formatBlock' 
                'paragraphStyle' 
                'blockquote'
                'bold' 
                'underline' 
                'italic' 
                'strike' 
                'subscript' 
                'superscript'
                'fontColor' 
                'hiliteColor' 
                'textStyle'
                'removeFormat'
                'outdent' 
                'indent'
                'align' 
                'horizontalRule' 
                'list' 
                'lineHeight'
                'fullScreen' 
                'showBlocks' 
                'codeView' 
                'preview' 
                'table' 
                'image' 
                'video' 
                'audio' 
                'link'
            ]
        ]
        
        lang: SUNEDITOR_LANG['en']
    });

Template.html_edit.events
    'blur .testsun': (e,t)->
        html = t.editor.getContents(onlyContents: Boolean);

        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        Docs.update parent._id,
            $set:"#{@key}":html


# Template.html_edit.helpers
        
Template.boolean_edit.helpers
    boolean_toggle_class: ->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        if parent["#{@key}"] then 'active' else 'basic'


Template.boolean_edit.events
    'click .toggle_boolean': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]




Template.image_edit.events
    "change input[name='upload_image']": (e) ->
        files = e.currentTarget.files
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) => #optional callback, you can catch with the Cloudinary collection as well
                # console.dir res
                if err
                    console.error 'Error uploading', err
                else
                    doc = Docs.findOne parent._id
                    user = Meteor.users.findOne parent._id
                    if doc
                        Docs.update parent._id,
                            $set:"#{@key}":res.public_id
                    else if user
                        Meteor.users.update parent._id,
                            $set:"#{@key}":res.public_id


    'blur .cloudinary_id': (e,t)->
        cloudinary_id = t.$('.cloudinary_id').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        Docs.update parent._id,
            $set:"#{@key}":cloudinary_id


    'click #remove_photo': ->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        if confirm 'remove photo?'
            # Docs.update parent._id,
            #     $unset:"#{@key}":1
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
            else if user
                Meteor.users.update parent._id,
                    $unset:"#{@key}":1






Template.array_edit.events
    'keyup .new_element': (e,t)->
        if e.which is 13
            element_val = t.$('.new_element').val().trim()
            if @direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $addToSet:"#{@key}":element_val
            else if user
                Meteor.users.update parent._id,
                    $addToSet:"#{@key}":element_val
            t.$('.new_element').val('')

    'click .remove_element': (e,t)->
        element = @valueOf()
        field = Template.currentData()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $pull:"#{field.key}":element
        else if user
            Meteor.users.update parent._id,
                $pull:"#{field.key}":element

        t.$('.new_element').focus()
        t.$('.new_element').val(element)


Template.textarea_edit.events
    # 'click .toggle_edit': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":textarea_val



Template.text_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val




Template.textarea_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000



Template.single_user_edit.onCreated ->
    @user_results = new ReactiveVar
Template.single_user_edit.helpers
    user_results: ->Template.instance().user_results.get()
Template.single_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup #single_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#single_user_select_input').val().trim()
        if search_value.length > 1
            Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                if err then console.error err
                else
                    t.user_results.set res

    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Router.current().params.doc_id
        field = Template.currentData()

        # console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)


        val = t.$('.edit_text').val()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{field.key}":@_id
        else
            Meteor.users.update parent._id,
                $set:"#{field.key}":@_id
            
        t.user_results.set null
        $('#single_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()

    'click .pull_user': ->
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)
        # console.log Template.parentData(5)
        # console.log Template.parentData(6)
        # console.log Template.parentData(7)
        if confirm "remove #{@username}?"
            parent = Template.parentData(1)
            field = Template.currentData()
            Docs.update parent._id,
                $unset:"#{field.key}":1

        #     page_doc = Docs.findOne Router.current().params.doc_id
            # Meteor.call 'unassign_user', page_doc._id, @






Template.multi_user_edit.onCreated ->
    @user_results = new ReactiveVar
Template.multi_user_edit.helpers
    user_results: -> 
        Template.instance().user_results.get()
Template.multi_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null
    'keyup #multi_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#multi_user_select_input').val().trim()
        if e.which is 8
            t.user_results.set null
        else if search_value and search_value.length > 1
            Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                if err then console.error err
                else
                    # console.log res 
                    t.user_results.set res
    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Router.current().params.doc_id
        val = t.$('.edit_text').val()
        field = Template.currentData()

        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $addToSet:"#{field.key}":@_id
        else if user
            Meteor.users.update parent._id,
                $addToSet:"#{field.key}":@_id


        t.user_results.set null
        $('#multi_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()

    'click .pull_user': ->
        if confirm "remove #{@username}?"
            page_doc = Docs.findOne Router.current().params.doc_id
            parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{@key}":@_id
            else if user
                Meteor.users.update parent._id,
                    $pull:"#{@key}":@_id
            # Meteor.call 'unassign_user', page_doc._id, @


Template.multi_doc_input.onCreated ->
    # @autorun => Meteor.subscribe 'model_docs', 'guest'
    @doc_results = new ReactiveVar
Template.multi_doc_input.helpers
    doc_results: -> Template.instance().doc_results.get()
Template.multi_doc_input.events
    'click .clear_results': (e,t)->
        t.doc_results.set null
    'keyup #multi_doc_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#multi_doc_select_input').val().trim()
        if search_value.length is 0
            t.doc_results.set null
        else if search_value
            Meteor.call 'lookup_doc', search_value, 'guest', (err,res)=>
                if err then console.error err
                else
                    # console.log res
                    t.doc_results.set res
    'click .select_doc': (e,t) ->
        # session_document = Docs.findOne Session.get('session_document')
        # if @direct
        #     parent = Template.parentData(1)
        # else
        #     parent = Template.parentData(5)
        parent = Docs.findOne _id: Router.current().params.doc_id
        Docs.update parent._id,
            $addToSet:guest_ids:@_id
        t.doc_results.set null
        $('#multi_user_select_input').val ''

    'click .pull_user': ->
        if confirm "Remove #{@username}?"
            page_doc = Docs.findOne Router.current().params.doc_id
            parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{@key}":@_id
            else if user
                Meteor.users.update parent._id,
                    $pull:"#{@key}":@_id
            # Meteor.call 'unassign_user', page_doc._id, @





Template.range_edit.onRendered ->
    # item = Template.currentData()
    $('#rangestart').calendar({
        type: 'datetime'
        today: true
        # type:'time'
        inline: true
        endCalendar: $('#rangeend')
        formatter: {
            date: (date, settings)->
                if !date then return ''
                mst_date = moment(date)
                mst_date.format("YYYY-MM-DD[T]hh:mm")
        }
    });
    $('#rangeend').calendar({
        type: 'datetime'
        today: true
        # type:'time'
        inline: true
        startCalendar: $('#rangestart')
        formatter: {
            date: (date, settings)->
                if !date then return ''
                mst_date = moment(date)
                mst_date.format("YYYY-MM-DD[T]hh:mm")

        }
    })

Template.range_edit.events
    'click .get_start': ->
        doc_id = Router.current().params.doc_id
        result = $('.ui.calendar').calendar('get startDate')[1]
        formatted = moment(result).format("YYYY-MM-DD[T]HH:mm")
        # moment_ob = moment(result)
        Docs.update doc_id,
            $set:start_datetime:formatted


    'click .get_end': ->
        doc_id = Router.current().params.doc_id
        result = $('.ui.calendar').calendar('get endDate')[0]
        console.log result
        formatted = moment(result).format("YYYY-MM-DD[T]HH:mm")
        console.log moment(@end_datetime).diff(moment(@start_datetime),'minutes',true)
        console.log moment(@end_datetime).diff(moment(@start_datetime),'hours',true)
        Docs.update doc_id,
            $set:end_datetime:formatted
