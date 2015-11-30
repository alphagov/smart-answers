# Developing without using the VM

The simplest way to get Smart Answers running locally is to run:

```bash
$ PLEK_SERVICE_CONTENTAPI_URI=https://www.gov.uk/api \
PLEK_SERVICE_STATIC_URI=https://assets-origin.preview.alphagov.co.uk \
rails s
```

This tells Smart Answers to use the production Content API and the asset server from the preview environment.

If you don't set either environment variable then the app will attempt to connect to the content API and asset server at http://contentapi.dev.gov.uk and http://static.dev.gov.uk respectively. NOTE. These are available automatically if you're [developing using the VM](developing-using-vm.md). If the app can't connect to these hosts then you'll see [errors][common-errors.md].
