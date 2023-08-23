defmodule Imager.Generators do
  use ExUnitProperties
  alias Imager.ThumborPath

  def gen_valid_uri_struct(secret) do
    gen all(uri <- gen_uri_struct()) do
      case secret do
        nil ->
          %{uri | hmac: :unsafe}

        _ ->
          hmac =
            uri
            |> ThumborPath.Encoder.build_image_path()
            |> ThumborPath.signature(secret)

          %{uri | hmac: hmac}
      end
    end
  end

  def gen_uri_struct do
    gen all(
          hmac <- hmac_or_unsafe(),
          meta <- maybe_meta(),
          trim <- maybe_trim(),
          crop <- maybe_crop(),
          fit <- fit(),
          size <- maybe_size(),
          horizontal_align <- maybe_horizontal_align(),
          vertical_align <- maybe_vertical_align(),
          smart <- maybe_smart()
        ) do
      %ThumborPath{
        hmac: hmac,
        meta: meta,
        trim: trim,
        crop: crop,
        fit: fit,
        size: size,
        horizontal_align: horizontal_align,
        vertical_align: vertical_align,
        smart: smart,
        filters: [],
        source: "some/path.jpg"
      }
    end
  end

  def maybe_secret do
    frequency([
      {3, secret()},
      {1, constant(nil)}
    ])
  end

  def secret do
    binary()
  end

  def hmac_or_unsafe do
    frequency([
      {3, hmac()},
      {1, constant(:unsafe)}
    ])
  end

  def hmac do
    gen all(hmac <- bitstring(length: 160)) do
      Base.url_encode64(hmac)
    end
  end

  def maybe_meta do
    boolean()
  end

  def maybe_trim do
    frequency([
      {3, trim()},
      {1, constant(nil)}
    ])
  end

  def trim do
    member_of([:top_left, :bottom_right])
  end

  def maybe_crop do
    frequency([
      {3, crop()},
      {1, constant(nil)}
    ])
  end

  def crop do
    gen all(
          a <- integer(0..10000),
          b <- integer(0..10000),
          c <- integer(a..10000),
          d <- integer(b..10000)
        ) do
      {{a, b}, {c, d}}
    end
  end

  def fit do
    member_of([
      :default,
      {:fit, []},
      {:fit, [:full]},
      {:fit, [:adaptive]},
      {:fit, [:adaptive, :full]}
    ])
  end

  def maybe_size do
    frequency([
      {3, size()},
      {1, constant(nil)}
    ])
  end

  def size do
    gen all(
          a <- single_size(),
          b <- single_size()
        ) do
      {a, b}
    end
  end

  def single_size do
    frequency([
      {3, integer(0..10000)},
      {1, constant(:orig)},
      {1, constant(nil)}
    ])
  end

  def maybe_horizontal_align do
    frequency([
      {3, horizontal_align()},
      {1, constant(nil)}
    ])
  end

  def horizontal_align do
    member_of([:left, :center, :right])
  end

  def maybe_vertical_align do
    frequency([
      {3, vertical_align()},
      {1, constant(nil)}
    ])
  end

  def vertical_align do
    member_of([:top, :middle, :bottom])
  end

  def maybe_smart do
    boolean()
  end
end
