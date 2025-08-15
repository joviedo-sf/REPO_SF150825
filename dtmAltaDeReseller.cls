@SuppressWarnings('PMD.AvoidGlobalModifier')
global class dtmAltaDeReseller {
    global class dtmAltaDeResellerResponse {
        global String codigoRespuesta {get;set;}
        global String mensajeRespuesta {get;set;}
        global List<error> errores {get;set;}
        global Integer resellerId {get;set;}
        global String folioId {get;set;}
        global Integer statusCode {get;set;}
        
        global  Map<String, Object> toMap() {
            Map<String, Object> mapa = new Map<String, Object>();
            mapa.put('codigoRespuesta', codigoRespuesta);
            mapa.put('mensajeRespuesta', mensajeRespuesta);
            mapa.put('resellerId', resellerId);
            mapa.put('folioId', folioId);
            mapa.put('statusCode', statusCode);
            if (errores != null) {
                List<Map<String, Object>> erroresList = new List<Map<String, Object>>();
                for (error e : errores) {
                    erroresList.add(e.toMap());
                }
                mapa.put('errores', erroresList);
            }
            return mapa;
        }
    }
    
    global class error {
        global String error {get;set;}
        
        public Map<String, Object> toMap() {
            Map<String, Object> mapa2 = new Map<String, Object>();
            mapa2.put('error', error);
            return mapa2;
        }
    }
    
    global static dtmAltaDeResellerResponse procesarSolicitud(String entradaDatos) {
        String idAccount = entradaDatos;
        String user = 'test';
        String pass = 'test';
        Integer idSistema = 1;
        
        /*Account cuenta = [SELECT id,Name,Phone,FirstName,MiddleName,LastName,Suffix,dtmEmailCorporativo__c,dtmTelefonoFijo__c FROM Account WHERE id=:idAccount];
        
        String jsonRequest = '{';
        jsonRequest +='"idSistema":"'+idSistema+'",';
        jsonRequest +='"telefono":"'+cuenta.Phone+'",';
        jsonRequest +='"usuario":"'+user+'",';
        jsonRequest +='"password":"'+pass+'",';
        jsonRequest +='"nombre":"'+cuenta.FirstName+' '+cuenta.MiddleName+'",';
        jsonRequest +='"apPaterno":"'+cuenta.MiddleName+'",';
        jsonRequest +='"apMaterno":"'+cuenta.LastName+'",';
        jsonRequest +='"correo":"'+cuenta.dtmEmailCorporativo__c+'",';
        jsonRequest +='"telContacto":"'+cuenta.dtmTelefonoFijo__c+'",';
        jsonRequest +='}';*/
    	String jsonRequest = '{"test":"test"}';
    	dtmAltaDeReseller.dtmAltaDeResellerResponse respuesta = new dtmAltaDeReseller.dtmAltaDeResellerResponse();
        dtmAltaDeReseller.dtmAltaDeResellerResponse responses = dtmAltaDeResellerController.integrarConEndpointExterno(jsonRequest);
    	
    	if (responses.statusCode==200) {
            respuesta.statusCode = responses.statusCode;
            respuesta.codigoRespuesta = responses.codigoRespuesta;
            respuesta.mensajeRespuesta = responses.mensajeRespuesta;
            respuesta.resellerId = responses.resellerId;
            respuesta.folioId = responses.folioId;
            respuesta.statusCode = responses.statusCode;
        } else{
            respuesta.statusCode = responses.statusCode;
            respuesta.codigoRespuesta = responses.codigoRespuesta;
            respuesta.mensajeRespuesta = responses.mensajeRespuesta;
            respuesta.errores = responses.errores;
            dtmAltaDeReseller.guardaErrores(jsonRequest, respuesta);
        }
    
        return respuesta;
    }
    
    public static void guardaErrores(String jsonEntrada,dtmAltaDeReseller.dtmAltaDeResellerResponse respuesta){
        String mensajeError = 'codigoError: '+respuesta.errores +' Mensaje: '+respuesta.mensajeRespuesta;
        Integer codigoEstatus = respuesta.StatusCode;
        vlocity_cmt__VlocityErrorLogEntry__c errorNew = new vlocity_cmt__VlocityErrorLogEntry__c();
        errorNew.vlocity_cmt__Action__c = 'POST';
        errorNew.vlocity_cmt__ErrorCode__c = String.valueOf(codigoEstatus);
        errorNew.vlocity_cmt__ErrorMessage__c = mensajeError;
        errorNew.vlocity_cmt__ErrorTime__c = Datetime.Now();
        errorNew.vlocity_cmt__ErrorType__c = 'Callout Error';
        errorNew.vlocity_cmt__InputData__c = jsonEntrada;
        errorNew.Name = 'Alta de Reseller';
        errorNew.vlocity_cmt__ObjectName__c = 'Quote';
        errorNew.vlocity_cmt__SourceType__c = 'Omniscript';
        Insert errorNew;
        System.debug('Id de registro: '+errorNew.Id); 
    }
}