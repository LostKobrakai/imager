import Config

if config_env() in [:dev, :test] do
  config :imager, thumbor_endpoint: System.get_env("THUMBOR_ENDPOINT", "http://localhost:8888/")
end
