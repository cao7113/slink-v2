defmodule TestHelpers do
  alias Slink.Accounts
  alias Slink.Accounts.User, warn: false
  alias Slink.Accounts.UserToken
  alias Slink.AccountsFixtures

  @default_user_email "a1@b.c"
  @default_password "123456123456"
  @dev_api_token_prefix "dev_api_token---"

  def init_data(opts \\ []) do
    user = get_user(opts)
    scope = get_scope(user)
    rand_links(scope: scope)
  end

  def get_user(opts \\ []) do
    email = Keyword.get(opts, :email, @default_user_email)
    password = Keyword.get(opts, :password, @default_password)
    user = Accounts.get_user_by_email(email)

    if !user do
      # init user
      {:ok, user} = Accounts.register_user(%{email: email})
      # confirm user email by magic link
      magic_token = Accounts.get_login_magic_link_token(user)
      Accounts.login_user_by_magic_link(magic_token)
      # set default password
      {:ok, {new_user, _}} = Accounts.update_user_password(user, %{password: password})
      # true = User.valid_password?(new_user, password)
      # create init api-token
      ensure_dev_api_token!(new_user)
      new_user
    else
      user
    end
  end

  def get_scope(user \\ get_user()) do
    AccountsFixtures.user_scope_fixture(user)
  end

  ## API Token

  def ensure_dev_api_token!(user \\ get_user()) do
    encoded_token = fetch_api_token_by_env!()

    encoded_token
    |> Accounts.fetch_user_by_api_token()
    |> case do
      {:ok, got_user} ->
        if got_user.id == user.id do
          {:ok, :found, user |> Map.take([:id, :email])}
        else
          raise "Mismatch user id #{got_user.id} != #{user.id}"
        end

      :error ->
        secret = encoded_token |> UserToken.decode_secret_token!()
        Accounts.create_user_api_token_with_secret(user, secret)
        {:ok, :created_new_api_token}
    end
  end

  def fetch_api_token_by_env!(env_key \\ "DEV_API_TOKEN") do
    env_key |> System.fetch_env!()
  end

  @doc """
  Gen dev api-token

  iex(101)> Th.gen_dev_api_token |> Ut.encode_secret_token!
  "dev_test_only_api_tokenOhPpYlnumwjQ0kGgynLs"
  """
  def gen_dev_api_token! do
    prefix_bytes = UserToken.decode_secret_token!(@dev_api_token_prefix)
    rand_bytes = :crypto.strong_rand_bytes(UserToken.secret_rand_size() - byte_size(prefix_bytes))

    (prefix_bytes <> rand_bytes)
    |> UserToken.encode_secret_token!()
  end

  def rand_links(opts \\ []) do
    scope = Keyword.get(opts, :scope, get_scope())
    count = Keyword.get(opts, :count, 5)

    1..count
    |> Enum.map(fn _ ->
      Slink.LinksFixtures.link_fixture(scope)
    end)
  end
end
