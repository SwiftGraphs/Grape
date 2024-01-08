# Creating a Force Directed Graph



## Describe a graph

A graph is a collection of nodes and links. Each node is connected to other nodes by links. In Grape, you describe a node with a `NodeMark` and a link with a `LinkMark`. `NodeMark` and `LinkMark` are associated with an `id` or `id`s that identifies them. An `id` can be any type that conforms to `Hashable`. 

Grape provides a `ForceDirectedGraph` view to visualize a graph. You can easily initialize it like you would do in SwiftUI. 

```swift

struct MyGraph: View {
    var body: some View {
        ForceDirectedGraph {
            NodeMark(id: "A")
            NodeMark(id: "B")
            LinkMark(from: "A", to: "B")
        }
    }
}

```

For the array data,  `Series` comes handy for describing a collection of nodes and links. Consider it a simplified version of `ForEach` in SwiftUI. 

@Row {
   @Column {

```swift

struct MyGraph: View {
    let myNodes = ["A", "B", "C"]
    let myLinks = [("A", "B"), ("B", "C")]

    var body: some View {
        ForceDirectedGraph {
            Series(myNodes) { id in
                NodeMark(id: id)
            }
            Series(myLinks) { from, to in
                LinkMark(from: from, to: to)
            }
        }
    }
}

```
   }


   @Column {

    @Image(source: "BasicExample.png", alt: "Rendered example of a small graph") {
        Rendered example of a small graph.
    }

   }
}



> Grape currently does not protect you from linking to non-existing nodes. If you link to a node that does not exist, view crashes.


## Customize forces

You can customize the forces that interfere with the nodes and links. By default, Grape uses a `LinkForce` and a `ManyBodyForce`. 

For example, the `CenterForce` can keep the mass center of the graph at the center of the view, so it does not drift away. To add a `CenterForce`, you can do the following. 


```swift
struct MyGraph: View {
    let myNodes = ["A", "B", "C"]
    let myLinks = [("A", "B"), ("B", "C")]

    var body: some View {
        ForceDirectedGraph {
            Series(myNodes) { id in
                NodeMark(id: id)
            }
            Series(myLinks) { from, to in
                LinkMark(from: from, to: to)
            }
        } force: {
            ManyBodyForce()
            LinkForce()
            CenterForce()
        }
    }
}
```

Note that when you override the default forces, you may need to add the `LinkForce` and `ManyBodyForce` back. Otherwise, the nodes may stay static since no forces are moving them to other places.

## Decorate marks

Add modifiers like you would do in SwiftUI to style your nodes and links. 

```swift

struct MyGraph: View {
    let myNodes = ["A", "B", "C"]
    let myLinks = [("A", "B"), ("B", "C")]

    var body: some View {
        ForceDirectedGraph {
            Series(myNodes) { id in
                NodeMark(id: id)
                    .foregroundStyle(.blue)
            }
            Series(myLinks) { from, to in
                LinkMark(from: from, to: to)
            }
        }
    }
}

```


## Respond to interactions and events

Grape provides a set of interactions and events to help you respond to user interactions, including dragging, zooming, and tapping. They are mostly supported by default, and you can install your callbacks to respond to them. 


For detailed usages, please refer to [MermaidVisualization.swift](https://github.com/li3zhen1/Grape/blob/main/Examples/ForceDirectedGraphExample/ForceDirectedGraphExample/MermaidVisualization.swift).


@Video(source: "https://github.com/li3zhen1/Grape/assets/45376537/80d933c1-8b5b-4b1a-9062-9628577bd2e0", alt: "A screen record of mermaid")


// TODO: Add examples