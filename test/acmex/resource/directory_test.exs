defmodule Acmex.Resource.DirectoryTest do
  use ExUnit.Case, async: true

  alias Acmex.Config
  alias Acmex.Resource.Directory

  describe "new/1" do
    test "returns a directory struct" do
      assert {:ok, %Directory{}} = Directory.new(Config.directory_url())
    end

    test "when directory URL is invalid, returns an error" do
      assert {:error, %{status_code: 404}} = Directory.new("#{Config.directory_url()}/invalid")
    end
  end
end
