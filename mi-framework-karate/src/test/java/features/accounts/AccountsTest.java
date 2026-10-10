package features.accounts;

import io.karatelabs.junit6.Karate;
import org.junit.jupiter.api.DynamicNode;

class AccountsTest {

    @Karate.Test
    Iterable<DynamicNode> testAccount() {
        return Karate.run("accounts").relativeTo(getClass());
    }
}
