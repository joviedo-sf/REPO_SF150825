global class dtmAltaDeResellerController {
    global static dtmAltaDeReseller.dtmAltaDeResellerResponse integrarConEndpointExterno(String jsonInput){
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://960d622d-75f3-480d-b955-44c943f04287.mock.pstmn.io/obtenerServicio';//Poner endpoint
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonInput);
        HttpResponse response = https.send(request);
        dtmAltaDeReseller.dtmAltaDeResellerResponse respuesta;
        
        if (response.getStatusCode() == 200) {
            respuesta = (dtmAltaDeReseller.dtmAltaDeResellerResponse) JSON.deserialize(response.getBody(), dtmAltaDeReseller.dtmAltaDeResellerResponse.class);
            System.debug('Response received V2: ' + respuesta);
        } else {
            respuesta = (dtmAltaDeReseller.dtmAltaDeResellerResponse) JSON.deserialize(response.getBody(), dtmAltaDeReseller.dtmAltaDeResellerResponse.class);
        }
        respuesta.statusCode = response.getStatusCode(); // Asignar el código de estado
        return respuesta;
    }
}