Feature: Transfers

Background:
  * url baseUrl

Scenario: Crear una transferencia y verificar el debito
  Given path 'accounts', 'acc-002'
  When method get
  Then status 200
  * def before = response.balance

  Given path 'transfers'
  And request { fromAccountId: 'acc-002', toAccountId: 'acc-003', amount: 350.50, currency: 'PEN' }
  When method post
  Then status 201
  And match response.status == 'pending'
  And match response.completedAt == null
  * def transferId = response.id

  Given path 'accounts', 'acc-002'
  When method get
  Then status 200
  And match response.balance == before - 350.50

Scenario: Esperar a que la transferencia se complete
  Given path 'transfers'
  And request { fromAccountId: 'acc-001', toAccountId: 'acc-002', amount: 150.50, currency: 'PEN' }
  When method post
  Then status 201
  And match response.status == 'pending'
  And match response.completedAt == null
  * def transferId = response.id

  * configure retry = { count: 5, interval: 2000 }
  Given path 'transfers', transferId
  And retry until response.status == 'completed'
  When method get
  Then status 200
  And match response.completedAt == '#string'

Scenario Outline: Transferencias invalidas <code>
  Given path 'transfers'
  And request { fromAccountId: '<from>', toAccountId: '<to>', amount: <amount> }
  When method post
  Then status <status>
  And match response.code == '<code>'

  Examples:
    | from    | to      | amount | status | code                |
    | acc-008 | acc-001 | 500    | 422    | INSUFFICIENT_FUNDS  |
    | acc-007 | acc-001 | 10     | 422    | ACCOUNT_INACTIVE    |
    | acc-001 | acc-009 | 10     | 422    | CURRENCY_MISMATCH   |
    | acc-001 | acc-001 | 10     | 400    | SAME_ACCOUNT        |
    | acc-001 | acc-002 | 1.234  | 400    | INVALID_AMOUNT      |
    | acc-999 | acc-002 | 10     | 404    | ACCOUNT_NOT_FOUND   |
    