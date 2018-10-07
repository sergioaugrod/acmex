defmodule Acmex.ConfigTest do
  use ExUnit.Case, async: true

  alias Acmex.Config

  describe "Config.directory_url/0" do
    test "returns configured directory_url" do
      assert Config.directory_url == Application.get_env(:acmex, :directory_url)
    end
  end
end
