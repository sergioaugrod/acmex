defmodule Acmex.Resource.DirectoryTest do
  use ExUnit.Case, async: true

  alias Acmex.Config
  alias Acmex.Resource.Directory

  describe "Directory.new/1" do
    test "returns directory struct" do
      {:ok, directory} = Directory.new(Config.directory_url())

      assert directory.__struct__ == Directory
      assert directory.new_account
    end

    test "returns error" do
      {:error, reason} = Directory.new("#{Config.directory_url()}/invalid")

      assert reason.status_code == 404
    end
  end
end
