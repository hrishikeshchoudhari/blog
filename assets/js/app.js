// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import { CodeEditorHook } from "../../deps/live_monaco_editor/priv/static/live_monaco_editor.esm"

let Hooks = {}
Hooks.CodeEditorHook = CodeEditorHook

// Scroll to top hook for pagination
Hooks.ScrollToTop = {
  mounted() {
    // Store the current page number
    this.page = this.el.dataset.page
  },
  
  updated() {
    // Check if page number changed
    const newPage = this.el.dataset.page
    if (newPage !== this.page) {
      this.page = newPage
      
      // Instant scroll to top
      window.scrollTo(0, 0)
      
      // Alternative: Smooth scroll
      // window.scrollTo({
      //   top: 0,
      //   behavior: 'smooth'
      // })
    }
  }
}

// Navigation scroll hook - scrolls to top on any navigation
Hooks.NavScrollTop = {
  mounted() {
    this.handleClick = (e) => {
      // Check if it's a LiveView navigation link
      const link = e.target.closest('a[data-phx-link]')
      if (link && (link.dataset.phxLink === 'patch' || link.dataset.phxLink === 'navigate')) {
        // Small delay to ensure navigation starts before scroll
        setTimeout(() => window.scrollTo(0, 0), 50)
      }
    }
    
    this.el.addEventListener('click', this.handleClick)
  },
  
  destroyed() {
    this.el.removeEventListener('click', this.handleClick)
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.addEventListener("lme:editor_mounted", (ev) => {
    const hook = ev.detail.hook

    // https://microsoft.github.io/monaco-editor/docs.html#interfaces/editor.IStandaloneCodeEditor.html
    const editor = ev.detail.editor.standalone_code_editor

    // push an event to the parent liveview containing the editor current value when the editor loses focus
    editor.onDidBlurEditorWidget(() => {
        hook.pushEvent("code-editor-lost-focus", { textBody: editor.getValue() })
    })
})

