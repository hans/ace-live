(function() {
  var ace_files, ace_modes, ace_themes, app, child_process, everyone, express, file, fs, nowjs, path, port, public_path, _i, _len;
  express = require('express');
  path = require('path');
  fs = require('fs');
  nowjs = require('now');
  child_process = require('child_process');
  port = process.env.PORT || 8000;
  app = express.createServer();
  console.log('===== Starting ACE Live on port ' + port + ' =====');
  app.register('.coffee', require('coffeekup'));
  app.set('view engine', 'coffee');
  public_path = path.resolve(__dirname, '..', 'public');
  app.use(express.static(public_path));
  ace_files = fs.readdirSync(__dirname + '/../public/vendor/ace/build/src');
  ace_modes = [];
  ace_themes = [];
  for (_i = 0, _len = ace_files.length; _i < _len; _i++) {
    file = ace_files[_i];
    if (file.indexOf('mode-') === 0) {
      ace_modes.push(file.substring('mode-'.length, file.length - 3));
    } else if (file.indexOf('theme-') === 0) {
      ace_themes.push(file.substring('theme-'.length, file.length - 3));
    }
  }
  child_process.exec('tput bold', function(error, bold, stderr) {
    if (error == null) {
      return child_process.exec('tput sgr0', function(error, normal, stderr) {
        if (error == null) {
          console.log(bold + 'Available modes: ' + normal + ace_modes.join(', '));
          return console.log(bold + 'Available themes: ' + normal + ace_themes.join(', '));
        }
      });
    }
  });
  app.get('/', function(request, response) {
    return response.render('index', {
      locals: {
        ace_modes: ace_modes,
        ace_themes: ace_themes
      }
    });
  });
  app.listen(port);
  everyone = nowjs.initialize(app);
  everyone.now.sendPatch = function(sender, patch_obj) {
    return everyone.now.applyPatch(sender, patch_obj);
  };
}).call(this);
