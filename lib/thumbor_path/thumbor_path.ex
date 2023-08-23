defmodule Imager.ThumborPath do
  #   @external_resource "README.md"
  #   @moduledoc "README.md"
  #              |> File.read!()
  #              |> String.split("<!-- MDOC !-->")
  #              |> Enum.fetch!(1)

  alias Imager.ThumborPath.Encoder
  alias Imager.ThumborPath.Parser

  defstruct hmac: :unsafe,
            meta: false,
            trim: nil,
            crop: nil,
            fit: :default,
            size: nil,
            horizontal_align: nil,
            vertical_align: nil,
            smart: false,
            filters: [],
            source: nil

  @type t :: %__MODULE__{
          hmac: :unsafe | hmac,
          meta: boolean,
          trim: nil | :top_left | :bottom_right,
          crop: nil | {crop_coordinates, crop_coordinates},
          fit: :default | {:fit, [:adaptive | :full]},
          size: nil | {size_coordinate, size_coordinate},
          horizontal_align: nil | :left | :center | :right,
          vertical_align: nil | :top | :middle | :left,
          smart: boolean(),
          filters: [binary()],
          source: Path.t()
        }

  @type hmac :: <<_::176>>
  @type crop_coordinates :: {non_neg_integer(), non_neg_integer()}
  @type size_coordinate :: integer() | nil | :orig
  @type secret :: nil | binary()

  @doc """
  Builds a path from a `%ThumborPath{}` struct

  ## Examples

      iex> path =
      ...>   %ThumborPath{
      ...>     hmac: :unsafe,
      ...>     crop: {{10, 10}, {490, 490}},
      ...>     filters: ["quality(40)"],
      ...>     fit: {:fit, [:adaptive, :full]},
      ...>     horizontal_align: :left,
      ...>     meta: true,
      ...>     size: {-100, :orig},
      ...>     smart: true,
      ...>     source: "some/path.jpg",
      ...>     trim: :bottom_right,
      ...>     vertical_align: :top
      ...>   }
      iex> ThumborPath.build(path, "abc")
      "/ZIIZAgsPURj4atIJCmNEPPCn2lU=/meta/trim:bottom-right/10x10:490x490/adaptive-full-fit-in/-100xorig/left/top/smart/filters:quality(40)/some%2Fpath.jpg"

      iex> path =
      ...>   %ThumborPath{
      ...>     hmac: :unsafe,
      ...>     meta: false,
      ...>     trim: nil,
      ...>     crop: nil,
      ...>     fit: :default,
      ...>     size: nil,
      ...>     horizontal_align: nil,
      ...>     vertical_align: nil,
      ...>     smart: false,
      ...>     filters: [],
      ...>     source: "some/path.jpg"
      ...>   }
      iex> ThumborPath.build(path, nil)
      "/unsafe/some%2Fpath.jpg"
  """
  @spec build(t, secret) :: Path.t()
  def build(%__MODULE__{} = uri, secret) do
    "/" <> Encoder.build(uri, secret)
  end

  @doc """
  Encodes a `%ThumborPath{}`

  ## Examples

      iex> path =
      ...>   %ThumborPath{
      ...>     crop: {{10, 10}, {490, 490}},
      ...>     filters: ["quality(40)"],
      ...>     fit: {:fit, [:adaptive, :full]},
      ...>     hmac: "ZIIZAgsPURj4atIJCmNEPPCn2lU=",
      ...>     horizontal_align: :left,
      ...>     meta: true,
      ...>     size: {-100, :orig},
      ...>     smart: true,
      ...>     source: "some/path.jpg",
      ...>     trim: :bottom_right,
      ...>     vertical_align: :top
      ...>   }
      iex> ThumborPath.encode(path)
      "/ZIIZAgsPURj4atIJCmNEPPCn2lU=/meta/trim:bottom-right/10x10:490x490/adaptive-full-fit-in/-100xorig/left/top/smart/filters:quality(40)/some%2Fpath.jpg"

      iex> path =
      ...>   %ThumborPath{
      ...>     hmac: :unsafe,
      ...>     meta: false,
      ...>     trim: nil,
      ...>     crop: nil,
      ...>     fit: :default,
      ...>     size: nil,
      ...>     horizontal_align: nil,
      ...>     vertical_align: nil,
      ...>     smart: false,
      ...>     filters: [],
      ...>     source: "some/path.jpg"
      ...>   }
      iex> ThumborPath.encode(path)
      "/unsafe/some%2Fpath.jpg"
  """
  @spec encode(t) :: Path.t()
  def encode(%__MODULE__{} = uri) do
    "/" <> Encoder.encode(uri)
  end

  @doc """
  Parses a thumbor path.

  ## Examples

      iex> ThumborPath.parse("/ZIIZAgsPURj4atIJCmNEPPCn2lU=/meta/trim:bottom-right/10x10:490x490/adaptive-full-fit-in/-100xorig/left/top/smart/filters:quality(40)/some/path.jpg")
      %ThumborPath{
        crop: {{10, 10}, {490, 490}},
        filters: ["quality(40)"],
        fit: {:fit, [:adaptive, :full]},
        hmac: "ZIIZAgsPURj4atIJCmNEPPCn2lU=",
        horizontal_align: :left,
        meta: true,
        size: {-100, :orig},
        smart: true,
        source: "some/path.jpg",
        trim: :bottom_right,
        vertical_align: :top
      }

      iex> ThumborPath.parse("/unsafe/some/path.jpg")
      %ThumborPath{
        hmac: :unsafe,
        meta: false,
        trim: nil,
        crop: nil,
        fit: :default,
        size: nil,
        horizontal_align: nil,
        vertical_align: nil,
        smart: false,
        filters: [],
        source: "some/path.jpg"
      }

  """
  @spec parse(Path.t()) :: t()
  def parse(path) do
    Parser.parse(path)
  end

  @doc """
  Check if the path or `%ThumborPath{}` is valid for a secret.

  ## Examples

      iex> ThumborPath.valid?("/unsafe/some/path.jpg", nil)
      true

      iex> ThumborPath.valid?("/Il8BQnbpFAXckv_jN8JcbbpSLoo=/some/path.jpg", nil)
      true

      iex> ThumborPath.valid?("/Il8BQnbpFAXckv_jN8JcbbpSLoo=/some/path.jpg", "abc")
      true

      iex> ThumborPath.valid?("/unsafe/some/path.jpg", "abc")
      false

  """
  @spec valid?(t | Path.t(), secret) :: boolean()
  def valid?(%__MODULE__{}, nil), do: true
  def valid?(%__MODULE__{hmac: :unsafe}, _), do: false

  def valid?(%__MODULE__{} = uri, secret) do
    [hmac | _] = Encoder.build(uri, secret) |> Path.split()
    hmac == uri.hmac
  end

  def valid?(path, nil) when is_binary(path), do: true

  def valid?(path, secret) when is_binary(path) do
    [hmac_given | rest] = path |> Path.relative() |> Path.split()

    if hmac_given == "unsafe" do
      false
    else
      hmac_computed = signature(Path.join(rest), secret)
      hmac_given == hmac_computed
    end
  end

  @doc """
  Build the HMAC signature for the given path and secret.

  ## Examples

      iex> ThumborPath.signature("/some/path.jpg", nil)
      :unsafe

      iex> ThumborPath.signature("/some/path.jpg", "abc")
      "Il8BQnbpFAXckv_jN8JcbbpSLoo="

      iex> ThumborPath.signature("some/path.jpg", "abc")
      "Il8BQnbpFAXckv_jN8JcbbpSLoo="

  """
  @spec signature(Path.t(), secret) :: :unsafe | String.t()
  def signature(_msg, nil), do: :unsafe

  def signature(msg, secret) do
    :crypto.mac(:hmac, :sha, secret, Path.relative(msg)) |> Base.url_encode64()
  end
end
