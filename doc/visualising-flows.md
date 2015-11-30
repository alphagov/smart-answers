# Visualising flows

To see an interactive visualisation of a smart answer flow, append `/visualise` to the root of a smartanswer URL e.g. `http://smartanswers.dev.gov.uk/<my-flow>/visualise/`

To see a static visualisation of a smart answer flow, using Graphviz:

```bash
# Download graphviz representation
$ curl https://www.gov.uk/marriage-abroad/visualise.gv --silent > /tmp/marriage-abroad.gv

# Use Graphviz to generate a PNG
$ dot /tmp/marriage-abroad.gv -Tpng > /tmp/marriage-abroad.png

# Open the PNG
$ open /tmp/marriage-abroad.png
```

__NOTE.__ This assumes you already have Graphviz installed. You can install it using Homebrew on a Mac (`brew install graphviz`).
