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
        
    Scenario: Crear una cuenta
        * def body =
        """
            {
            holderName: 'Hazel Bloom',
            currency: 'PEN',
            initialBalance: 1000,
            contact: {
                email: 'hazel.bloom@example.com'}
            }
        """
        # Crear
        Given path 'accounts'
        And request body
        When method post
        Then status 201
        And match response.id == '#string'
        And match response.balance == 1000
        And match response.holderName == body.holderName
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


    #casos con cuentas en duro
    # Scenario: PUT reemplaza los campos mutables
    #   * def changes = 
    #          """
    #         {
    #         holderName: 'Humberto Ramos',
    #         active: true,
    #         contact: {email: 'humberto.ramos@novusdemo.pe'}
    #         }
    #     """
    #   Given path 'accounts', 'acc-17bf39bd'
    #   And request changes
    #   When method put
    #   Then status 200
    #   And match response.alias == null
    #   And match response.tags == []
    #   And match response.updatedAt == '#string' 
    

    Scenario: PATCH solo cambia lo enviado
        Given path 'accounts', 'acc-010'
        And request {active: false}
        When method patch
        Then status 200
        And match response.active == false
        And match response.holderName =='#string'

    #Casos con cuenta en duro
    # Scenario: Eliminar y cofirmar que ya no existe
    #     #1. Eliminar
    #     Given path 'accounts', 'acc-48a617b0'
    #     When method delete
    #     Then status 204

    #     #2. Consultar para confirmar que ya no existe
    #     Given path 'accounts', 'acc-48a617b0'
    #     When method get
    #     Then status 404
    #     And match response.code == 'ACCOUNT_NOT_FOUND'
