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

## Gallery

Photos live in `content/gallery/`, with one folder per location. To add a location, create a folder and add it to `albums` in `content/gallery/index.md`, which sets the header text and order.

Photos within a location are shuffled on each visit or reload, so filenames don't set the display order. Going back to the page (for example after opening a photo) keeps the previous order. Row height, spacing and page width are set at the top of `assets/css/extended/gallery.css`.

### Adding photos

Prepare each photo before adding it:

1. Resize to 2000px on the long edge. Don't enlarge photos that are already smaller.
2. Convert to sRGB. Hugo drops color profiles when it makes the web images, so Display P3 scans would look washed out.
3. Save as JPEG at quality 85, named with the next free number in the folder (`001.jpg`, `002.jpg`, ...).

With macOS `sips`, for images larger than 2000px:

```
sips -Z 2000 -m "/System/Library/ColorSync/Profiles/sRGB Profile.icc" \
  -s format jpeg -s formatOptions 85 in.jpg --out 015.jpg
```

Leave out `-Z 2000` for images already 2000px or smaller, since `sips` would enlarge them.

### What Hugo generates

At build time, Hugo makes WebP versions of each photo at 800px, 1200px and 1600px on the long edge, resized with the Lanczos filter (`imaging` in `config.yml`). The grid offers all three through `srcset`, so the browser picks a size to suit the screen. Clicking a photo opens the 1600px version. The source JPEGs aren't published (`publishResources: false` in `content/gallery/index.md`).

The resized images aren't committed (`resources/_gen/` is gitignored), so Cloudflare regenerates them on every deploy. A clean build of about 150 photos takes around a minute.

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
