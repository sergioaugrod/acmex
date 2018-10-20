defmodule Acmex.Config do
  def directory_url, do: Application.get_env(:acmex, :directory_url)
end
