defmodule DocChat.Repo do
  use Ecto.Repo,
    otp_app: :doc_chat,
    adapter: Ecto.Adapters.Postgres
end
