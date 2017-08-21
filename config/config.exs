# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :fire_auth,
  project_id: nil

if Mix.env() == :test do
  config :fire_auth,
    project_id: "nada-preview",
    current_time: 1503350512, # Time the test data was generated
    http_client: FireAuth.HttpClientMock # Mock the http client
end
