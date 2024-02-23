# State Management and Eliminating Redundant Rerenders



## Control the state

You can control the view state like this:

```swift
import Grape

struct MyStatefulGraph: View {

    // States including running status, transformation, etc.
    // Gives you a handle to control the states.
    @State var graphStates = ForceDirectedGraphState() 
    
    var body: some View {
        ForceDirectedGraph(states: graphStates) {
            // ...
        } force: {
            // ...
        }
    }
}
```

`ForceDirectedGraphState` utilizes the `Observation` framework so all you need to change the state is to mutate its properties:

```swift

    graphStates.isRunning.toggle()

    graphStates.transform = .identity // reset transform to identity

```

## Eliminate redundant rerenders

One trick to eliminate redundant rerenders is to not referencing any observed properties in the `body` of the `View`. Instead, try to reference the entire `Observable` object. This way, the `body` will not re-evaluate when the observed properties change.

```swift
import Grape

struct MyStatefulGraph: View {

    // States including running status, transformation, etc.
    // Gives you a handle to control the states.
    @State var graphStates = ForceDirectedGraphState() 
    
    var body: some View {
        HStack {
            ForceDirectedGraph(states: graphStates) {
                // ...
            } force: {
                // ...
            }
            GraphStateToggle(graphStates: graphStates) // seperate views so we can reference the entire graphStates
        }
    }
}

struct GraphStateToggle: View {
    @Bindable var graphStates: ForceDirectedGraphState
    var body: some View {
        Button {
            graphStates.isRunning.toggle()
        } label: {
            // ...
        }
    }
}
```

Although this introduces boilerplates, `Grape` do benifit from this pattern since its re-evaluation is expensive (especially with large graphs or heavy rich text labels).

> This might not always work for other `Observation` based state management. 