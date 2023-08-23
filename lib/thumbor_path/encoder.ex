defmodule Imager.ThumborPath.Encoder do
  @moduledoc false
  alias Imager.ThumborPath

  def build(%ThumborPath{} = uri, secret) do
    img_path = build_image_path(uri)
    encode(%{uri | hmac: ThumborPath.signature(img_path, secret)}, img_path)
  end

  def encode(%ThumborPath{} = uri, img_path \\ nil) do
    img_path = img_path || build_image_path(uri)

    case uri.hmac do
      :unsafe -> "unsafe"
      hmac -> hmac
    end
    |> Path.join(img_path)
  end

  @doc false
  def build_image_path(%ThumborPath{} = uri) do
    commands =
      [
        if(uri.meta, do: "meta", else: nil),
        case uri.trim do
          nil -> nil
          :top_left -> "trim:top-left"
          :bottom_right -> "trim:bottom-right"
        end,
        with {{a, b}, {c, d}} <- uri.crop do
          "#{a}x#{b}:#{c}x#{d}"
        end,
        with {:fit, opts} <- uri.fit do
          [
            if(:adaptive in opts, do: "adaptive-"),
            if(:full in opts, do: "full-"),
            "fit-in"
          ]
          |> Enum.join("")
        else
          :default -> nil
        end,
        with {a, b} <- uri.size do
          "#{a}x#{b}"
        end,
        case uri.horizontal_align do
          nil -> nil
          :left -> "left"
          :center -> "center"
          :right -> "right"
        end,
        case uri.vertical_align do
          nil -> nil
          :top -> "top"
          :middle -> "middle"
          :bottom -> "bottom"
        end,
        if(uri.smart, do: "smart", else: nil),
        with list when list != [] <- uri.filters do
          "filters:" <> Enum.join(list, ":")
        end
      ]
      |> Enum.reject(&(&1 == nil || &1 == ""))

    [commands, URI.encode_www_form(uri.source)]
    |> List.flatten()
    |> Path.join()
  end
end
