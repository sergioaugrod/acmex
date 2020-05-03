defmodule Acmex.Config do
  @moduledoc """
  This module is responsible for getting the application configuration.
  """

  @doc """
  Returns the directory URL from the application configuration.
  """
  @spec directory_url :: String.t() | nil
  def directory_url, do: Application.get_env(:acmex, :directory_url)
end
