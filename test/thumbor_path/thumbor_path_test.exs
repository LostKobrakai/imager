defmodule Imager.ThumborPathTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Imager.ThumborPath

  doctest ThumborPath

  property "any encoded path can be decoded" do
    check all(uri <- Imager.Generators.gen_uri_struct()) do
      path = ThumborPath.encode(uri)
      parsed = ThumborPath.parse(path)

      assert uri == parsed
    end
  end

  property "valid uris stay valid" do
    check all(
            secret <- Imager.Generators.maybe_secret(),
            uri <- Imager.Generators.gen_valid_uri_struct(secret)
          ) do
      path = ThumborPath.encode(uri)
      parsed = ThumborPath.parse(path)

      assert ThumborPath.valid?(path, secret)
      assert ThumborPath.valid?(parsed, secret)
    end
  end

  describe "parse/1" do
    test "success" do
      assert ThumborPath.parse("/unsafe/300x301/smart/path/to/image.jpg") ==
               %ThumborPath{
                 crop: nil,
                 fit: :default,
                 hmac: :unsafe,
                 meta: false,
                 trim: nil,
                 size: {300, 301},
                 horizontal_align: nil,
                 vertical_align: nil,
                 smart: true,
                 filters: [],
                 source: "path/to/image.jpg"
               }

      assert ThumborPath.parse("/unsafe/10x10:290x290/300x301/smart/path/to/image.jpg") ==
               %ThumborPath{
                 crop: {{10, 10}, {290, 290}},
                 fit: :default,
                 hmac: :unsafe,
                 meta: false,
                 trim: nil,
                 size: {300, 301},
                 horizontal_align: nil,
                 vertical_align: nil,
                 smart: true,
                 filters: [],
                 source: "path/to/image.jpg"
               }

      assert ThumborPath.parse("/1234567890123456789012345678/300x200/smart/path/to/image.jpg") ==
               %ThumborPath{
                 crop: nil,
                 fit: :default,
                 hmac: "1234567890123456789012345678",
                 meta: false,
                 trim: nil,
                 size: {300, 200},
                 horizontal_align: nil,
                 vertical_align: nil,
                 smart: true,
                 filters: [],
                 source: "path/to/image.jpg"
               }

      assert ThumborPath.parse("/300x200/smart/path/to/image.jpg") ==
               %ThumborPath{
                 crop: nil,
                 fit: :default,
                 hmac: nil,
                 meta: false,
                 trim: nil,
                 size: {300, 200},
                 horizontal_align: nil,
                 vertical_align: nil,
                 smart: true,
                 filters: [],
                 source: "path/to/image.jpg"
               }

      assert ThumborPath.parse("/unsafe/-300x-200/left/top/smart/path/to/my/nice/image.jpg") ==
               %ThumborPath{
                 crop: nil,
                 fit: :default,
                 hmac: :unsafe,
                 meta: false,
                 trim: nil,
                 size: {-300, -200},
                 horizontal_align: :left,
                 vertical_align: :top,
                 smart: true,
                 filters: [],
                 source: "path/to/my/nice/image.jpg"
               }

      assert ThumborPath.parse("/unsafe/meta/-300x-200/left/top/path/to/my/nice/image.jpg") ==
               %ThumborPath{
                 crop: nil,
                 fit: :default,
                 hmac: :unsafe,
                 meta: true,
                 trim: nil,
                 size: {-300, -200},
                 horizontal_align: :left,
                 vertical_align: :top,
                 smart: false,
                 filters: [],
                 source: "path/to/my/nice/image.jpg"
               }
    end
  end
end
