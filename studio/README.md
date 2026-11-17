# Portfolio admin

Open https://sumit-portfolio-8egglvol.sanity.studio/ and sign in with the GitHub account that owns the Sanity project.

## Editing the portfolio

- **Profile and site settings** contains your name, photo, introduction, background, résumé buttons, social links, contact settings, section headings, and homepage section order.
- Drag buttons, social links, and homepage sections to change their order.
- Toggle **Show this button/link** to control visibility.
- **Projects** contains each project's description, uploaded image and links. **Display order** sorts ascending, so 10 appears before 20.
- **Articles** contains the title, summary, URL slug, cover, and rich-text body. Use the insert menu for images and code blocks. Generate the URL slug before publishing. Display order controls the article list.
- Edits are drafts until you select **Publish**. **Unpublish** withdraws a document. **Hide from the portfolio** removes it from the UI, but published documents remain readable through the public API.
- Removing a homepage section hides that section without deleting its documents.
- To preview a published article, open https://iamsumitmandloi.github.io/?article=YOUR-SLUG.

The Flutter site requests published content from the Sanity CDN on each page load, when the tab becomes active, and every five minutes while visible. CDN caching can briefly delay updates. Reload after publishing to request fresh content. No Flutter rebuild is required for content edits.

Profile and articles are stored in project 8egglvol, dataset production. The public app has no write token. Studio access is authenticated with Sanity.

## Development

Use Node 24 LTS (or another version supported by the installed Sanity release).

    npm ci
    npm run check
    npm run dev

Deploy Studio schema or interface changes with:

    npm run deploy

Content edits only require Publish. Studio deployment is for changes to fields or editor configuration.

## Migration

seed-content.json preserves the initial portfolio content for migration. It is not loaded by Flutter. After authenticating with the Sanity CLI, import missing documents and assets with:

    npx sanity exec seed.mjs --with-user-token

The importer uses stable IDs and createIfNotExists, so it leaves edited documents intact. Public document IDs must not contain dots; Sanity reserves dotted paths for authenticated access.

Verify public access after migration with `node verify-content.mjs` from the studio directory. This checks the Flutter query without an API token.

## Public website

The Flutter app reads published content at runtime. There is no bundled portfolio fallback. A failed initial fetch displays Retry; a failed refresh preserves the last fetched content in memory and indicates that the refresh failed.

Article URLs use query parameters so new posts work directly on GitHub Pages without server-side routing or a new deployment. The two original HTML article URLs redirect to their CMS-backed routes.

The initial HTML has generic metadata. Flutter updates the page title and metadata after content loads. Social crawlers that do not execute the application receive generic previews. Per-article server-rendered previews are outside this static Flutter implementation.
