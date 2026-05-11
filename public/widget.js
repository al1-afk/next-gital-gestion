/* GestiQ Lead Widget — paste this <script> tag on any page:
   <script src="https://api.gestiq.com/widget.js"
           data-workspace="<WIDGET_KEY>"
           data-api="https://api.gestiq.com"
           data-source="Landing nextgital.ma"
           data-color="#2563eb"
           data-target="#gestiq-form">
   </script>
   The widget renders an in-place form (or fills the element matched by
   data-target). Submissions go to <api>/api/public/leads with the
   workspace key in the X-Workspace-Key header. */
(function () {
  'use strict'

  var script = document.currentScript
  if (!script) return

  var workspace = script.getAttribute('data-workspace')
  if (!workspace) {
    console.error('[GestiQ Widget] data-workspace manquant')
    return
  }

  var apiBase    = (script.getAttribute('data-api') || '').replace(/\/+$/, '')
  if (!apiBase) {
    // Default to same origin as the script
    try { apiBase = new URL(script.src, document.baseURI).origin } catch (e) { apiBase = '' }
  }
  var source     = script.getAttribute('data-source')      || document.location.hostname + document.location.pathname
  var color      = script.getAttribute('data-color')       || '#2563eb'
  var buttonText = script.getAttribute('data-button-text') || 'Envoyer'
  var heading    = script.getAttribute('data-heading')     || 'Contactez-nous'
  var subheading = script.getAttribute('data-subheading')  || 'Notre équipe vous recontacte sous 24h.'
  var fieldsAttr = (script.getAttribute('data-fields')     || 'name,email,phone,message').toLowerCase()
  var fields     = fieldsAttr.split(',').map(function (f) { return f.trim() }).filter(Boolean)
  var targetSel  = script.getAttribute('data-target')

  /* ── Locate the host element ── */
  var host
  if (targetSel) {
    host = document.querySelector(targetSel)
    if (!host) {
      console.error('[GestiQ Widget] target introuvable :', targetSel)
      return
    }
  } else {
    host = document.createElement('div')
    script.parentNode.insertBefore(host, script)
  }

  /* ── Styles (scoped via prefix to avoid clashing with the host page) ── */
  var styleId = 'gestiq-widget-style'
  if (!document.getElementById(styleId)) {
    var s = document.createElement('style')
    s.id = styleId
    s.textContent =
      '.gw-card{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;' +
      'max-width:480px;background:#fff;border:1px solid #e5e7eb;border-radius:16px;' +
      'padding:24px;box-shadow:0 4px 14px rgba(0,0,0,.05);color:#0f172a}' +
      '.gw-card h3{margin:0 0 4px 0;font-size:20px;font-weight:700}' +
      '.gw-card p.gw-sub{margin:0 0 18px 0;font-size:13px;color:#64748b}' +
      '.gw-row{margin-bottom:12px}' +
      '.gw-row label{display:block;font-size:12px;font-weight:600;color:#334155;margin-bottom:4px}' +
      '.gw-row input,.gw-row textarea{width:100%;padding:10px 12px;border:1px solid #d1d5db;' +
      'border-radius:8px;font-size:14px;font-family:inherit;background:#fff;color:#0f172a;box-sizing:border-box;' +
      'transition:border-color .15s,box-shadow .15s}' +
      '.gw-row textarea{resize:vertical;min-height:80px}' +
      '.gw-row input:focus,.gw-row textarea:focus{outline:none;border-color:var(--gw-accent);' +
      'box-shadow:0 0 0 3px color-mix(in srgb, var(--gw-accent) 25%, transparent)}' +
      '.gw-btn{width:100%;padding:11px 18px;background:var(--gw-accent);color:#fff;border:none;' +
      'border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;' +
      'transition:opacity .15s}' +
      '.gw-btn:hover{opacity:.92}' +
      '.gw-btn:disabled{opacity:.55;cursor:wait}' +
      '.gw-msg{margin-top:12px;padding:10px 12px;border-radius:8px;font-size:13px;display:none}' +
      '.gw-msg.gw-ok{background:#ecfdf5;border:1px solid #a7f3d0;color:#065f46;display:block}' +
      '.gw-msg.gw-err{background:#fef2f2;border:1px solid #fecaca;color:#991b1b;display:block}' +
      '.gw-hp{position:absolute!important;left:-9999px!important;width:1px!important;height:1px!important;' +
      'opacity:0!important;pointer-events:none!important}' +
      '@media (prefers-color-scheme: dark){' +
      '.gw-card{background:#0b1220;border-color:#1f2937;color:#e5e7eb}' +
      '.gw-card p.gw-sub{color:#94a3b8}' +
      '.gw-row label{color:#cbd5e1}' +
      '.gw-row input,.gw-row textarea{background:#0f172a;border-color:#334155;color:#e5e7eb}' +
      '}'
    document.head.appendChild(s)
  }

  /* ── Render ── */
  var FIELD_DEFS = {
    name:    { label: 'Nom complet *',    type: 'input',    inputType: 'text',  required: true,  autocomplete: 'name' },
    email:   { label: 'Email',            type: 'input',    inputType: 'email', required: false, autocomplete: 'email' },
    phone:   { label: 'Téléphone',        type: 'input',    inputType: 'tel',   required: false, autocomplete: 'tel' },
    company: { label: 'Entreprise',       type: 'input',    inputType: 'text',  required: false, autocomplete: 'organization' },
    message: { label: 'Votre message',    type: 'textarea', inputType: '',      required: false, autocomplete: 'off' },
  }

  var rowsHtml = fields.map(function (f) {
    var def = FIELD_DEFS[f]
    if (!def) return ''
    var ctrl = def.type === 'textarea'
      ? '<textarea name="' + f + '" rows="3" autocomplete="' + def.autocomplete + '"' + (def.required ? ' required' : '') + '></textarea>'
      : '<input name="' + f + '" type="' + def.inputType + '" autocomplete="' + def.autocomplete + '"' + (def.required ? ' required' : '') + '>'
    return '<div class="gw-row"><label>' + def.label + '</label>' + ctrl + '</div>'
  }).join('')

  host.innerHTML =
    '<div class="gw-card" style="--gw-accent:' + escapeAttr(color) + '">' +
      '<h3>' + escapeHtml(heading) + '</h3>' +
      '<p class="gw-sub">' + escapeHtml(subheading) + '</p>' +
      '<form class="gw-form" novalidate>' +
        rowsHtml +
        '<input class="gw-hp" type="text" name="_hp" tabindex="-1" autocomplete="off">' +
        '<button class="gw-btn" type="submit">' + escapeHtml(buttonText) + '</button>' +
        '<div class="gw-msg" role="status"></div>' +
      '</form>' +
    '</div>'

  var form   = host.querySelector('.gw-form')
  var msgEl  = host.querySelector('.gw-msg')
  var btnEl  = host.querySelector('.gw-btn')
  var btnTxt = btnEl.textContent

  form.addEventListener('submit', function (e) {
    e.preventDefault()
    msgEl.className = 'gw-msg'
    msgEl.textContent = ''

    var body = { source: source, _hp: form._hp ? form._hp.value : '' }
    fields.forEach(function (f) {
      var el = form.querySelector('[name="' + f + '"]')
      if (el) body[f] = (el.value || '').trim()
    })

    if (!body.name) {
      msgEl.className = 'gw-msg gw-err'
      msgEl.textContent = 'Veuillez renseigner votre nom.'
      return
    }

    btnEl.disabled = true
    btnEl.textContent = 'Envoi…'

    fetch(apiBase + '/api/public/leads', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-Workspace-Key': workspace },
      body: JSON.stringify(body),
    })
      .then(function (r) { return r.json().then(function (j) { return { ok: r.ok, j: j } }) })
      .then(function (res) {
        if (!res.ok) throw new Error((res.j && res.j.error) || 'Erreur réseau')
        msgEl.className = 'gw-msg gw-ok'
        msgEl.textContent = 'Merci ! Nous vous recontactons très vite.'
        form.reset()
      })
      .catch(function (err) {
        msgEl.className = 'gw-msg gw-err'
        msgEl.textContent = 'Échec : ' + (err && err.message ? err.message : 'réessayez plus tard.')
      })
      .finally(function () {
        btnEl.disabled = false
        btnEl.textContent = btnTxt
      })
  })

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
    })
  }
  function escapeAttr(s) { return escapeHtml(s).replace(/[`;]/g, '') }
})()
