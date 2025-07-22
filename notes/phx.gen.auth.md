# Auth

```
$ mix phx.gen.auth Accounts User users
An authentication system can be created in two different ways:
- Using Phoenix.LiveView (default)
- Using Phoenix.Controller only
Do you want to create a LiveView based authentication system? [Yn] y
* creating priv/repo/migrations/20250722063518_create_users_auth_tables.exs
* creating lib/slink/accounts/user_notifier.ex
* creating lib/slink/accounts/user.ex
* creating lib/slink/accounts/user_token.ex
* creating lib/slink_web/user_auth.ex
* creating test/slink_web/user_auth_test.exs
* creating lib/slink_web/controllers/user_session_controller.ex
* creating test/slink_web/controllers/user_session_controller_test.exs
* creating lib/slink/accounts/scope.ex
* creating lib/slink_web/live/user_live/registration.ex
* creating test/slink_web/live/user_live/registration_test.exs
* creating lib/slink_web/live/user_live/login.ex
* creating test/slink_web/live/user_live/login_test.exs
* creating lib/slink_web/live/user_live/settings.ex
* creating test/slink_web/live/user_live/settings_test.exs
* creating lib/slink_web/live/user_live/confirmation.ex
* creating test/slink_web/live/user_live/confirmation_test.exs
* creating lib/slink/accounts.ex
* injecting lib/slink/accounts.ex
* creating test/slink/accounts_test.exs
* injecting test/slink/accounts_test.exs
* creating test/support/fixtures/accounts_fixtures.ex
* injecting test/support/fixtures/accounts_fixtures.ex
* injecting test/support/conn_case.ex
* injecting config/test.exs
* injecting config/config.exs
* injecting mix.exs
* injecting lib/slink_web/router.ex
* injecting lib/slink_web/router.ex - imports
* injecting lib/slink_web/router.ex - plug
* injecting lib/slink_web/components/layouts/root.html.heex

Please re-fetch your dependencies with the following command:

    $ mix deps.get

Remember to update your repository by running migrations:

    $ mix ecto.migrate

Once you are ready, visit "/users/register"
to create your account and then access "/dev/mailbox" to
see the account confirmation email.
```
