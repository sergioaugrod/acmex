defmodule Acmex.Config do
  @moduledoc false

  def directory_url, do: Application.get_env(:acmex, :directory_url)
end
