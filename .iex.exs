alias Slink, as: S
alias Slink.Repo
alias Slink.Mailer

# Accounts & User
alias Slink.Accounts
alias Slink.Accounts, as: A
alias Slink.Accounts.User
alias Slink.Accounts.User, as: U
alias Slink.Accounts.UserToken, as: Ut
alias Slink.Accounts.UserNotifier
alias Slink.Accounts.Scope
alias Slink.Accounts.Scope, as: Sc
u1 = User.find(1)

## Links
alias Slink.Links
alias Slink.Links.Link

# Web
alias SlinkWeb, as: Web
alias SlinkWeb.UserAuth

## API
# A.create_user_api_token(A.get_user!(1))

## Remote
alias Remote, as: R
alias EnvHelper, as: Env

## Testing
alias TestHelpers, as: Th
