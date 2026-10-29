# evanslack.dev

My personal website

## Development

Requires [Hugo](https://gohugo.io/installation/) >= 0.158 (production is pinned to 0.169.0). The PaperMod theme is a git submodule:

```
git clone --recurse-submodules https://github.com/evanofslack/evanslack.dev.git
# or, in an existing clone
git submodule update --init
```

`hugo server` will spin up the static site server at <http://localhost:1313> (add `-D` to include drafts).

`hugo --minify` builds the production site into `public/`.

To update the theme:

```
git submodule update --remote themes/PaperMod
```

## Deployment

Deployed on cloudflare with pages

```
Build command:hugo --minify
Build output:public
Root directory:
Build comments:Enabled
Build system:Version 3
Environment variables:HUGO_VERSION=0.169.0
```

When bumping Hugo locally, update `HUGO_VERSION` in the Cloudflare Pages settings (Production and Preview) to match.
