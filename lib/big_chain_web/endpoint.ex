defmodule BigChainWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :big_chain

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    # Currently we're saving the cart in the session cookie, however, it has a limit of 4096bytes and
    # I've crossed it twice during development. This said, it was really not a good idea to leave this as simple
    # as storing the session in cookies, yet it's already too late to change it now to a database-backed solution
    # (since we need to work on migrations and relationships). So, for the sake of this exercise, let's store the data server side under an ETS.
    store: :ets,
    key: "_big_chain_key",
    signing_salt: "44s/4mrU",
    same_site: "Lax",
    table: :session_table
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :big_chain,
    gzip: false,
    only: BigChainWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :big_chain
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug BigChainWeb.Router
end
