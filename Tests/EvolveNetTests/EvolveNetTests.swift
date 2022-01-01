import XCTest
@testable import EvolveNet

final class EvolveNetTests: XCTestCase {
    func testLinear() throws {
        let data: [[[Double]]] = [
            [[0.0],[0.0]],
            [[1.0],[1.0]],
            [[2.0],[2.0]],
            [[3.0],[3.0]],
            [[4.0],[4.0]],
        ]

        let linear = LinearNetwork()
        let organism = EvolveNet(network: linear)
        let network = organism.evolve(data: data)

        XCTAssertEqual(network.run(data: [5.0])[0], 5.0)
        XCTAssertEqual(network.run(data: [1000.0])[0], 1000.0)
    }

    func testQuadradic() throws {
        var data: [[[Double]]] = []
        var input: [Double] = []
        var output: [Double] = []

        (-10..<10).forEach {
            input.append(Double($0))
            output.append(Double($0 * $0))
            data.append([input, output])
        }

        let quadradic = QuadradicNetwork()
        let organism = EvolveNet(network: quadradic)
        let network = organism.evolve(data: data)

        XCTAssertEqual(network.run(data: [5.0])[0], 25.0)
        XCTAssertEqual(network.run(data: [10.0])[0], 100.0)
        XCTAssertEqual(network.run(data: [100.0])[0], 10000.0)
    }

    func testNeural() throws {
        let data: [[[Double]]] = [
            [[0.0, 0.0],[0.0]],
            [[0.0, 1.0],[1.0]],
            [[1.0, 0.0],[1.0]],
            [[1.0, 1.0],[0.0]],
        ]

        let neural = NeuralNetwork()
        neural.push(layer: Layer(size: 2))
        neural.push(layer: Layer(size: 2))
        neural.push(layer: Layer(size: 1))
        neural.connect()
        
        let organism = EvolveNet(network: neural)
        let network = organism.evolve(data: data)

        XCTAssertLessThan(network.run(data: [0.0, 0.0])[0], 0.1)
        XCTAssertGreaterThan(network.run(data: [0.0, 1.0])[0], 0.9)
        XCTAssertGreaterThan(network.run(data: [1.0, 0.0])[0], 0.9)
        XCTAssertLessThan(network.run(data: [1.0, 1.0])[0], 0.1)
    }
}
