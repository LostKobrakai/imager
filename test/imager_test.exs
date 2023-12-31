defmodule ImagerTest do
  use ExUnit.Case, async: true
  import Imager.Helper
  alias Imager.ThumborPath

  doctest Imager

  @moduletag :tmp_dir

  describe "stream response" do
    test "default size", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "girl_behind_scarf.jpg",
        size: {300, 400}
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end
  end

  describe "secret handling" do
    test "success if secret is valid" do
      thumbor_path =
        %ThumborPath{
          source: "girl_behind_scarf.jpg",
          size: {300, 400}
        }
        |> full_source(:imager)

      url =
        URI.parse("http://localhost:4001")
        |> Map.put(:path, ThumborPath.build(thumbor_path, "secret"))
        |> Map.put(:query, Plug.Conn.Query.encode(%{secret: "secret"}))
        |> URI.to_string()

      assert {:ok, %{status: 200}} = Finch.request(Finch.build(:get, url), Imager.Finch)
    end

    test "success if no secret is expected, but provided" do
      thumbor_path =
        %ThumborPath{
          source: "girl_behind_scarf.jpg",
          size: {300, 400}
        }
        |> full_source(:imager)

      url =
        URI.parse("http://localhost:4001")
        |> Map.put(:path, ThumborPath.build(thumbor_path, "secret"))
        |> Map.put(:query, Plug.Conn.Query.encode(%{secret: nil}))
        |> URI.to_string()

      assert {:ok, %{status: 200}} = Finch.request(Finch.build(:get, url), Imager.Finch)
    end

    test "not accepted if secret is expected but missing" do
      thumbor_path =
        %ThumborPath{
          source: "girl_behind_scarf.jpg",
          size: {300, 400}
        }
        |> full_source(:imager)

      url =
        URI.parse("http://localhost:4001")
        |> Map.put(:path, ThumborPath.build(thumbor_path, nil))
        |> Map.put(:query, Plug.Conn.Query.encode(%{secret: "secret"}))
        |> URI.to_string()

      assert {:ok, %{status: 403}} = Finch.request(Finch.build(:get, url), Imager.Finch)
    end

    test "not accepted if secret is incorrect" do
      thumbor_path =
        %ThumborPath{
          source: "girl_behind_scarf.jpg",
          size: {300, 400}
        }
        |> full_source(:imager)

      url =
        URI.parse("http://localhost:4001")
        |> Map.put(:path, ThumborPath.build(thumbor_path, "othersecret"))
        |> Map.put(:query, Plug.Conn.Query.encode(%{secret: "secret"}))
        |> URI.to_string()

      assert {:ok, %{status: 403}} = Finch.request(Finch.build(:get, url), Imager.Finch)
    end
  end

  describe "filetype png" do
    test "default size", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "signee.png",
        size: {50, 50}
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end
  end

  describe "size setting" do
    test "default size", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "girl_behind_scarf.jpg",
        size: {300, 400}
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - vertical align top", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "girl_behind_scarf.jpg",
        size: {300, 300},
        vertical_align: :top
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - vertical align middle", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "girl_behind_scarf.jpg",
        size: {300, 300},
        vertical_align: :middle
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - vertical align bottom", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "girl_behind_scarf.jpg",
        size: {300, 300},
        vertical_align: :bottom
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - horizontal align left", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "pizza.jpg",
        size: {300, 300},
        horizontal_align: :left
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - horizontal align center", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "pizza.jpg",
        size: {300, 300},
        horizontal_align: :center
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - horizontal align right", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "pizza.jpg",
        size: {300, 300},
        horizontal_align: :right
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end
  end

  test "crop", %{tmp_dir: tmp_dir} do
    thumbor_path = %ThumborPath{
      source: "girl_behind_scarf.jpg",
      crop: {{50, 100}, {650, 750}}
    }

    paths = paths(tmp_dir, thumbor_path.source)

    assert {:ok, thumbor_file} =
             thumbor_path
             |> full_source(:thumbor)
             |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

    assert {:ok, imager_file} =
             thumbor_path
             |> full_source(:imager)
             |> fetch(paths.imager,
               endpoint: "http://localhost:4001",
               force: true
             )

    assert_similar thumbor_file, imager_file, 0.1, paths.compare
  end

  describe "trim" do
    test "trim", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "trima.jpg",
        trim: :top_left
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      # Trim is not matching up well
      assert_similar thumbor_file, imager_file, 0.25, paths.compare
    end

    test "order of operations", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "trima.jpg",
        trim: :top_left,
        crop: {{10, 10}, {50, 50}}
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               thumbor_path
               |> full_source(:thumbor)
               |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               thumbor_path
               |> full_source(:imager)
               |> fetch(paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      # Trim is not matching up well
      assert_similar thumbor_file, imager_file, 0.25, paths.compare
    end
  end

  test "crop and size", %{tmp_dir: tmp_dir} do
    thumbor_path = %ThumborPath{
      source: "girl_behind_scarf.jpg",
      crop: {{50, 100}, {650, 750}},
      size: {300, 300}
    }

    paths = paths(tmp_dir, thumbor_path.source)

    assert {:ok, thumbor_file} =
             thumbor_path
             |> full_source(:thumbor)
             |> fetch(paths.thumbor, endpoint: thumbor_endpoint())

    assert {:ok, imager_file} =
             thumbor_path
             |> full_source(:imager)
             |> fetch(paths.imager,
               endpoint: "http://localhost:4001",
               force: true
             )

    assert_similar thumbor_file, imager_file, 0.1, paths.compare
  end
end
