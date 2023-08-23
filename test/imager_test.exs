defmodule ImagerTest do
  use ExUnit.Case, async: true
  import Imager.Helper
  alias Imager.ThumborPath

  doctest Imager

  @moduletag :tmp_dir

  describe "stream response" do
    test "default size", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1030/20130322-_ben8030.jpg",
        size: {300, 400}
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end
  end

  describe "filetype png" do
    test "default size", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/templates/images/signee.png",
        size: {50, 50}
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end
  end

  describe "size setting" do
    test "default size", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1030/20130322-_ben8030.jpg",
        size: {300, 400}
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - vertical align top", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1030/20130322-_ben8030.jpg",
        size: {300, 300},
        vertical_align: :top
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - vertical align middle", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1030/20130322-_ben8030.jpg",
        size: {300, 300},
        vertical_align: :middle
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - vertical align bottom", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1030/20130322-_ben8030.jpg",
        size: {300, 300},
        vertical_align: :bottom
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - horizontal align left", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1056/katharina_5.jpg",
        size: {300, 300},
        horizontal_align: :left
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - horizontal align center", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1056/katharina_5.jpg",
        size: {300, 300},
        horizontal_align: :center
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end

    test "size - horizontal align right", %{tmp_dir: tmp_dir} do
      thumbor_path = %ThumborPath{
        source: "https://foto.space.kobrakai.de/site/assets/files/1056/katharina_5.jpg",
        size: {300, 300},
        horizontal_align: :right
      }

      paths = paths(tmp_dir, thumbor_path.source)

      assert {:ok, thumbor_file} =
               fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

      assert {:ok, imager_file} =
               fetch(thumbor_path, paths.imager,
                 endpoint: "http://localhost:4001",
                 force: true
               )

      assert_similar thumbor_file, imager_file, 0.1, paths.compare
    end
  end

  test "crop", %{tmp_dir: tmp_dir} do
    thumbor_path = %ThumborPath{
      source: "https://foto.space.kobrakai.de/site/assets/files/1030/20130322-_ben8030.jpg",
      crop: {{50, 100}, {650, 750}}
    }

    paths = paths(tmp_dir, thumbor_path.source)

    assert {:ok, thumbor_file} = fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

    assert {:ok, imager_file} =
             fetch(thumbor_path, paths.imager,
               endpoint: "http://localhost:4001",
               force: true
             )

    assert_similar thumbor_file, imager_file, 0.1, paths.compare
  end

  test "crop and size", %{tmp_dir: tmp_dir} do
    thumbor_path = %ThumborPath{
      source: "https://foto.space.kobrakai.de/site/assets/files/1030/20130322-_ben8030.jpg",
      crop: {{50, 100}, {650, 750}},
      size: {300, 300}
    }

    paths = paths(tmp_dir, thumbor_path.source)

    assert {:ok, thumbor_file} = fetch(thumbor_path, paths.thumbor, endpoint: thumbor_endpoint())

    assert {:ok, imager_file} =
             fetch(thumbor_path, paths.imager,
               endpoint: "http://localhost:4001",
               force: true
             )

    assert_similar thumbor_file, imager_file, 0.1, paths.compare
  end
end
