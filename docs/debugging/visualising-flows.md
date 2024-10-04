# Visualising flows

To see an interactive visualisation of a smart answer flow, append `/y/visualise` to the root of a smart answer URL e.g. `http://smart-answers.dev.gov.uk/<smart-answer>/y/visualise` or `https://www.gov.uk/<smart-answer>/y/visualise`

To see a static visualisation of a smart answer flow, using Graphviz:

```bash
# Download graphviz representation
$ curl https://www.gov.uk/check-uk-visa/y/visualise.gv --silent > /tmp/check-uk-visa.gv

# Use Graphviz to generate a PNG
$ dot /tmp/check-uk-visa.gv -Tpng > /tmp/check-uk-visa.png

# Open the PNG
$ open /tmp/check-uk-visa.png
```

__NOTE.__ This assumes you already have Graphviz installed. You can install it using Homebrew on a Mac (`brew install graphviz`).
