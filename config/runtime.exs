import Config

config :logger, level: :warn

if config_env() in [:dev, :test] do
  thumbor_host_type =
    case System.get_env("THUMBOR_HOST_TYPE") do
      "LOCAL" -> :local
      "DOCKER" -> :docker
      "CI" -> :ci
      _ -> :docker
    end

  config :imager,
    thumbor_endpoint: System.get_env("THUMBOR_ENDPOINT", "http://localhost:8888/"),
    thumbor_host_type: thumbor_host_type
end
