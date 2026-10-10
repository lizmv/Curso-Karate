Feature: Accounts - Lab1

Background: 
    Given url baseUrl
    And path 'auth', 'login'
    And request { username: '#(user)', password: '#(pass)' }
    When method post
    Then status 200
    And match response.tokenType == 'Bearer'
    * def token = response.token
    * configure headers= { Authorization: '#("Bearer " + token)' }
    
Scenario: Detalle de una cuenta (path)
    Given path 'accounts', 'acc-001'
    When method get
    Then status 200
    And match response.currency == 'PEN'
    And match response.balance == '#number'
    And match response.active == '#boolean'
    And match response.contact == '#object'
    And match response.tags == '#array'

Scenario: Listar cuentas por paginazion
    Given path 'accounts'
    And param pageSize= 10
    When method get
    Then status 200
    And match response.items == '#[10]'
    
Scenario: Buscar cuenta no existente
    Given path 'accounts', 'acc-999'
    When method get
    Then status 404
    And match response.code == 'ACCOUNT_NOT_FOUND'
    And match response.message == 'No existe la cuenta acc-999'

Scenario: Filtrar por param y paginacion
    Given path 'accounts'
    And params {currency: 'USD', pageSize: 4}
    When method get
    Then status 200
    And match response.items == '#[4]'
    And match each response.items[*].currency == 'USD'
    
  

