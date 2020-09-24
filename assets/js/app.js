// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}

Hooks.StartCamera = {
  mounted() {
    let hook = this;
    const video = this.el;
    navigator.mediaDevices.getUserMedia({
      audio: true,
      video: true
    }).then((cameraStream) => {
      video.srcObject = cameraStream;
      video.onloadedmetadata = function (e) {
        video.play();
        let mediaRecorder = new MediaRecorder(cameraStream, {
          mimeType: 'video/webm',
          videoBitsPerSecond: 3000000
        });
        mediaRecorder.ondataavailable = (e) => {
          var reader = new FileReader();
          reader.onloadend = function () {
            hook.pushEvent("video_data", { data: reader.result });
          }
          reader.readAsDataURL(e.data);
        }
        mediaRecorder.start(1000);
      }
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

