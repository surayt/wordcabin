// Taken from
// https://github.com/dreyercalitz/tinymce-rails-fileupload/blob/master/app/assets/javascripts/tinymce/plugins/uploadfile/plugin.js,
// Changed line 179 to produce a link having a CSS class for easier identification of file links.
// Pasted English translations at the bottom instead of keeping them in a separate file.

(function() {
  tinymce.PluginManager.requireLangPack('uploadfile', 'en,de');

  tinymce.create('tinymce.plugins.UploadFile', {
    UploadFile: function(ed, url) {
      var form,
          iframe,
          win,
          editor = ed;

      function showDialog() {  
        win = editor.windowManager.open({
          title: ed.translate('Upload a file from your computer'),
          width:  500 + parseInt(editor.getLang('uploadfile.delta_width', 0), 10),
          height: 180 + parseInt(editor.getLang('uploadfile.delta_height', 0), 10),
          body: [
            {type: 'iframe',  url: 'javascript:void(0)'},
            {type: 'textbox', name: 'document[file]', label: ed.translate('Choose a file'), subtype: 'file'},
            {type: 'textbox', name: 'document[title]', label: ed.translate('Link text'), value: tinymce.activeEditor.selection.getContent()},
            {type: 'container', classes: 'error', html: "<p style='color: #b94a48;'>&nbsp;</p>"}
          ],
          buttons: [
            {
              text: ed.translate('Insert'),
              onclick: insertFile,
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

        // TinyMCE likes pointless submit handlers
        win.off('submit');
        win.on('submit', insertFile);

        iframe = win.find("iframe")[0];
        form = createElement('form', {
          action: ed.getParam("uploadfile_form_url", '/files'),
          target: iframe._id,
          method: "POST",
          enctype: 'multipart/form-data',
          accept_charset: "UTF-8",
        });

        // Might have several instances on the same page,
        // so we TinyMCE create unique IDs and use those.
        iframe.getEl().name = iframe._id;

        // Create some needed hidden inputs
        form.appendChild(createElement('input', {type: "hidden", name: "utf8", value: "✓"}));
        form.appendChild(createElement('input', {type: 'hidden', name: 'authenticity_token', value: getMetaContents('csrf-token')}));

        var el = win.getEl();
        var body = document.getElementById(el.id + "-body");

        // Copy everything TinyMCE made into our form
        var containers = body.getElementsByClassName('mce-container');
        for(var i = 0; i < containers.length; i++) {
          form.appendChild(containers[i]);
        }

        // Fix inputs, since TinyMCE hates HTML and forms
        var inputs = form.getElementsByTagName('input');
        for(var i = 0; i < inputs.length; i++) {
          var ctrl = inputs[i];

          if(ctrl.tagName.toLowerCase() == 'input' && ctrl.type != "hidden") {
            if(ctrl.type == "file") {
              ctrl.name = "document[file]";
              
              // Hack styles
              var padding = '0';
              if(window.navigator.userAgent.match(/(Chrome|Safari)/))
                padding = '7px 0';
              
              tinymce.DOM.setStyles(ctrl, {
                'border': 0,
                'boxShadow': 'none',
                'webkitBoxShadow': 'none',
                'padding': padding
              });
            } else if(ctrl.type == "text") {
              ctrl.name = "document[title]";
            }
          }
        }

        body.appendChild(form);
      }

      function insertFile() {
        if(getInputValue("document[file]") == "") {
          return handleError('You must choose a file');
        }

        clearErrors();

        /* Add event listeners.
         * We remove the existing to avoid them being called twice in case
         * of errors and re-submitting afterwards.
         */
        var target = iframe.getEl();
        if(target.attachEvent) {
          target.detachEvent('onload', uploadDone);
          target.attachEvent('onload', uploadDone);
        } else {
          target.removeEventListener('load', uploadDone);
          target.addEventListener('load', uploadDone, false);
        }

        form.submit();
      }

      function uploadDone() {
        var target = iframe.getEl();
        if(target.document || target.contentDocument) {
          var doc = target.contentDocument || target.contentWindow.document;
          handleResponse(doc.getElementsByTagName("body")[0].innerHTML);
        } else {
          handleError("Did not get a response from the server");
        }
      }

      function handleResponse(ret) {
        try {
          var json = tinymce.util.JSON.parse(ret);

          if(json["error"]) {
            handleError(json["error"]["message"]);
          } else {
            ed.execCommand('mceInsertContent', false, buildHTML(json));
            ed.windowManager.close();
          }
        } catch(e) {
          handleError('Got a bad response from the server');
        }
      }

      function clearErrors() {
        var message = win.find(".error")[0].getEl();

        if(message)
          message.getElementsByTagName("p")[0].innerHTML = "&nbsp;";
      }

      function handleError(error) {
        console.log(error);
        var message = win.find(".error")[0].getEl();

        if(message)
          message.getElementsByTagName("p")[0].innerHTML = ed.translate(_.escape(error));
      }

      function createElement(element, attributes) {
        var el = document.createElement(element);
        for(var property in attributes) {
          if (!(attributes[property] instanceof Function)) {
            el[property] = attributes[property];
          }
        }

        return el;
      }

      function buildHTML(json) {
        var url = json["document"]["url"];
        var title = json["document"]["title"];
        var link = '<a href="' + url + '" title="' + title + '" class="file">' + title + '</a>';
        
        return link;
      }

      function getInputValue(name) {
        var inputs = form.getElementsByTagName("input");

        for(var i in inputs)
          if(inputs[i].name == name)
            return inputs[i].value;

        return "";
      }

      function getMetaContents(mn) {
        var m = document.getElementsByTagName('meta');

        for(var i in m)
          if(m[i].name == mn)
            return m[i].content;

        return null;
      }

      // Add a button that opens a window
      editor.addButton('uploadfile', {
        tooltip: ed.translate('Upload a file from your computer'),
        icon : 'fa-upload',
        onclick: showDialog
      });

      // Adds a menu item to the tools menu
      editor.addMenuItem('uploadfile', {
        text: ed.translate('Upload a file from your computer'),
        icon : 'fa-upload',
        context: 'insert',
        onclick: showDialog
      });
    }
  });

  tinymce.PluginManager.add('uploadfile', tinymce.plugins.UploadFile);
})();
