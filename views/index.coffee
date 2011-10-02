div id: 'editor'

div id: 'toolbox', ->
  select id: 'mode_selector', ->
    option mode for mode in @ace_modes

  select id: 'theme_selector', ->
    option theme for theme in @ace_themes

script "window.initial_content = '#{@doc}';"
coffeescript ->
  window.editor = null
  window.session = null
  dmp = null
  previous = window.initial_content
  just_received = false

  $.getScript '/vendor/ace/build/src/ace-uncompressed.js', ->
    window.editor = ace.edit 'editor'
    window.session = window.editor.getSession()
    window.session.setValue(window.initial_content)

    Range = require('ace/range').Range

    $.getScript '/nowjs/now.js', ->
      $.getScript '/vendor/diff_match_patch.js', ->
        dmp = new diff_match_patch()

        now.ready ->
          user_id = new Date().getTime()

          now.applyPatch = (sender_id, patch) ->
            return if sender_id == user_id

            just_received = true
            window.session.setValue(dmp.patch_apply(patch, window.session.getValue())[0])
            just_received = false

          session.on 'change', (diff_obj) ->
            return if just_received

            new_value = window.session.getValue()
            patch = dmp.patch_make(previous, new_value)
            previous = new_value
            now.sendPatch user_id, patch

    switchMode = (mode) ->
      $.getScript '/vendor/ace/build/src/mode-' + mode + '.js', ->
        mode = require('ace/mode/' + mode).Mode
        window.session.setMode(new mode())

    $('#mode_selector').change ->
      switchMode $(this).val()
      editor.focus()

    $('#mode_selector').val('java')
    switchMode 'java'

    switchTheme = (theme) ->
      $.getScript '/vendor/ace/build/src/theme-' + theme + '.js', ->
        window.editor.setTheme('ace/theme/' + theme)

    $('#theme_selector').change ->
      switchTheme $(this).val()
      editor.focus()