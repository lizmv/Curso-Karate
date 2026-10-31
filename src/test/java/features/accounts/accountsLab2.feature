Feature: Accounts - Lab2

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
        And match response.balance == '#number'
        And match response.active == '#boolean'
        And match response.contact == '#object'
        And match response.tags == '#array'

    Scenario: Crear una cuenta
        * def body =
        #1. Crear
        Given path 'accounts'
        And request read('classpath:data/account.json')
        When method post
        Then status 201
        * def id=response.id
        And match response.id == '#string'
        And match response.balance == 1000
        And match response.holderName == 'Ana Rojas'
        And match header Location contains response.id

    Scenario: Crear y consultar la cuenta
       
        #1. Crear
        Given path 'accounts'
        And request read('classpath:data/account.json')
        When method post
        Then status 201
        * def id=response.id

        #2. Consultar usando el id capturado
        Given path 'accounts', id
        When method get
        Then status 200
        And match response.holderName == 'Ana Rojas'

    Scenario: Crear, actualizar con PUT  y verificar

        #1. Crear
        Given path 'accounts'
        And request read('classpath:data/account.json')
        When method post
        Then status 201
        * def id=response.id

        #2. Actualizar con PUT
        * def changes = 
                """
                {
                holderName: 'Hazel Bloom',
                active: true,
                contact: {email: 'hazelbloom@gmail.com'}
                }
            """
        Given path 'accounts', id
        And request changes
        When method put
        Then status 200
        And match response.alias == null
        And match response.tags == []
        And match response.updatedAt == '#string'

        #3. Verificar 
        Given path 'accounts', id
        When method get
        Then status 200
        And match response.holderName == 'Hazel Bloom'
        And match response.active == true
        And match response.contact.email == 'hazelbloom@gmail.com'

    Scenario: Crear y actualizar con PATCH 
        #1. Crear
        Given path 'accounts'
        And request read('classpath:data/account.json')
        When method post
        Then status 201
        * def id=response.id

        #2. Actualizar con PATCH
        Given path 'accounts', id
        And request {active: false}
        When method patch
        Then status 200
        And match response.active == false

        #3. Verificar 
        Given path 'accounts', id
        When method get
        Then status 200
        And match response.holderName == 'Ana Rojas'
        And match response.active == false
        And match response.contact.email == 'ana.rojas@novusdemo.pe'

    Scenario: Crear, eliminar y confirmar que ya no existe
        #1. Crear
        Given path 'accounts'
        And request read('classpath:data/account.json')
        When method post
        Then status 201
        * def id=response.id

        #2. Eliminar
        Given path 'accounts', id
        When method delete
        Then status 204

        #3. Consultar para confirmar que ya no existe
        Given path 'accounts', id
        When method get
        Then status 404
        And match response.code == 'ACCOUNT_NOT_FOUND'

Scenario: Actualizar con PATCH 

        #2. Actualizar con PATCH
        Given path 'accounts', 'acc-001'
        And request {balance: 5}
        When method patch
        Then status 400
        And match response.code == 'IMMUTABLE_FIELD'
        And match response.message == 'El campo balance no se puede modificar'