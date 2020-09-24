defmodule MuxLiveviewWeb.PageLive do
  use MuxLiveviewWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        {:ok, %{"stream_key" => stream_key}, _env} =
          Mux.Video.LiveStreams.create(Mux.client(), %{
            playback_policy: "public",
            new_asset_settings: %{playback_policy: "public"}
          })

        assign(socket, :porcelain_process, spawn_ffmpeg(stream_key))
      else
        socket
      end

    {:ok, socket}
  end

  defp spawn_ffmpeg(key) do
    # Copied from https://github.com/MuxLabs/wocket/blob/master/server.js
    ffmpeg_args =
      ~w(-i - -c:v libx264 -preset veryfast -tune zerolatency -c:a aac -ar 44100 -b:a 64k -y -use_wallclock_as_timestamps 1 -async 1 -bufsize 1000 -f flv)

    Porcelain.spawn("ffmpeg", ffmpeg_args ++ ["rtmps://global-live.mux.com/app/#{key}"])
  end

  @impl true
  def handle_event("video_data", %{"data" => "data:video/x-matroska;codecs=avc1,opus;base64," <> data}, socket) do
    Porcelain.Process.send_input(socket.assigns.porcelain_process, Base.decode64!(data))
    {:noreply, socket}
  end
end
