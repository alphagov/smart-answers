# Next node rules

The `next_node` method takes a block that should return the next node (question or outcome) to send the user to. The relevant node key must be returned via the `question` or `outcome` method.

```ruby
next_node do |response|
  if response == 'green'
    question :green? # Go to the :green? question node
  else
    outcome :red # Go to the :red outcome node
  end
end
```

## Errors

### Multiple calls to next_node are not allowed

Occurs if `next_node` is called more than once within a single question block.

```ruby
# For example
next_node do
  outcome :red
end
next_node do
  question :green?
end
```

### ArgumentError: You must specify a block

Occurs if `next_node` is called without a block.

```ruby
# For example
next_node
```

### Next node undefined

Occurs if the `next_node` block returns something "falsey" (e.g. `nil`).

```ruby
# For example
next_node do
  nil
end
```

### Next node not returned via question or outcome method

Occurs if the `next_node` block returns something which was not returned by a
call to `#question` or `#outcome`.

```ruby
# For example
next_node do
  :green?
end
```

### Node "node-name" does not exist

Occurs if the `next_node` blocks returns a value that isn't defined as a question or outcome node.

```ruby
# For example
next_node do
  outcome :red
end
outcome :blue
```
