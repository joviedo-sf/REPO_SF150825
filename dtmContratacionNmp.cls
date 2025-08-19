// Implement this interface method   rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr  XXXX  1

@SuppressWarnings('PMD.AvoidGlobalModifier')
global class dtmContratacionNmp {
    global class dtmContratacionNmpResponse {
        global String codigo {get;set;}
        global String folio {get;set;}
        global String mensajeError {get;set;}
        global Integer statusCode {get;set;}
        
        global Map<String, Object> toMap() {
            Map<String, Object> mapa = new Map<String, Object>();
            mapa.put('codigo', codigo);
            mapa.put('folio', folio);
            mapa.put('statusCode', statusCode);
            mapa.put('mensajeError', mensajeError);
            return mapa;
    }
}
    global static dtmContratacionNmpResponse procesarSolicitud(String entradaDatos) {
        String idQuote = entradaDatos;
        String producto = '';
        String numParticipante = '';
        Quote cotizacion = [SELECT dtmFolioNmp__c,dtmMensajeError__c FROM Quote WHERE Id=:idQuote];
        /*Quote cotizacion = [SELECT Account.FirstName,Account.LastName,Account.dtmTelefonoFijo__c,Account.dtmEmailCorporativo__c FROM Quote WHERE Id=:idQuote];
        List<QuoteLineItem> productos = [SELECT id,Quantity,vlocity_cmt__AttributeSelectedValues__c,Product2.Id,Product2.Name,Product2.vlocity_cmt__SpecificationType__c,Product2.ProductCode FROM QuoteLineItem WHERE QuoteId=:idQuote];
        for (Integer i = 0; i < productos.size(); i++) {
            QuoteLineItem item2 = productos[i];
            if(item2.Product2.vlocity_cmt__SpecificationType__c == 'Product'){
                producto = item2.Product2.ProductCode;
                numParticipante = item2.Product2.Name;
            }
        }
        String[] partes = numParticipante.split(' ');
        String numParticipantes = partes[1];/*
        /*String jsonRequest ='{';
        jsonRequest +='"telefono":"'+cotizacion.Account.dtmTelefonoFijo__c+'",';
        jsonRequest +='"producto":"'+producto+'",';
        jsonRequest += '"parametros": [';
        jsonRequest += '{';
        jsonRequest +='"nombreDato":"nombre",';
        jsonRequest +='"valorDato":"'+cotizacion.Account.FirstName+'",';
        jsonRequest += '},';
        jsonRequest += '{';
        jsonRequest +='"nombreDato":"apellidos",';
        jsonRequest +='"valorDato":"'+cotizacion.Account.LastName+'",';
        jsonRequest += '},';
        jsonRequest += '{';
        jsonRequest +='"nombreDato":"correo",';
        jsonRequest +='"valorDato":"'+cotizacion.Account.dtmEmailCorporativo__c+'",';
        jsonRequest += '},';
        jsonRequest += '{';
        jsonRequest +='"nombreDato":"numParticipantes",';
        jsonRequest +='"valorDato":"'+numParticipantes+'",';
        jsonRequest += '}';
        jsonRequest += ']';
        jsonRequest +='}';*/
        
        String jsonRequest = '{ "telefono" : "5555550010", "producto" : "VDC01", "datosAdicionales" : [ { "nombreDato" : "nombre", "valorDato" : "Cruz Ricardo" }, { "nombreDato" : "apellidos", "valorDato" : "5528037652" }, { "nombreDato" : "correo", "valorDato" : "cruz@gmail.com" }, { "nombreDato" : "numParticipantes", "valorDato" : "10" } ] }';
        
        System.debug('El request a enviar es:'+jsonRequest);
        dtmContratacionNmp.dtmContratacionNmpResponse respuesta = new dtmContratacionNmp.dtmContratacionNmpResponse();
        dtmContratacionNmp.dtmContratacionNmpResponse responses = dtmContratacionNmpController.integrarConEndpointExterno(jsonRequest);
        String mensajeErr = '';
        if (responses.statusCode==200) {
            respuesta.statusCode = responses.statusCode;
            respuesta.codigo = responses.codigo;
            respuesta.folio = responses.folio;
            cotizacion.dtmFolioNmp__c = responses.folio;
            update cotizacion;
        } else{
            respuesta.statusCode = responses.statusCode;
            respuesta.codigo = responses.codigo;
            respuesta.folio = responses.folio;
            switch on responses.codigo{
                When '001'{
                    mensajeErr = 'ERROR EN CONTRATACIÓN';
                }
                When '002'{
                    mensajeErr = 'PALABRAS RESERVADAS';
                }
                When '003'{
                    mensajeErr = 'CAMPOS OBLIGATORIOS VACIOS';
                }
                When '004'{
                    mensajeErr = 'IP NO AUTORIZADA PARA CONSUMO';
                }
                When '005'{
                    mensajeErr = 'TOKEN INVALIDO';
                }
                When '707'{
                    mensajeErr = 'SIN RESPUESTA DE LA CONTRATACIÓN';
                }
                When '706'{
                    mensajeErr = 'DATOS DE ENTRADA AL SERVICIO SON VACÍOS';
                }
                When '713'{
                    mensajeErr = 'PRODUCTO NO VÁLIDO';
                }
                When '700'{
                    mensajeErr = 'ERROR GENÉRICO DEL APLICATIVO';
                }
            }
            respuesta.mensajeError = mensajeErr;
            dtmContratacionNmp.guardaErrores(jsonRequest, respuesta);
            cotizacion.dtmMensajeError__c = mensajeErr;
            update cotizacion;
        }
        return respuesta;
    }
    
    public static void guardaErrores(String jsonEntrada,dtmContratacionNmp.dtmContratacionNmpResponse respuesta){
        String mensajeError = 'codigoError: '+respuesta.codigo+' mensajeError: '+respuesta.mensajeError;
        Integer codigoEstatus = respuesta.StatusCode;
        vlocity_cmt__VlocityErrorLogEntry__c errorNew = new vlocity_cmt__VlocityErrorLogEntry__c();
        errorNew.vlocity_cmt__Action__c = 'POST';
        errorNew.vlocity_cmt__ErrorCode__c = String.valueOf(codigoEstatus);
        errorNew.vlocity_cmt__ErrorMessage__c = respuesta.mensajeError;
        errorNew.vlocity_cmt__ErrorTime__c = Datetime.Now();
        errorNew.vlocity_cmt__ErrorType__c = 'Callout Error: '+respuesta.codigo;
        errorNew.vlocity_cmt__InputData__c = jsonEntrada;
        errorNew.Name = 'Contratacion NMP';
        errorNew.vlocity_cmt__ObjectName__c = 'Quote';
        errorNew.vlocity_cmt__SourceType__c = 'Omniscript';
        Insert errorNew;
        System.debug('Id de registro: '+errorNew.Id); 
    }
}
