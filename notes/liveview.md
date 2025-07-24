# Phx liveview

- https://hexdocs.pm/phoenix/1.8.0-rc.4/live_view.html
- https://hexdocs.pm/phoenix/1.8.0-rc.4/Mix.Tasks.Phx.Gen.Live.html

LiveViews are processes that receive events, update their state, and render updates to a page as diffs.

## My Links

```
$ mix phx.gen.live Links Link links --web my --no-context title url user_id:integer
* creating lib/slink_web/live/my/link_live/show.ex
* creating lib/slink_web/live/my/link_live/index.ex
* creating lib/slink_web/live/my/link_live/form.ex
* creating test/slink_web/live/my/link_live_test.exs

Add the live routes to your My :browser scope in lib/slink_web/router.ex:

    scope "/my", SlinkWeb.My do
      pipe_through :browser
      ...

      live "/links", LinkLive.Index, :index
      live "/links/new", LinkLive.Form, :new
      live "/links/:id", LinkLive.Show, :show
      live "/links/:id/edit", LinkLive.Form, :edit
    end

Ensure the routes are defined in a block that sets the `:current_scope` assign.
```
