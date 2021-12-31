import Foundation

class LinearNetwork: Network {
    var error: Double
    var m: Double
    var b: Double

    init() {
        self.error = 1.0
        self.m = 0.0
        self.b = 0.0
    }

    func clone() -> Network {
        let network = LinearNetwork()
        network.m = self.m
        network.b = self.b
        return network
    }
    func randomize() -> Network {
        self.m = Double.random(in: -1.0...1.0)
        self.b = Double.random(in: -1.0...1.0)
        return self
    }

    func mutate() {
        self.m += Double.random(in: -0.1...0.1)
        self.b += Double.random(in: -0.1...0.1)
    }

    func punctuate(pos: Int) {
        let precision: Double = Double(truncating: pow(10.0, pos) as NSNumber)
        self.m = round(self.m * precision) / precision
        self.b = round(self.b * precision) / precision
    }

    func run(data: [Double]) -> [Double] {
        let x = data[0]
        return [(self.m * x) + self.b]
    }

    func evaluate(data: [[[Double]]]) {
        var sum: Double = 0.0
        for row in data {
            let actual = run(data: row[0])
            let expected = row[1]
            let diff = expected[0] - actual[0]
            sum += diff * diff
        }
        self.error = sum / Double(2 * data.count)
    }
}
