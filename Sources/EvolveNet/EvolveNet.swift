import Logging

public class EvolveNet {
    var networks: [Network] = []
    var logger = Logger(label: "EvolveNet")

    public init(network: Network, population: Int = 16) {
        for _ in 0..<population {
            self.networks.append(network.clone().randomize())
        }
    }

    public func evolve(data: [[[Double]]],
                generations: Int = 10000,
                errorThreshold: Double = 0.0,
                logEach: Int = 1000) async -> Network {

        for gen in 0..<generations {
            // Evalutate each network
            if #available(macOS 10.15, *) {
                var tasks: [Task<Any, Error>] = []
                for network in self.networks {
                    let task = Task<Any, Error> { return network.evaluate(data: data) }
                    tasks.append(task)
                }
                for task in tasks {
                    do {
                        let _ = try await task.value
                    } catch {
                        print("Error")
                    }
                }
            } else {
                for network in self.networks {
                    network.evaluate(data: data)
                }
            }
            
            // Sort from best to worst error
            self.networks.sort { $0.error < $1.error }

            // Determine Error
            let error = self.networks[0].error
            if error <= errorThreshold {
                logger.info("generation: \(gen) error: \(error). below threshold. breaking.")
                break
            }
            if gen % logEach == 0 {
                logger.info("generation: \(gen) error: \(error).")
            }

            // Kill bottom quarter
            let half = self.networks.count / 2
            let quarter = half / 2
            self.networks = Array(self.networks[0...(half+quarter)])

            // Clone top quarter
            self.networks[0...quarter].forEach { self.networks.append($0.clone()) }

            // Punctuate top
            self.networks[1..<4].enumerated().forEach { $1.punctuate(pos: $0) }

            // Mutate
            self.networks[4...].forEach { $0.mutate() }
        }

        self.networks.sort { $0.error < $1.error }
        return self.networks[0]
    }
}

