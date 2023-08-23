defmodule Imager.Endpoint do
  use Plug.Builder

  plug :fetch_query_params
  plug :run

  def run(conn, _) do
    plug_opts =
      Enum.reduce(conn.query_params, [http_adapter: Imager.FinchAdapter, secret: nil], fn
        {"stream", "true"}, acc ->
          Keyword.put(acc, :stream, true)

        # Don't do it like that in production!
        {"secret", secret}, acc when byte_size(secret) > 0 ->
          Keyword.put(acc, :secret, secret)

        _, acc ->
          acc
      end)

    Plug.run(conn, [{Imager, plug_opts}])
  end
end
