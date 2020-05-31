defmodule Lngrpc.Repo do
  use Ecto.Repo,
    otp_app: :lngrpc,
    adapter: Ecto.Adapters.Postgres
end
