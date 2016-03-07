# Next node rules

The `next_node` method takes a block that should return the name of the next node (question or outcome) to send the user to.

We define the permitted next nodes so that we can visualise the Smart Answer flows.

```ruby
permitted_next_nodes = [
  :green,
  :red
]
next_node(permitted: permitted_next_nodes) do |response|
  if response == 'green'
    :green # Go to the :green node
  else
    :red   # Go to the :red node
  end
end
```

## Shortcut

If the next node for a question is always the same then you can call `next_node` with a single node key. This will automatically add the specified node key to the list of permitted next nodes i.e. there is no need to specify the `:permitted` option.

```ruby
# For example
next_node :red
```

## Errors

### Multiple calls to next_node are not allowed

Occurs if `next_node` is called more than once within a single question block.

```ruby
# For example
next_node :red
next_node :green
```

### ArgumentError: You must specify at least one permitted next node

Occurs if the list of permitted next nodes is empty.

```ruby
# For example
next_node(permitted: []) do
  :red
end
```

### ArgumentError: You must specify a block or a single next node key

Occurs if `next_node` is called without a block and with no arguments.

```ruby
# For example
next_node
```

### Next node undefined

Occurs if the `next_node` block returns something "falsey" (e.g. `nil`).

```ruby
# For example
next_node(permitted: [:red]) do
  nil
end
```

### Next node not in list of permitted next nodes

Occurs if the `next_node` block returns a value that doesn't appear in the array passed as the `permitted` option to the `next_node` block.

```ruby
# For example
next_node(permitted: [:red]) do
  :green
end
```

### Node "node-name" does not exist

Occurs if the `next_node` blocks returns a value that isn't defined as a question or outcome node.

```ruby
# For example
next_node(permitted: [:red]) do
  :red
end
outcome :green
```
