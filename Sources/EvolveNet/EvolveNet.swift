import Logging

class EvolveNet {
    var networks: [Network] = []
    var logger = Logger(label: "EvolveNet")

    init(network: Network, population: Int = 32) {
        for _ in 0..<population {
            self.networks.append(network.clone().randomize())
        }
    }

    func evolve(data: [[[Double]]],
                generations: Int = 10000,
                errorThreshold: Double = 0.0,
                logEach: Int = 1000) -> Network {

        for gen in 0..<generations {
            // Evalutate each network
            self.networks.forEach { network in network.evaluate(data: data) }

            // Sort from best to worst error
            self.networks.sort { $0.error < $1.error }

            // Determine Error
            let error = self.networks[0].error
            if error <= errorThreshold {
                logger.info("generation: \(gen) error \(error). below threshold. breaking.")
                break
            }
            if gen % logEach == 0 {
                logger.info("generation: \(gen) error \(error).")
            }

            // Kill bottom half
            let size = self.networks.count / 2
            self.networks = Array(self.networks[0..<size])

            // Clone top half
            self.networks.forEach { self.networks.append($0.clone()) }

            // Punctuate top
            self.networks[1..<8].enumerated().forEach { $1.punctuate(pos: $0) }

            // Mutate
            self.networks[8...].forEach { $0.mutate() }
        }

        self.networks.sort { $0.error < $1.error }
        return self.networks[0]
    }
}

