// TODO: i18n! (See uploadfile.js for how to do so)

(function() {
  tinymce.create('tinymce.plugins.InsertExercise', {
    InsertExercise: function(ed, url) {
      var form, iframe, win, editor = ed;
      
      function showDialog() {
        win = editor.windowManager.open({
          title: ed.translate('Insert an exercise'),
          width:  500 + parseInt(editor.getLang('insertexercise.delta_width',  0), 10),
          height: 190 + parseInt(editor.getLang('insertexercise.delta_height', 0), 10),
          body: [
            {type: 'iframe',  url: 'javascript:void(0)'},
            {type: 'listbox', name: 'document[exercise_id]', label: ed.translate('Choose an exercise')},
            {type: 'container', classes: 'legend', html: '<p>'+ed.translate("If you haven't prepared an   \
               exercise yet, you may close this dialog and<br/>navigate to the exercise management screen \
               (see the buttons in the<br/>upper right corner) and create one there. Once you open this   \
               dialog<br/>again, you will be able to select your exercise in the above menu.")+'</p>'},
            {type: 'container', classes: 'error', html: '<p style="color:#b94a48;"></p>'},
          ],
          buttons: [
            {
              text: ed.translate('Insert'),
              onclick: insertExercise,
              subtype: 'primary'
            },
            {
              text: ed.translate('Cancel'),
              onclick: ed.windowManager.close
            }
          ],
        }, {
          plugin_url: url
        });
        
        // Original comment: "TinyMCE likes pointless submit 
        // handlers" (see uploadfile plugin for more info?)
        win.off('submit');
        win.on('submit', insertExercise);

        iframe = win.find('iframe')[0];
        form = createElement('form', {
          action: ed.getParam('insertexercise_form_url', '/exercises'),
          target: iframe._id,
          method: 'GET',
          accept_charset: 'UTF-8',
        });
        // Might have several instances on the same page,
        // so we TinyMCE create unique IDs and use those.
        iframe.getEl().name = iframe._id;
        // Create some needed hidden inputs
        form.appendChild(createElement('input', {type: 'hidden', name: 'utf8', value: '✓'}));
        form.appendChild(createElement('input', {type: 'hidden', name: 'authenticity_token', value: getMetaContents('csrf-token')}));

        var el = win.getEl();
        var body = document.getElementById(el.id + "-body");

        // Copy everything TinyMCE made into our form
        var containers = body.getElementsByClassName('mce-container');
        for(var i = 0; i < containers.length; i++) {
          form.appendChild(containers[i]);
        }

        body.appendChild(form);
      }
      
      function insertExercise() {
        if (getInputValue('document[exercise_id]') == '') {
          return handleError('You must choose an exercise to be inserted into the document.');
        } else {
          ed.execCommand('mceInsertContent', false, '<p>Jippiiiiieeeee! (TODO: das Richtige einfügen!)</p>');
          ed.windowManager.close();
        }
        
        clearErrors();
      }

      function createElement(element, attributes) {
        var el = document.createElement(element);
        for (var property in attributes) {
          if (!(attributes[property] instanceof Function)) {
            el[property] = attributes[property];
          }
        }

        return el;
      }

      function getMetaContents(mn) {
        var m = document.getElementsByTagName('meta');

        for (var i in m) {
          if (m[i].name == mn) {
            return m[i].content;
          }
        }

        return null;
      }

      function getInputValue(name) {
        var inputs = form.getElementsByTagName('button');

        for (var i in inputs) {
          if (inputs[i].name == name) {
            return inputs[i].value;
          }
        }

        return '';
      }

      function clearErrors() {
        var message = win.find('.error')[0].getEl();

        if (message) {
          message.getElementsByTagName('p')[0].innerHTML = '';
        }
      }

      function handleError(error) {
        var message = win.find('.error')[0].getEl();

        if (message) {
          message.getElementsByTagName('p')[0].innerHTML = ed.translate(_.escape(error));
        }
      }
      
      // Add a button that opens a window
      editor.addButton('insertexercise', {
        tooltip: ed.translate('Insert a prepared exercise'),
        icon : 'fa-check-square-o',
        onclick: showDialog
      });

      // Adds a menu item to the tools menu
      editor.addMenuItem('insertexercise', {
        text: ed.translate('Insert a prepared exercise'),
        icon : 'fa-check-square-o',
        context: 'insert',
        onclick: showDialog
      });
    }
  });
  
  tinymce.PluginManager.add('insertexercise', tinymce.plugins.InsertExercise);
}) ();
