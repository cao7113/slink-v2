#!/usr/bin/env mix run
alias Slink.Accounts
# alias Slink.Accounts.User

email = "a@b.c"
user = Accounts.get_user_by_email(email)

user =
  if !user do
    {:ok, user} = Accounts.register_user(%{email: email})
    user
  else
    user
  end

IO.puts("user #{email} with id=#{user.id}")
api_token = Accounts.create_user_api_token(user)
IO.puts("Create api-token: #{api_token}")
