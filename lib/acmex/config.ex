defmodule Acmex.Config do
  @spec directory_url() :: String.t()
  def directory_url, do: Application.get_env(:acmex, :directory_url)
end
