# ADR 2: Rummager integration via Publishing API

## Context

We are currently moving to use the publishing API as the source of truth for data in our search index - we had each application integrate directly with rummager - this will help standardise how data is inserted into our index and simplify the reindexing process.

Smart answers currently sends a single document to rummager per a smart answer which is indexed under the smart page URL. This document contains all the text from all the nodes (questions and outcomes) associated with the smart answer.

In addition to this smart answers sends two documents to the publishing API for each smart answer:

1. A document representing the start page, this document only contains the text present on the start page. This has a document type of `transaction`
1. A document representing the flow, this has the URL for the flow base page and does not contain any content. This has a document type of `smart-answer`

## Options

In order to move to indexing via rummager we will need to change what data is sent to the publishing API, the following options have been considered:

1. Add the content for each node to a new array item on the document schema at `details -> nodes` for the start page.

  This has the negative side effect of adding the new item to all `transaction` dcument types - this document type is also used by the `publisher` application. It has also been suggested that "something feels wrong about adding context-specific data to a schema because search happens to use it".

1. Change the document type for the start page then add the new array item to the new content schema.

  This would avoid the issue posed by multiple applications using the same document type, however this is potentially a large piece of work.

1. Add the content to any existing document schema item at `hidden_indeaxable_content` for the flow base page.

  This would increase the system complexity as it would require rummager to merge the two records from the publishing API into a single item in the rummager index, this functionality is not currently supported and would require a reworking of the queue based processing.

  This raises the question about the `hidden_indexable_content` field which is something that we want to remove in the future as it is considered a hack which is primarily used by `specialist_publisher` to store PDF content as we are not currently able to extract it from the PDF documents.

1. Add the content to any existing document schema item at `hidden_indeaxable_content` for the start page.

  As stated above we want to remove this field long term.

  This is consider the easiest option to implement.


## Decision


## Status


## Consequences
