defmodule Imager.Endpoint do
  use Plug.Builder

  plug :fetch_query_params
  plug :run

  def run(conn, _) do
    plug_opts =
      case conn.query_params["stream"] do
        "true" -> [http_adapter: Imager.FinchAdapter, stream: true]
        _ -> [http_adapter: Imager.FinchAdapter, stream: false]
      end

    Plug.run(conn, [{Imager, plug_opts}])
  end
end
