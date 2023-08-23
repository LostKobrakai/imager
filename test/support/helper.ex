defmodule Imager.Helper do
  alias Imager.ThumborPath
  import ExUnit.Assertions

  def thumbor_endpoint do
    Application.fetch_env!(:imager, :thumbor_endpoint)
  end

  def thumbor_host_type do
    Application.fetch_env!(:imager, :thumbor_host_type)
  end

  def paths(root, source) do
    for key <- [:thumbor, :imager, :compare], into: %{} do
      {key, Path.join(root, "#{key}." <> Path.basename(source))}
    end
  end

  def full_source(thumbor_path, :thumbor) do
    %ThumborPath{thumbor_path | source: url(thumbor_host_type(), thumbor_path.source)}
  end

  def full_source(thumbor_path, :imager) do
    %ThumborPath{thumbor_path | source: url(:local, thumbor_path.source)}
  end

  defp url(host, path) do
    %URI{
      scheme: "http",
      host:
        case host do
          :local -> "localhost"
          :docker -> "host.docker.internal"
          :ci -> "172.17.0.1"
        end,
      port: 4001,
      path: Path.join(["/", "public", path])
    }
    |> URI.to_string()
  end

  def fetch(thumbor_path, file, opts \\ []) do
    endpoint = Keyword.fetch!(opts, :endpoint)
    force = Keyword.get(opts, :force, false)
    stream = Keyword.get(opts, :stream, false)
    secret = Keyword.get(opts, :secret, nil)

    query_params = %{stream: stream, secret: secret}

    url =
      URI.parse(endpoint)
      |> Map.put(:path, ThumborPath.build(thumbor_path, nil))
      |> Map.put(:query, Plug.Conn.Query.encode(query_params))
      |> URI.to_string()

    if force or !File.exists?(file) do
      request = Finch.build(:get, url)

      with {:ok, %{status: 200} = response} <- Finch.request(request, Imager.Finch),
           :ok <- File.write(file, response.body) do
        {:ok, file}
      else
        err -> {:error, err}
      end
    else
      {:ok, :exists}
    end
  end

  def assert_similar(img1, img2, similarity, path) do
    with {:ok, timg} <- Image.open(img1),
         {:ok, iimg} <- Image.open(img2),
         {:ok, result, cimg} <- Image.compare(timg, iimg, metric: :rmse, difference_boost: 2.5),
         {:ok, _} <- Image.write(cimg, path) do
      assert_in_delta result, 0.0, similarity, "Images differ"
    else
      _ -> flunk("Error comparing images")
    end
  end
end
