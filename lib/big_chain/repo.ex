defmodule BigChain.Repo do
  use Ecto.Repo,
    otp_app: :big_chain,
    adapter: Ecto.Adapters.Postgres
end
