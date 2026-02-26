# evanslack.dev

My personal website

## Development

`hugo server` will spin up the static site server at <http://localhost:1313>

## Deployment

Deployed on cloudflare with pages

```
Build command:hugo --minify -b $CF_PAGES_URL
Build output:public
Root directory:
Build comments:Enabled
```
