defmodule Imager.ThumborPath.Parser do
  @moduledoc false
  alias Imager.ThumborPath

  @parts [
    :hmac,
    :meta,
    :trim,
    :crop,
    :fit,
    :size,
    :horizontal_align,
    :vertical_align,
    :smart,
    :filters,
    :source
  ]

  def parse(path) do
    segments = path |> Path.relative() |> Path.split()

    {[], acc} =
      Enum.reduce(@parts, {segments, %ThumborPath{}}, fn
        :hmac, {rest, acc} -> parse_hmac(rest, acc)
        :meta, {rest, acc} -> parse_meta(rest, acc)
        :trim, {rest, acc} -> parse_trim(rest, acc)
        :crop, {rest, acc} -> parse_crop(rest, acc)
        :fit, {rest, acc} -> parse_fit(rest, acc)
        :size, {rest, acc} -> parse_size(rest, acc)
        :horizontal_align, {rest, acc} -> parse_horizontal_align(rest, acc)
        :vertical_align, {rest, acc} -> parse_vertical_align(rest, acc)
        :smart, {rest, acc} -> parse_smart(rest, acc)
        :filters, {rest, acc} -> parse_filters(rest, acc)
        :source, {rest, acc} -> parse_source(rest, acc)
      end)

    acc
  end

  # https://thumbor.readthedocs.io/en/latest/security.html
  defp parse_hmac(["unsafe" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | hmac: :unsafe}}
  end

  defp parse_hmac([auth_code | rest], %ThumborPath{} = acc)
       when is_binary(auth_code) and byte_size(auth_code) == 28 do
    {rest, %ThumborPath{acc | hmac: auth_code}}
  end

  defp parse_hmac(rest, %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | hmac: nil}}
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#metadata-endpoint
  defp parse_meta(["meta" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | meta: true}}
  end

  defp parse_meta(rest, %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | meta: false}}
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#trim
  defp parse_trim(["trim" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | trim: :top_left}}
  end

  defp parse_trim(["trim:top-left" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | trim: :top_left}}
  end

  defp parse_trim(["trim:bottom-right" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | trim: :bottom_right}}
  end

  defp parse_trim(rest, %ThumborPath{} = acc) do
    {rest, acc}
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#manual-crop
  defp parse_crop([maybe_crop | rest], %ThumborPath{} = acc) do
    with [a, b, c, d] <-
           Regex.run(~r/^(\d+)x(\d+):(\d+)x(\d+)$/, maybe_crop, capture: :all_but_first),
         {:ok, a} <- parse_crop_coordinate(a),
         {:ok, b} <- parse_crop_coordinate(b),
         {:ok, c} <- parse_crop_coordinate(c),
         {:ok, d} <- parse_crop_coordinate(d) do
      {rest, %ThumborPath{acc | crop: {{a, b}, {c, d}}}}
    else
      _ -> {[maybe_crop | rest], acc}
    end
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#fit-in
  defp parse_fit(["adaptive-full-fit-in" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | fit: {:fit, [:adaptive, :full]}}}
  end

  defp parse_fit(["adaptive-fit-in" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | fit: {:fit, [:adaptive]}}}
  end

  defp parse_fit(["full-fit-in" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | fit: {:fit, [:full]}}}
  end

  defp parse_fit(["fit-in" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | fit: {:fit, []}}}
  end

  defp parse_fit(rest, %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | fit: :default}}
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#image-size
  defp parse_size([maybe_size | rest], %ThumborPath{} = acc) do
    with map when is_map(map) <-
           Regex.named_captures(~r/^(?<a>orig|-?\d*)x(?<b>orig|-?\d*)$/, maybe_size,
             capture: :all_but_first
           ),
         {:ok, a} <- parse_size_coordinate(map["a"] || ""),
         {:ok, b} <- parse_size_coordinate(map["b"] || "") do
      {rest, %ThumborPath{acc | size: {a, b}}}
    else
      _ -> {[maybe_size | rest], %ThumborPath{acc | size: nil}}
    end
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#horizontal-align
  defp parse_horizontal_align(["left" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | horizontal_align: :left}}
  end

  defp parse_horizontal_align(["center" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | horizontal_align: :center}}
  end

  defp parse_horizontal_align(["right" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | horizontal_align: :right}}
  end

  defp parse_horizontal_align(rest, %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | horizontal_align: nil}}
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#vertical-align
  defp parse_vertical_align(["top" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | vertical_align: :top}}
  end

  defp parse_vertical_align(["middle" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | vertical_align: :middle}}
  end

  defp parse_vertical_align(["bottom" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | vertical_align: :bottom}}
  end

  defp parse_vertical_align(rest, %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | vertical_align: nil}}
  end

  # https://thumbor.readthedocs.io/en/latest/detection_algorithms.html
  defp parse_smart(["smart" | rest], %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | smart: true}}
  end

  defp parse_smart(rest, %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | smart: false}}
  end

  # https://thumbor.readthedocs.io/en/latest/filters.html
  defp parse_filters(["filters" <> filters | rest], %ThumborPath{} = acc) do
    matches = Regex.scan(~r/:([a-z_]+\(.*?\))/, filters, capture: :all_but_first)
    {rest, %ThumborPath{acc | filters: Enum.map(matches, fn [x] -> x end)}}
  end

  defp parse_filters(rest, %ThumborPath{} = acc) do
    {rest, %ThumborPath{acc | filters: []}}
  end

  # https://thumbor.readthedocs.io/en/latest/usage.html#image-uri
  defp parse_source(rest, %ThumborPath{} = acc) do
    {[], %ThumborPath{acc | source: Path.join(rest) |> URI.decode()}}
  end

  defp parse_crop_coordinate(str) do
    case Integer.parse(str, 10) do
      {int, ""} when int >= 0 -> {:ok, int}
      _ -> :error
    end
  end

  defp parse_size_coordinate(""), do: {:ok, nil}
  defp parse_size_coordinate("orig"), do: {:ok, :orig}

  defp parse_size_coordinate(str) do
    case Integer.parse(str, 10) do
      {int, ""} -> {:ok, int}
      _ -> :error
    end
  end
end
