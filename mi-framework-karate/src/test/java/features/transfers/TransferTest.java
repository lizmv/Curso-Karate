package features.transfers;

import io.karatelabs.junit6.Karate;
import org.junit.jupiter.api.DynamicNode;

class TransferTest {

    @Karate.Test
    Iterable<DynamicNode> testTransfer() {
        return Karate.run().relativeTo(getClass());
    }
}
