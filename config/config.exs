use Mix.Config

config :swoosh, :sendgrid,
  base_url: "https://api.sendgrid.com/api/"

if Mix.env == :test do
  import_config "test.exs"
end

