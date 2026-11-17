import {readFile} from 'node:fs/promises'
import {createReadStream} from 'node:fs'
import {resolve} from 'node:path'
import {getCliClient} from 'sanity/cli'

const client = getCliClient({apiVersion: '2025-02-19'}).withConfig({useCdn: false})
const source = JSON.parse(await readFile(new URL('./seed-content.json', import.meta.url), 'utf8'))
const root = resolve(import.meta.dirname, '..')

async function uploadImage(path, alt) {
  const asset = await client.assets.upload('image', createReadStream(resolve(root, path)), {
    filename: path.split('/').pop(),
  })
  return {_type: 'image', asset: {_type: 'reference', _ref: asset._id}, alt}
}

if (!(await client.getDocument('siteSettings'))) {
  const response = await fetch('https://avatars.githubusercontent.com/u/61627516?v=4')
  if (!response.ok) throw new Error('Profile image download failed')
  const portrait = await client.assets.upload('image', Buffer.from(await response.arrayBuffer()), {
    filename: 'sumit-profile.jpg',
  })
  await client.createIfNotExists({
    ...source.settings,
    portrait: {_type: 'image', asset: {_type: 'reference', _ref: portrait._id}, alt: source.settings.name},
    background: await uploadImage('assets/images/hero_background.webp', 'Workspace background'),
  })
  console.log('Imported profile and site settings')
}
for (const project of source.projects) {
  if (await client.getDocument(project._id)) continue
  const {sourceImage, ...document} = project
  document.image = await uploadImage(sourceImage, project.title)
  await client.createIfNotExists(document)
  console.log('Imported project ' + project.title)
}
for (const article of source.articles) {
  await client.createIfNotExists(article)
  console.log('Imported article ' + article.title)
}
