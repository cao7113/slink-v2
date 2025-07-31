defmodule Slink.Accounts.UserToken do
  use Endon
  use Ecto.Schema
  import Ecto.Query
  alias Slink.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the magic link token expiry short,
  # since someone with access to the email may take over the account.
  @magic_link_validity_in_minutes 15
  @change_email_validity_in_days 7
  @session_validity_in_days 14
  @api_token_validity_in_days 365

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    field :authenticated_at, :utc_datetime
    belongs_to :user, Slink.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    dt = user.authenticated_at || DateTime.utc_now(:second)
    {token, %UserToken{token: token, context: "session", user_id: user.id, authenticated_at: dt}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any, along with the token's creation time.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: {%{user | authenticated_at: token.authenticated_at}, token.inserted_at}

    {:ok, query}
  end

  @doc """
  Checks if the API token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within 365 days.
  """
  def verify_api_token_query(token) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in by_token_and_context_query(hashed_token, "api-token"),
            join: user in assoc(token, :user),
            where:
              token.inserted_at > ago(^@api_token_validity_in_days, "day") and
                token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  @doc """
  Build token with pre-known secret string. Mainly used for testing and dev purposes.
  """
  def build_email_token_with_secret!(user, context, secret_bytes)
      when is_binary(secret_bytes) and byte_size(secret_bytes) == @rand_size do
    build_hashed_token(user, context, user.email, secret_bytes: secret_bytes)
  end

  defp build_hashed_token(user, context, sent_to, opts \\ []) do
    token =
      Keyword.get_lazy(opts, :secret_bytes, fn ->
        gen_secret_token!(@rand_size)
      end)

    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  def secret_rand_size, do: @rand_size

  @doc """
  Generate token secret bytes. like:

  <<237, 68, 58, 153, 183, 212, 122, 212, 228, 2, 69, 148, 189, 164, 61, 250, 125,
    161, 16, 198, 98, 238, 48, 135, 69, 146, 65, 9, 60, 128, 132, 67>>
  """
  def gen_secret_token!(size \\ @rand_size) do
    :crypto.strong_rand_bytes(size)
  end

  @doc """
  Encode secret bytes into human string

    iex(53)> <<237, 68, 58, 153, 183, 212, 122, 212, 228, 2, 69, 148, 189, 164, 61, 250, 125, 161, 16, 198, 98, 238, 48, 135, 69, 146, 65, 9, 60, 128, 132, 67>>
            |> Ut.encode_secret_token!
    "7UQ6mbfUetTkAkWUvaQ9-n2hEMZi7jCHRZJBCTyAhEM"
  """
  def encode_secret_token!(secret_bytes \\ gen_secret_token!()) do
    Base.url_encode64(secret_bytes, padding: false)
  end

  @doc """
  Decode human string into secret bytes

    iex(56)> "7UQ6mbfUetTkAkWUvaQ9-n2hEMZi7jCHRZJBCTyAhEM" |> Ut.decode_secret_token!
    <<237, 68, 58, 153, 183, 212, 122, 212, 228, 2, 69, 148, 189, 164, 61, 250, 125,
      161, 16, 198, 98, 238, 48, 135, 69, 146, 65, 9, 60, 128, 132, 67>>
  """
  def decode_secret_token!(encoded_token \\ encode_secret_token!()) do
    Base.url_decode64!(encoded_token, padding: false)
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  If found, the query returns a tuple of the form `{user, token}`.

  The given token is valid if it matches its hashed counterpart in the
  database. This function also checks if the token is being used within
  15 minutes. The context of a magic link token is always "login".
  """
  def verify_magic_link_token_query(token) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in by_token_and_context_query(hashed_token, "login"),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^@magic_link_validity_in_minutes, "minute"),
            where: token.sent_to == user.email,
            select: {user, token}

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user_token found by the token, if any.

  This is used to validate requests to change the user
  email.
  The given token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after @change_email_validity_in_days).
  The context must always start with "change:".
  """
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  defp by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end
end
