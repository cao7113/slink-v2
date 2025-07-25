#!/usr/bin/env mix run
alias Slink.Accounts
alias Slink.Accounts.User

if Mix.env() != :dev, do: raise("Not dev env, now: #{Mix.env()} env")

email = "a1@b.c"
user = Accounts.get_user_by_email(email)

user =
  if !user do
    {:ok, user} = Accounts.register_user(%{email: email})
    user
  else
    user
  end

pswd = "123456" |> String.duplicate(2)
{:ok, {new_user, _}} = Accounts.update_user_password(user, %{password: pswd})
true = User.valid_password?(new_user, pswd)

IO.puts("user #{email} with id=#{user.id}")
api_token = Accounts.create_user_api_token(user)
IO.puts("Create api-token: #{api_token}")
