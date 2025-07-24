# Links design and pages

## Models

links table
- title
- url
- user_id: as contributor
-------
- tags
- owner_type: nil(public), user, org
- owner_id

unique with {url, owner_type, owner_id}???

my_links table
- title
- link_id
- user_id
- note
- favor_at

## Public links show

list links with possible scope

build to my-link actions:
- favor
- add note
- read later?

```
$ mix phx.gen.live Links Link links --no-context title url user_id:integer
* creating lib/slink_web/live/link_live/show.ex
* creating lib/slink_web/live/link_live/index.ex
* creating lib/slink_web/live/link_live/form.ex
* creating test/slink_web/live/link_live_test.exs

Add the live routes to your browser scope in lib/slink_web/router.ex:

    live "/links", LinkLive.Index, :index
    live "/links/new", LinkLive.Form, :new
    live "/links/:id", LinkLive.Show, :show
    live "/links/:id/edit", LinkLive.Form, :edit

Ensure the routes are defined in a block that sets the `:current_scope` assign.
```

## My links page for normal user

actions:
- CRUD
- edit note

## Links in Admin

- admin
