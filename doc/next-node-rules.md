# Next node rules

#### Using `next_node` with a block

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
