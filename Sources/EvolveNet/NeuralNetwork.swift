import Foundation

class Synapse {
    let index: Int
    var weight: Double = 0.0

    init(index: Int, weight: Double) {
        self.index = index
        self.weight = weight
    }

    func clone() -> Synapse {
        let synapse = Synapse(index: self.index, weight: self.weight)
        return synapse
    }

    func randomize() {
        self.weight = Double.random(in: -1...1)
    }

    func mutate(rate: Double) {
        self.weight += Double.random(in: -rate...rate)
    }

    func punctuate(pos: Int) {
        let precision: Double = Double(truncating: pow(10.0, pos) as NSNumber)
        self.weight = round(self.weight * precision) / precision
    }
}

class Neuron {
    var synapses: [Synapse] = []
    let function: String
    var activation: Double = 0.0
    var bias: Double = 0.0

    init(function: String) {
        self.function = function
    }

    func clone() -> Neuron {
        let neuron = Neuron(function: self.function)
        neuron.activation = self.activation
        neuron.bias = self.bias
        for synapse in self.synapses {
            neuron.synapses.append(synapse.clone())
        }
        return neuron
    }

    func randomize() {
        self.bias = Double.random(in: -1...1)
        for synapse in self.synapses {
            synapse.randomize()
        }
    }

    func mutate(rate: Double) {
        self.bias += Double.random(in: -rate...rate)

        let synapse_rate = rate / Double(self.synapses.count)
        for synapse in self.synapses {
            synapse.mutate(rate: synapse_rate)
        }
    }

    func punctuate(pos: Int) {
        let precision: Double = Double(truncating: pow(10.0, pos) as NSNumber)
        self.bias = round(self.bias * precision) / precision
        for synapse in self.synapses {
            synapse.punctuate(pos: pos)
        }
    }

    func activate(value: Double) {
        self.activation = value
    }

    func activate(parent: Layer) {
        var sum: Double = 0.0
        for synapse in self.synapses {
            sum += (synapse.weight * parent.neurons[synapse.index].activation)
        }
        sum += self.bias
        switch self.function {
            case "relu":
                self.activation = sum < 0.0 ? 0.0 : sum
            case "signoid":
                self.activation = (1.0/(1.0 + pow(M_E, -sum)))
            case "tanh":
                self.activation = (pow(M_E, sum) - pow(M_E, -sum)) / (pow(M_E, sum) + pow(M_E, -sum))
            default:
                self.activation = sum
        }
    }
}

public class Layer {
    var neurons: [Neuron] = []
    var size: Int
    let function: String

    public init(size: Int, function: String = "signoid") {
        self.size = size
        self.function = function
        for _ in (0..<size) {
            self.neurons.append(Neuron(function: function))
        }
    }

    func connect(parent optParent: Layer?) {
        if let parent = optParent {
            for neuron in self.neurons {
               for index in (0..<parent.neurons.count) {
                   neuron.synapses.append(Synapse(index: index, weight: 0.0))
               }
            }
        }
    }

    func clone() -> Layer {
        let layer = Layer(size: 0, function: self.function)
        layer.size = self.size
        for neuron in self.neurons {
            layer.neurons.append(neuron.clone())
        }
        return layer
    }

    func randomize() {
        for neuron in self.neurons {
            neuron.randomize()
        }
    }

    func mutate(rate: Double) {
        let neuronRate = rate / Double(self.neurons.count)
        for neuron in self.neurons {
            neuron.mutate(rate: neuronRate)
        }
    }

    func punctuate(pos: Int) {
        for neuron in self.neurons {
            neuron.punctuate(pos: pos)
        }
    }

    func activate(parent: Layer) {
        for neuron in self.neurons {
            neuron.activate(parent: parent)
        }
    }
    
    func activate(data: [Double]) {
        for index in (0..<self.neurons.count) {
            let neuron = self.neurons[index]
            neuron.activate(value: data[index])
        }
    }
}

public class NeuralNetwork: Network {
    var layers: [Layer] = []
    public var error: Double = 1.0
    
    public init() {}

    public func push(layer: Layer) {
        self.layers.append(layer)
    }

    public func connect() {
        var parent: Layer? = nil
        for layer in layers {
            layer.connect(parent: parent)
            parent = layer
        }
    }

    public func clone() -> Network {
        let network = NeuralNetwork()
        network.error = self.error
        for layer in self.layers {
            network.layers.append(layer.clone())
        }
        return network
    }

    public func randomize() -> Network {
        self.error = 1.0
        for layer in self.layers {
            layer.randomize()
        }
        return self
    }

    public func mutate() {
        for layer in self.layers {
            layer.mutate(rate: self.error)
        }
    }

    public func punctuate(pos: Int) {
        for layer in self.layers {
            layer.punctuate(pos: pos)
        }
    }

    public func run(data: [Double]) -> [Double] {
        for index in (0..<self.layers.count) {
            let layer = self.layers[index]
            if index == 0 {
                layer.activate(data: data)
            } else {
                layer.activate(parent: self.layers[index-1])
            }
        }
        return self.layers.last!.neurons.map { neuron in neuron.activation }
    }

    public func evaluate(data: [[[Double]]]) {
        var sum: Double = 0.0
        for row in data {
            let expected = row[1]
            let actual = run(data: row[0])
            for index in (0..<expected.count) {
                let exp = expected[index]
                let act = actual[index]
                let diff = exp - act
                sum += diff * diff
            }
        }
        self.error = sum / (2 * Double(data.count))
    }
}
