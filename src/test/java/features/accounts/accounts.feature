Feature: Cuentas

Background: 
    Given url baseUrl
    # And path 'auth', 'login'
    # And request { username: '#(user)', password: '#(pass)' }
    # When method post
    # Then status 200
    # And match response.tokenType == 'Bearer'
    # * def token = response.token
    # * configure headers= { Authorization: '#("Bearer " + token)' }
    
Scenario: Detalle de una cuenta (path)
    Given path 'accounts', 'acc-001'
    When method get
    Then status 200
    And match response.currency == 'PEN'

Scenario: Filtrar por query param
    Given path 'accounts'
    And param currency = 'USD'
    When method get
    Then status 200
    And match each response.items contains { currency: 'USD'}
    
Scenario: Paginar con varios params
    Given path 'accounts'
    And params {page: 2, pageSize: 5}
    When method get
    Then status 200
    And match response.page == 2
    And match response.items == '#[5]'
  

Scenario: Contrato de una cuenta
    * def schema = read('classpath:schemas/account.json')
    Given path 'accounts', 'acc-006'
    When method get
    Then status 200
    And match response == schema

Scenario: Crear una cuenta con datos generados
    * def body = read('classpath:data/account.json')
    * def ref = karate.uuid()
    * set body.alias = 'qa-' + ref.substring(0, 8)
    * set body.holderName = 'QA ' + karate.faker.firstName()
    * set body.contact.email = karate.faker.email()
    //borrar los prints luego, no se deben dejar en codigo
    * print "Datos usados: ", body 
    Given path 'accounts'
    And request body
    When method post
    Then status 201
    And match response.alias == body.alias

Scenario: Actualizar una cuenta existente
    //* def helper = read('classpath:common/create-account.feature')
    * def created = call read('classpath:common/create-account.feature')
    * def changes = {holderName: 'Nuevo', active: true}
    * set changes.contact = created.account.contact

    Given path 'accounts', created.id
    And request changes
    When method put
    Then status 200