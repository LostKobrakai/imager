defmodule Imager.FinchAdapter do
  @behaviour Imager.HTTP.Adapter

  def get(url) do
    case Finch.request(Finch.build(:get, url), Imager.Finch) do
      {:ok, %{status: 200} = response} -> {:ok, response.headers, response.body}
      {:ok, response} -> {:error, response.status, response.body}
      {:error, exception} -> {:error, 500, Exception.message(exception)}
    end
  end
end
