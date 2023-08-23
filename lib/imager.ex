defmodule Imager do
  @moduledoc """
  Documentation for `Imager`.
  """
  use Plug.Builder
  import Plug.Conn
  alias Imager.ThumborPath

  plug :check_hmac
  plug :parse_path
  plug :fetch_source
  plug :build_image

  @impl true
  def init(opts) do
    %{
      http_adapter: Keyword.fetch!(opts, :http_adapter),
      stream: Keyword.get(opts, :stream, false)
    }
  end

  @impl true
  def call(conn, opts) do
    conn
    |> assign(:http_adapter, opts.http_adapter)
    |> assign(:stream, opts.stream)
    |> super([])
  end

  defp check_hmac(conn, _) do
    if ThumborPath.valid?(Path.join(conn.path_info), nil && conn.assigns.secret) do
      conn
    else
      conn
      |> send_resp(:forbidden, "")
      |> halt()
    end
  end

  defp parse_path(conn, _) do
    assign(conn, :thumbor_path, conn.path_info |> Path.join() |> ThumborPath.parse())
  end

  defp fetch_source(conn, _) do
    %ThumborPath{} = thumbor_path = conn.assigns.thumbor_path

    case conn.assigns.http_adapter.get(thumbor_path.source) do
      {:ok, _headers, body} -> assign(conn, :source, body)
      {:error, status, body} -> send_resp(conn, status, body) |> halt()
    end
  end

  defp build_image(conn, _) do
    %ThumborPath{} = thumbor_path = conn.assigns.thumbor_path

    image =
      conn.assigns.source
      |> Image.from_binary!()
      |> apply_crop(thumbor_path.crop)
      |> apply_size(thumbor_path.size, thumbor_path)

    if conn.assigns.stream do
      image
      |> stream_image(thumbor_path)
      |> Enum.reduce_while(conn, fn chunk, conn ->
        case chunk(conn, chunk) do
          {:ok, conn} -> {:cont, conn}
          {:error, :closed} -> {:halt, conn}
        end
      end)
    else
      {:ok, file} = write_image(image, thumbor_path)
      send_resp(conn, 200, file)
    end
  end

  defp apply_crop(image, {{ax, ay}, {bx, by}}) do
    Image.crop!(image, [{ax, ay}, {bx, ay}, {bx, by}, {ax, by}])
  end

  defp apply_crop(image, _) do
    image
  end

  defp apply_size(image, {a, b}, thumbor_path) do
    {width, height, _} = Image.shape(image)

    crop =
      if width <= height do
        case thumbor_path.vertical_align || :middle do
          :top -> :high
          :middle -> :center
          :bottom -> :low
        end
      else
        case thumbor_path.horizontal_align || :center do
          :left -> :high
          :center -> :center
          :right -> :low
        end
      end

    opts =
      case thumbor_path.fit do
        :default -> [crop: crop]
        {:fit, _} -> [crop: :none, resize: :both]
      end

    Image.thumbnail!(
      image,
      size_and_dimensions_to_thumbnail({a, b}, {width, height}),
      opts
    )
  end

  defp apply_size(image, _, _) do
    image
  end

  defp size_and_dimensions_to_thumbnail({0, b}, {w, h}) do
    a = trunc(w / h * b)
    size_and_dimensions_to_thumbnail({a, b}, {w, h})
  end

  defp size_and_dimensions_to_thumbnail({a, 0}, {w, h}) do
    b = trunc(h / w * a)
    size_and_dimensions_to_thumbnail({a, b}, {w, h})
  end

  defp size_and_dimensions_to_thumbnail({a, b}, _), do: "#{a}x#{b}"

  defp write_image(image, thumbor_path) do
    Image.write(image, :memory, write_opts(thumbor_path.source))
  end

  defp stream_image(image, thumbor_path) do
    Image.stream!(image, write_opts(thumbor_path.source) ++ [buffer_size: 5_000_000])
  end

  defp write_opts(source) do
    source
    |> URI.new!()
    |> Map.get(:path)
    |> Path.extname()
    |> String.downcase()
    |> case do
      jpg when jpg in [".jpg", "jpeg"] -> [suffix: ".jpg", progressive: true, quality: 100]
      ".png" -> [suffix: ".png", progressive: true]
      suffix -> [suffix: suffix]
    end
  end
end
