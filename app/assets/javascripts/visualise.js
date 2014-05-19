// Helpers.
// --------

function buildGraphFromAdjacencyList(labels, adjacencyList) {

    var elements = [];
    var links = [];

    _.each(adjacencyList, function(edges, parentElementId) {
        var parentElementLabel = labels[parentElementId] || "";

        elements.push(makeElement(parentElementId, parentElementLabel, edges.length==0));

        _.each(edges, function(childElementRecord) {
            links.push(makeLink(parentElementId, childElementRecord[0], childElementRecord[1]));
        });
    });

    // Links must be added after all the elements. This is because when the links
    // are added to the graph, link source/target
    // elements must be in the graph already.
    return elements.concat(links);
}

function makeLink(parentElementId, childElementId, edgeLabel) {
  return new joint.dia.Link({
    source: { id: parentElementId },
    target: { id: childElementId },
    attrs: { '.marker-target': { d: 'M 8 0 L 0 4 L 8 8 z' } },
    labels: [
      {
        position: 0.5,
        attrs: {
          rect: { fill: '#F5E9A2' },
          text: { text: edgeLabel },
          padding: 10,
          width: 100
        }
      }
    ],
    smooth: true
  });
}

function makeElement(id, label, isOutcome) {
  var maxLineLength = _.max(label.split('\n'), function(l) { return l.length; }).length;

  // Compute approx width/height of the rectangle based on the number
  // of lines in the label and the letter size.
  var letterSize = 16;
  var width = 2 * (letterSize * (0.26 * maxLineLength + 1));
  var height = 2 * ((label.split('\n').length + 1) * letterSize * 0.5);

  var rectProperties = {
    width: width,
    height: height,
    rx: 5,
    ry: 5,
    stroke: '#aaa',
    'stroke-width': 1
  };

  if (isOutcome) {
    rectProperties = $.extend(rectProperties, {
      fill: '#afa'
    });
  } else {
    rectProperties = $.extend(rectProperties, {
      fill: '#fff'
    });
  }

  var properties = {
    id: id,
    size: { width: width, height: height },
    attrs: {
      text: { text: label, 'font-size': letterSize, 'font-family': 'verdana' },
      rect: rectProperties
    }
  };
  return new joint.shapes.basic.Rect(properties);
}

// Main.
// -----

$(document).ready(function() {
    var graph = new joint.dia.Graph;

    var paper = new joint.dia.Paper({
        el: $('#paper'),
        gridSize: 2,
        model: graph
    });

    // Just give the viewport a little padding.
    V(paper.viewport).translate(20, 20);

    $('#btn-layout').on('click', layout);

    function layout() {
        var cells = buildGraphFromAdjacencyList(adjacencyList['labels'], adjacencyList['adjacencyList']);
        graph.resetCells(cells);
        joint.layout.DirectedGraph.layout(graph, { setLinkVertices: false, rankDir: 'LR', rankSep: 100 });
    }
    layout();
    var padding = 400;
    paper.fitToContent(10, 10, padding);
    var bbox = V(paper.viewport).bbox()
    $('#paper').width(bbox.width + padding);
    $('#paper').height(bbox.height + padding);
});
