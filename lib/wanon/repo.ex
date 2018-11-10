defmodule Wanon.Repo do
  use Ecto.Repo,
    otp_app: :wanon,
    adapter: Ecto.Adapters.Postgres
end
