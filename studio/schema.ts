import {defineArrayMember, defineField, defineType} from 'sanity'

const linkRule = (rule: any) => rule.uri({scheme: ['http', 'https', 'mailto', 'tel']})
const orderField = defineField({
  name: 'order', title: 'Display order', type: 'number', initialValue: 10,
  description: 'Smaller numbers appear first. Use 10, 20, 30 to leave room between items.',
  validation: (rule) => rule.required().integer().min(0),
})
const hiddenField = defineField({
  name: 'hidden', title: 'Hide from the portfolio', type: 'boolean', initialValue: false,
  description: 'Hidden published content is still public through the API. Unpublish to withdraw it.',
})
const imageFields = [
  defineField({name: 'alt', title: 'Image description', type: 'string'}),
]
const imageField = (name: string, title: string) => defineField({
  name, title, type: 'image', options: {hotspot: true}, fields: imageFields,
})
const ordering = [{
  title: 'Portfolio order', name: 'portfolioOrder',
  by: [{field: 'order', direction: 'asc' as const}, {field: 'title', direction: 'asc' as const}],
}]
const link = defineType({
  name: 'portfolioLink', title: 'Link', type: 'object',
  fields: [
    defineField({name: 'label', type: 'string', validation: (rule) => rule.required()}),
    defineField({name: 'url', title: 'Destination URL', type: 'url', validation: linkRule}),
    defineField({name: 'visible', title: 'Show this link', type: 'boolean', initialValue: true}),
    defineField({
      name: 'icon', type: 'string', initialValue: 'link',
      options: {list: ['link', 'github', 'linkedin', 'email', 'x', 'instagram', 'medium', 'youtube', 'playStore', 'appStore']},
    }),
  ],
  preview: {select: {title: 'label', subtitle: 'url'}},
})
const button = defineType({
  name: 'heroButton', title: 'Button', type: 'object',
  fields: [
    defineField({name: 'label', type: 'string', validation: (rule) => rule.required()}),
    defineField({name: 'visible', title: 'Show this button', type: 'boolean', initialValue: true}),
    defineField({
      name: 'action', title: 'Button action', type: 'string', initialValue: 'url',
      options: {list: [
        {title: 'Open a URL', value: 'url'},
        {title: 'Open an uploaded résumé', value: 'file'},
        {title: 'Open contact form', value: 'contact'},
        {title: 'Scroll to articles', value: 'articles'},
      ]},
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'url', title: 'Destination URL', type: 'url',
      hidden: ({parent}) => parent?.action !== 'url',
      validation: (rule) => linkRule(rule).custom((value: unknown, context: any) =>
        context.parent?.action === 'url' && !value ? 'Enter a URL' : true),
    }),
    defineField({
      name: 'file', title: 'Résumé PDF', type: 'file', options: {accept: '.pdf'},
      hidden: ({parent}) => parent?.action !== 'file',
      validation: (rule) => rule.custom((value, context: any) =>
        context.parent?.action === 'file' && !value?.asset ? 'Upload a PDF' : true),
    }),
  ],
  preview: {select: {title: 'label', subtitle: 'action'}},
})
const siteSettings = defineType({
  name: 'siteSettings', title: 'Profile and site settings', type: 'document',
  groups: [
    {name: 'profile', title: 'Profile', default: true},
    {name: 'links', title: 'Buttons and socials'},
    {name: 'sections', title: 'Sections'},
    {name: 'contact', title: 'Contact'},
  ],
  fields: [
    defineField({name: 'name', title: 'Name', type: 'string', group: 'profile', validation: (r) => r.required()}),
    defineField({name: 'handle', type: 'string', group: 'profile'}),
    defineField({name: 'intro', title: 'Introduction', type: 'text', rows: 5, group: 'profile', validation: (r) => r.required()}),
    {...imageField('portrait', 'Profile photo'), group: 'profile'},
    {...imageField('background', 'Header background'), group: 'profile'},
    defineField({name: 'pageTitle', title: 'Browser title', type: 'string', group: 'profile'}),
    defineField({name: 'description', title: 'Page description', type: 'text', rows: 3, group: 'profile'}),
    defineField({
      name: 'buttons', title: 'Header buttons', type: 'array', group: 'links',
      description: 'Drag the handles to reorder buttons.',
      of: [defineArrayMember({type: 'heroButton'})],
    }),
    defineField({
      name: 'socials', title: 'Social icons', type: 'array', group: 'links',
      description: 'Add, remove or drag to reorder links.',
      of: [defineArrayMember({type: 'portfolioLink'})],
    }),
    defineField({
      name: 'sections', title: 'Homepage sections', type: 'array', group: 'sections',
      description: 'Drag to reorder. Remove a section to hide it.',
      of: [defineArrayMember({type: 'string'})],
      options: {list: [{title: 'Projects', value: 'projects'}, {title: 'Articles', value: 'articles'}]},
      validation: (r) => r.unique(),
    }),
    defineField({name: 'projectsTitle', type: 'string', group: 'sections'}),
    defineField({name: 'projectsDescription', type: 'text', group: 'sections', rows: 2}),
    defineField({name: 'projectsDisclaimer', type: 'text', group: 'sections', rows: 2}),
    defineField({name: 'articlesTitle', type: 'string', group: 'sections'}),
    defineField({name: 'footerLink', title: 'Footer link', type: 'portfolioLink', group: 'links'}),
    defineField({name: 'contactEnabled', title: 'Enable contact page', type: 'boolean', group: 'contact', initialValue: true}),
    defineField({name: 'contactTitle', type: 'string', group: 'contact'}),
    defineField({name: 'contactDescription', type: 'text', group: 'contact', rows: 3}),
    defineField({name: 'email', title: 'Public contact email', type: 'string', group: 'contact', validation: (r) => r.email()}),
    defineField({
      name: 'formspreeEndpoint', title: 'Formspree endpoint', type: 'url', group: 'contact',
      validation: (r) => r.custom((value) => !value || /^https:\/\/formspree\.io\/f\/[a-z0-9]+$/i.test(value)
        ? true : 'Use your https://formspree.io/f/... endpoint'),
    }),
  ],
  preview: {select: {title: 'name', media: 'portrait'}},
})
const project = defineType({
  name: 'project', title: 'Project', type: 'document', orderings: ordering,
  fields: [
    defineField({name: 'title', type: 'string', validation: (r) => r.required()}),
    defineField({name: 'description', type: 'text', rows: 3}),
    imageField('image', 'Project picture'),
    defineField({name: 'imageFit', type: 'string', initialValue: 'cover', options: {list: [
      {title: 'Fill the frame', value: 'cover'}, {title: 'Show the whole image', value: 'contain'},
    ]}}),
    defineField({name: 'links', type: 'array', of: [defineArrayMember({type: 'portfolioLink'})]}),
    orderField, hiddenField,
  ],
  preview: {select: {title: 'title', media: 'image', subtitle: 'description'}},
})
const article = defineType({
  name: 'article', title: 'Article', type: 'document', orderings: ordering,
  fields: [
    defineField({name: 'title', type: 'string', validation: (r) => r.required()}),
    defineField({
      name: 'slug', title: 'Article URL', type: 'slug',
      options: {source: 'title', maxLength: 96},
      validation: (r) => r.required().custom((value) => !value?.current || /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value.current)
        ? true : 'Use lowercase words separated by hyphens'),
    }),
    defineField({name: 'summary', type: 'text', rows: 3, validation: (r) => r.required()}),
    imageField('cover', 'Cover image'),
    defineField({name: 'publishedAt', title: 'Publication date', type: 'datetime'}),
    defineField({name: 'tags', type: 'array', of: [defineArrayMember({type: 'string'})], options: {layout: 'tags'}}),
    defineField({
      name: 'body', title: 'Article', type: 'array',
      validation: (r) => r.required().min(1),
      of: [
        defineArrayMember({
          type: 'block',
          styles: [
            {title: 'Paragraph', value: 'normal'}, {title: 'Heading', value: 'h2'},
            {title: 'Subheading', value: 'h3'}, {title: 'Quote', value: 'blockquote'},
          ],
          lists: [{title: 'Bullets', value: 'bullet'}, {title: 'Numbered', value: 'number'}],
          marks: {
            decorators: [{title: 'Bold', value: 'strong'}, {title: 'Italic', value: 'em'}, {title: 'Code', value: 'code'}],
            annotations: [{
              name: 'link', type: 'object', title: 'Link',
              fields: [{name: 'href', type: 'url', validation: linkRule}],
            }],
          },
        }),
        defineArrayMember(imageField('articleImage', 'Image')),
        defineArrayMember({
          name: 'codeBlock', title: 'Code block', type: 'object',
          fields: [
            {name: 'language', title: 'Language', type: 'string', initialValue: 'dart'},
            {name: 'code', type: 'text', rows: 12, validation: (r) => r.required()},
          ],
          preview: {select: {title: 'language', subtitle: 'code'}},
        }),
      ],
    }),
    orderField, hiddenField,
  ],
  preview: {select: {title: 'title', subtitle: 'summary', media: 'cover'}},
})
export const schemaTypes = [siteSettings, project, article, link, button]
