# Next node rules

## Using `next_node` with a block

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

## Errors

### Next node undefined

Occurs if the `next_node` block returns something "falsey" (e.g. `nil`).

```ruby
# For example
next_node(permitted: []) do
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
