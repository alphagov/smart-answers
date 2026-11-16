/* global _, joint, V, adjacencyList */

(function () {
  'use strict'

  const linkBackground = '#fff'
  const outcomeBackground = '#d5e8f3'
  const questionBackground = '#fff'
  const strokeColour = '#333'

  // Helpers.
  // --------

  function buildGraphFromAdjacencyList (labels, adjacencyList) {
    const elements = []
    const links = []

    _.each(adjacencyList, function (edges, parentElementId) {
      const parentElementLabel = labels[parentElementId] || ''

      elements.push(makeElement(parentElementId, parentElementLabel, edges.length === 0))

      _.each(edges, function (childElementRecord) {
        links.push(makeLink(parentElementId, childElementRecord[0], childElementRecord[1]))
      })
    })

    // Links must be added after all the elements. This is because when the links
    // are added to the graph, link source/target
    // elements must be in the graph already.
    return elements.concat(links)
  }

  function makeLink (parentElementId, childElementId, edgeLabel) {
    return new joint.dia.Link({
      source: { id: parentElementId },
      target: { id: childElementId },
      attrs: { '.marker-target': { d: 'M 8 0 L 0 4 L 8 8 z' } },
      labels: [
        {
          position: 0.5,
          attrs: {
            rect: { fill: linkBackground },
            text: { text: edgeLabel },
            padding: 10,
            width: 100
          }
        }
      ],
      smooth: true
    })
  }

  function makeElement (id, label, isOutcome) {
    const maxLineLength = _.max(label.split('\n'), function (l) { return l.length }).length

    // Compute approx width/height of the rectangle based on the number
    // of lines in the label and the letter size.
    const letterSize = 16
    const width = 2 * (letterSize * (0.26 * maxLineLength + 1))
    const height = 2 * ((label.split('\n').length + 1) * letterSize * 0.5)

    let rectProperties = {
      width,
      height,
      rx: 5,
      ry: 5,
      stroke: strokeColour,
      'stroke-width': 1
    }

    if (isOutcome) {
      rectProperties = $.extend(rectProperties, {
        fill: outcomeBackground
      })
    } else {
      rectProperties = $.extend(rectProperties, {
        fill: questionBackground
      })
    }

    const properties = {
      id,
      size: { width, height },
      attrs: {
        text: { text: label, 'font-size': letterSize },
        rect: rectProperties
      }
    }
    return new joint.shapes.basic.Rect(properties)
  }

  // Main.
  // -----

  $(document).ready(function () {
    const graph = new joint.dia.Graph()

    const paper = new joint.dia.Paper({
      el: $('#paper'),
      gridSize: 2,
      model: graph
    })

    // Just give the viewport a little padding.
    V(paper.viewport).translate(20, 20)

    const toggleButton = $('[data-click-action=visualise]')
    toggleButton.on('click', toggleRankdir)

    let rankDir = 'TB'

    function toggleRankdir () {
      rankDir = rankDir === 'LR' ? 'TB' : 'LR'
      layout()
    }

    function layout () {
      const cells = buildGraphFromAdjacencyList(adjacencyList.labels, adjacencyList.adjacencyList)
      graph.resetCells(cells)
      joint.layout.DirectedGraph.layout(graph, {
        setLinkVertices: false,
        rankDir,
        rankSep: 100
      })
      if (rankDir === 'LR') {
        toggleButton.text('Show in portrait')
      } else {
        toggleButton.text('Show in landscape')
      }
      const padding = 400
      paper.fitToContent(10, 10, padding)
      const bbox = V(paper.viewport).bbox()
      $('#paper').width(bbox.width + padding)
      $('#paper').height(bbox.height + padding)
    }
    layout()
  })
})()
