express = require('express')
path = require('path')
fs = require('fs')
nowjs = require('now')
child_process = require('child_process')

port = process.env.PORT || 8000
app = express.createServer()

console.log '===== Starting ACE Live on port ' + port + ' ====='

# Setup Template Engine
app.register '.coffee', require('coffeekup')
app.set 'view engine', 'coffee'

# Setup Static Files
public_path = path.resolve(__dirname, '..', 'public')
app.use express.static(public_path)

# Load lists of available editor modes and themes
ace_files = fs.readdirSync __dirname + '/../public/vendor/ace/build/src'
ace_modes = []; ace_themes = []
for file in ace_files
  if file.indexOf('mode-') == 0
    ace_modes.push(file.substring('mode-'.length, file.length - 3))
  else if file.indexOf('theme-') == 0
    ace_themes.push(file.substring('theme-'.length, file.length - 3))

child_process.exec 'tput bold', (error, bold, stderr) ->
  unless error?
    child_process.exec 'tput sgr0', (error, normal, stderr) ->
      unless error?
        console.log bold + 'Available modes: ' + normal + ace_modes.join(', ')
        console.log bold + 'Available themes: ' + normal + ace_themes.join(', ')

# App Routes
app.get '/', (request, response) ->
  response.render 'index',
    locals:
      ace_modes: ace_modes
      ace_themes: ace_themes

# Listen
app.listen port

# NowJS
everyone = nowjs.initialize(app)

everyone.now.sendPatch = (sender, patch_obj) ->
  everyone.now.applyPatch(sender, patch_obj)