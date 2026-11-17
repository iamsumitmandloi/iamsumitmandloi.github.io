import {defineConfig} from 'sanity'
import {structureTool} from 'sanity/structure'
import {schemaTypes} from './schema'

export default defineConfig({
  name: 'portfolio',
  title: 'Sumit · Portfolio',
  projectId: '8egglvol',
  dataset: 'production',
  plugins: [
    structureTool({
      structure: (S) => S.list().title('Portfolio').items([
        S.listItem().title('Profile and site settings')
          .child(S.document().schemaType('siteSettings').documentId('siteSettings')),
        S.divider(),
        S.documentTypeListItem('project').title('Projects'),
        S.documentTypeListItem('article').title('Articles'),
      ]),
    }),
  ],
  schema: {
    types: schemaTypes,
    templates: (templates) => templates.filter((item) => item.schemaType !== 'siteSettings'),
  },
  document: {
    actions: (actions, context) => context.schemaType === 'siteSettings'
      ? actions.filter((item) => ['publish', 'discardChanges', 'restore'].includes(item.action ?? ''))
      : actions,
  },
})
