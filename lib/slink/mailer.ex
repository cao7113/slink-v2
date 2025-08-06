defmodule Slink.Mailer do
  use Swoosh.Mailer, otp_app: :slink

  require Logger

  def info, do: Application.get_env(:slink, __MODULE__)

  def set(tp \\ :local) do
    Logger.info("Setting mailer-type to #{inspect(tp)}")

    case tp do
      :local ->
        put_mailer_env(adapter: Swoosh.Adapters.Local)

      :logger ->
        put_mailer_env(adapter: Swoosh.Adapters.Logger)

      :test ->
        put_mailer_env(adapter: Swoosh.Adapters.Test)

      :smtp_gmail ->
        put_mailer_env(smtp_gmail_opts())

      # :smtp_hotmail ->
      #   put_mailer_env(
      #     adapter: Swoosh.Adapters.Smtp,
      #     relay: "smtp.office365.com",
      #     username: System.fetch_env!("HOTMAIL_USERNAME"),
      #     # use app password
      #     password: System.fetch_env!("HOTMAIL_PASSWORD"),
      #     port: 587,
      #     ssl: false,
      #     tls: :if_available,
      #     auth: :always,
      #     retries: 1
      #   )

      other ->
        raise "Unknown mailer type: #{inspect(other)}"
    end

    info()
  end

  def smtp_gmail_opts do
    [
      adapter: Swoosh.Adapters.SMTP,
      relay: "smtp.gmail.com",
      port: 587,
      username: System.fetch_env!("GMAIL_USERNAME"),
      # use app password
      password: System.fetch_env!("GMAIL_PASSWORD"),
      ssl: false,
      tls: :always,
      tls_options: [verify: :verify_none],
      retries: 3,
      no_mx_lookups: false,
      auth: :always
    ]
  end

  def gmail_username, do: System.get_env("GMAIL_USERNAME")

  def put_mailer_env(opts \\ []) do
    Application.put_env(:slink, Slink.Mailer, opts)
  end
end
