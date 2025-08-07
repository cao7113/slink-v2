# Flyio Deployment

https://slink.fly.dev/api

## Deploy

`fly deploy`

## Init launch

Notes:
- auto-generated .github/workflows/fly-deploy.yml
- Setting FLY_API_TOKEN secret in GitHub repository settings
  - check by: https://github.com/cao7113/slink/settings/secrets/actions
- Set secrets on slink: SECRET_KEY_BASE
  - check by `fly config env`
- manual do set `fly secrets set DATABASE_URL="postgres://slink:xxxx@xxx-db.internal:5432/slink?sslmode=disable"` before manual run `fly deploy`
  - check by `fly secrets list`

```
fly launch --no-deploy --verbose

Compiling 9 files (.ex)
Generated slink app
Detected a Phoenix app
Creating app in /Users/rj/dev/elab/slink
We're about to launch your Phoenix app on Fly.io. Here's what you're getting:

Organization: 草色青青                              (fly launch defaults to the personal org)
Name:         slink                                  (derived from your directory name)
Region:       Tokyo, Japan                              (this is the fastest region for you)
App Machines: shared-cpu-1x, 1GB RAM                    (most apps need about 1GB of RAM)
Postgres:     shared-cpu-1x, 1GB RAM, 10GB disk, $38/mo (determined from app source)
Redis:        <none>                                    (not requested)
Tigris:       <none>                                    (not requested)

? Do you want to tweak these settings before proceeding? Yes
Opening https://fly.io/cli/launch/73653737657737336d3435766c61766c67367a78716b73636f6b6a716c693677 ...

Waiting for launch data... Done
Created app 'slink' in organization 'personal'
Admin URL: https://fly.io/apps/slink
Hostname: slink.fly.dev
Setting FLY_API_TOKEN secret in GitHub repository settings
Set secrets on slink: SECRET_KEY_BASE
Preparing system for Elixir builds
Installing application dependencies
Running Docker release generator
Wrote config file fly.toml
Validating /Users/rj/dev/elab/slink/fly.toml
✓ Configuration is valid

Your Phoenix app should be ready for deployment!.

If you need something else, post on our community forum at https://community.fly.io.

When you're ready to deploy, use 'fly deploy'.
```
