# Using content blocks in Smart Answers

You can use content blocks from the [Content Block Manager](https://content-block-manager.publishing.service.gov.uk) in Smart Answers.  
This lets you reuse content across multiple Smart Answers, which will automatically update when the content block is updated.

## Content block embed codes

A content block embed code is a short snippet used to embed a content block. It looks like this:

```
{{embed:content_block_contact:information-commissioners-office}}
````

## Using an embed code in a Smart Answer

You can use embed codes in a Smart Answer’s Flow, Calculator or view.  

To fetch a content block using an embed code, call the [`ContentBlockTools::ContentBlock.from_embed_code` method](https://github.com/alphagov/govuk_content_block_tools/blob/69f06ce51513e47f2cc2925b933a0de09249a516/lib/content_block_tools/content_block.rb#L69):

```ruby
block = ContentBlockTools::ContentBlock.from_embed_code("{{embed:content_block_contact:information-commissioners-office}}")
````

You can then use the [`render` method](https://github.com/alphagov/govuk_content_block_tools/blob/69f06ce51513e47f2cc2925b933a0de09249a516/lib/content_block_tools/content_block.rb#L93) to return the content block as an HTML string:

```ruby
block.render #=> "<div class=\"content-block content-block--contact\" ..."
```

## Publishing a Smart Answer that uses content blocks

After adding a content block to a Smart Answer, you must [republish the Smart Answer](https://github.com/alphagov/smart-answers/blob/main/docs/tasks/publishing.md).
This ensures the Smart Answer is shown as dependent content in Content Block Manager. It also allows changes to the content block to be previewed in the context of the Smart Answer.

This process uses the [`ContentBlockDetector` class](https://github.com/alphagov/smart-answers/blob/main/app/services/content_block_detector.rb) to detect embedded content blocks and send them to the Publishing API as links.

## Limitations

Because the Content Block Manager’s preview service finds and replaces content blocks within pages, it’s not yet possible to use content blocks in Calculations.
We plan to address this in the future.
