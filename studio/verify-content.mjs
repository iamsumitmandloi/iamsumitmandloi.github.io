// Verify the same public access that portfolio visitors use (no auth token).
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source = await readFile(new URL('../lib/content/sanity_repository.dart', import.meta.url), 'utf8')
const query = source.match(/const query = r'''([\s\S]*?)'''/)[1]
const url = new URL('https://8egglvol.api.sanity.io/v2025-02-19/data/query/production')
url.search = new URLSearchParams({query,perspective:'published','$slug':JSON.stringify('dart-event-loop-and-isolates')})
const response = await fetch(url)
assert(response.ok)
const {result} = await response.json()
assert(result.settings?.name)
assert(result.projects.length > 0, 'No publicly readable projects')
assert(result.articles.length > 0, 'No publicly readable articles')
assert(result.article?.body.length > 0, 'Article body is unavailable')
assert(result.projects.every(p => p.imageUrl?.startsWith('https://cdn.sanity.io/')))
console.log(`Public content verified: ${result.projects.length} projects, ${result.articles.length} articles, ${result.article.body.length} article blocks`)
