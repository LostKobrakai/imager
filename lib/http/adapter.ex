defmodule Imager.HTTP.Adapter do
  @type status() :: 100..599
  @type headers() :: [{String.t(), String.t()}]
  @type body() :: binary()

  @callback get(url :: String.t()) ::
              {:ok, headers(), body()} | {:error, status(), body()}
end
