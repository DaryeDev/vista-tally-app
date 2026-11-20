// Page logic. `Vista` is provided by the app page:
//   Vista.post({op: ...})   -> logic.lua gets vista.on('phone', function(cmd) ... end)
//   Vista.onState(fn)       -> fn(state), the table logic.lua last passed to vista.render()
(function () {
  var $ = function (id) { return document.getElementById(id); };
  var text = $('text'), count = $('count'), status = $('status');
  var size = 'small', color = 'cream', first = true;

  function mark(group, value) {
    Array.prototype.forEach.call($(group).children, function (b) {
      b.setAttribute('aria-pressed', b.getAttribute('data-v') === value ? 'true' : 'false');
    });
  }

  function counter() { count.textContent = text.value.length + ' / 280'; }

  function send() {
    Vista.post({ op: 'set', text: text.value, size: size, color: color });
  }

  text.addEventListener('input', counter);
  $('send').addEventListener('click', send);
  $('size').addEventListener('click', function (e) {
    var v = e.target.getAttribute('data-v');
    if (v) { size = v; mark('size', v); send(); }
  });
  $('color').addEventListener('click', function (e) {
    var v = e.target.getAttribute('data-v');
    if (v) { color = v; mark('color', v); send(); }
  });

  Vista.onState(function (s) {
    size = s.size || size;
    color = s.color || color;
    mark('size', size);
    mark('color', color);
    // Fill the box from the saved note once; never overwrite what is being typed.
    if (first || document.activeElement !== text) {
      if (text.value !== (s.text || '')) text.value = s.text || '';
      first = false;
    }
    counter();
    status.textContent = s.len > 0 ? 'On the glasses: ' + s.len + ' characters' : 'Nothing on the glasses yet';
  });

  mark('size', size);
  mark('color', color);
  counter();
})();
