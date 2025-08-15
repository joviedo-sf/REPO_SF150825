@SuppressWarnings('PMD.AvoidGlobalModifier')
global class dtmContratacionGis {
    global class dtmContratacionGisResponse {
        global String userMenssage {get;set;}
        global String severety {get;set;}
        global List<String> errors {get;set;}
        global Integer statusCode {get;set;}
        global Integer id {get;set;}
        
        global Map<String, Object> toMap() {
            Map<String, Object> mapa = new Map<String, Object>();
            mapa.put('userMenssage', userMenssage);
            mapa.put('severety', severety);
            mapa.put('statusCode', statusCode);
            mapa.put('id', id);
            if (errors != null) {
                mapa.put('errors', errors);
            }
            return mapa;
        }
    }
    
    global static dtmContratacionGisResponse procesarSolicitud(String entradaDatos) {
        String idQuote = entradaDatos;
        String movimiento = 'ALTA';
        String direccionamiento = '1 IP Publica'; //duro por ahora
        
        Quote cotizacion = [SELECT Name, dtmFolioNmp__c,dtmMensajeError__c,Account.dtmRFC__c, Account.dtmCuentaMaestra__c, Account.dtmCUCE__c, Opportunity.dtmIdentificadorOpp__c, Opportunity.dtmCUPID__r.Name FROM Quote WHERE Id=:idQuote];
        System.debug('Cotizacion: ' + cotizacion);
        List<QuoteLineItem> productos = [SELECT id, Quantity, dtmNombresitio__c, vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c, dtmCodigoISOMoneda__c, Product2.Id, Product2.Name, Product2.vlocity_cmt__SpecificationType__c, Product2.ProductCode, Product2.dtmEmpresaPrestaServicios__c, Product2.StockKeepingUnit, Product2.dtmProductSkuContratacion__c, Product2.dtmPlataforma__c FROM QuoteLineItem WHERE QuoteId=:idQuote];
        System.debug('productos: ' + productos);
        List<QuoteLineItem> productosHijos = [SELECT id, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c, Quantity, dtmNombresitio__c, Product2.Id, Product2.vlocity_cmt__SpecificationType__c, Product2.ProductCode,Product2.Name, Product2.StockKeepingUnit, Product2.dtmProductSkuContratacion__c, Product2.dtmPlataforma__c FROM QuoteLineItem WHERE QuoteId=:idQuote AND Product2.vlocity_cmt__SpecificationType__c = 'Product'];
        System.debug('productosHijos: ' + productosHijos);
        
        String jsonRequest = '{';
        jsonRequest += '"idCotizacionSf":"' + cotizacion.Id + '",';
        jsonRequest += '"rfcClienteFinal":"' + cotizacion.Account.dtmRFC__c + '",';
        jsonRequest += '"oportunidad":"' + cotizacion.Opportunity.dtmIdentificadorOpp__c + '",';
        jsonRequest += '"cuce":"' + cotizacion.Account.dtmCUCE__c + '",';
        jsonRequest += '"cupId":' + Integer.valueOf(cotizacion.Opportunity.dtmCUPID__r.Name) + ',';
        jsonRequest += '"cuentaMaestra":"' + cotizacion.Account.dtmCuentaMaestra__c + '",';
        jsonRequest += '"productos": [';
        
        List<String> productosJsonList = new List<String>();
        
        for (Integer i = 0; i < productos.size(); i++) {
            QuoteLineItem item = productos[i];
            if (item.Product2.vlocity_cmt__SpecificationType__c == 'Offer') {
                String productoJson = '{';
                productoJson += '"productId": "' + item.Product2.Id + '",';
                productoJson += '"empresa": "' + item.Product2.dtmEmpresaPrestaServicios__c + '",';
                productoJson += '"movimiento": "' + movimiento + '",';
                productoJson += '"plataforma": "' + item.Product2.dtmPlataforma__c + '",';
                productoJson += '"producto": "' + item.Product2.Name + '",';
                if (item.Product2.Name == 'Internet Directo Negocio') {
                 	String[] sitioss = item.dtmNombresitio__c.split(' ');
                    Integer sitio = Integer.valueOf(sitioss[0]);
                productoJson += '"sitio": ' + sitio + ',';
                }else{
                    productoJson += '"sitio": null,';
                }
                productoJson += '"plazo": ' + 12 + ',';
                productoJson += '"cantidad": ' + item.Quantity + ',';
                productoJson += '"tipoMoneda": "' + item.dtmCodigoISOMoneda__c + '",';
                productoJson += '"anchoBanda": ' + 0 + ','; //IDN
                
                if (item.Product2.Name == 'Internet Directo Negocio') {
                    productoJson += '"direccionamiento": "' + direccionamiento + '",';
                } else {
                    productoJson += '"direccionamiento": null,';
                }
                productoJson += '"skus":[';
                List<String> skusJsonList = new List<String>();
                for (Integer j = 0; j < productosHijos.size(); j++) {
                    QuoteLineItem item2 = productosHijos[j];
                    String skuJson = '{';
                    if (item.Product2.Name == 'Internet Directo Negocio') {
                        String[] skuTipos = item2.Product2.Name.split(' ');
                        String skuTipo = skuTipos[0];
                        skuJson += '"skuTipo":"' + skuTipo + '",';
                    } else {
                        skuJson += '"skuTipo":null,';
                    }
                    skuJson += '"skuRenta":"' + item2.Product2.StockKeepingUnit + '",';
                    skuJson += '"precioRenta":' + item2.vlocity_cmt__RecurringCharge__c + ',';
                    skuJson += '"skuContratacion":"' + item2.Product2.dtmProductSkuContratacion__c + '",';
                    skuJson += '"precioContratacion":' + item2.vlocity_cmt__OneTimeCharge__c + ',';
                    if (item.Product2.Name != 'Internet Directo Negocio') {
                        String[] sitioss = item2.dtmNombresitio__c.split(' ');
                        String sitio = sitioss[0];
                        productoJson += '"sitio": ' + sitio + ',';
                    }else{
                        productoJson += '"sitio": null,';
                    }
                    skuJson += '"cantidad":' + item2.Quantity;
                    skuJson += '}';
                    
                    skusJsonList.add(skuJson);
                }
                
                productoJson += String.join(skusJsonList, ',');
                productoJson += ']}';
                productosJsonList.add(productoJson);
            }
        }
        
        jsonRequest += String.join(productosJsonList, ',');
        jsonRequest += ']}';
        
        System.debug('El request a enviar es:' + jsonRequest);
        
        dtmContratacionGis.dtmContratacionGisResponse respuesta = new dtmContratacionGis.dtmContratacionGisResponse();
        dtmContratacionGis.dtmContratacionGisResponse responses = dtmContratacionGisController.integrarConEndpointExterno(jsonRequest);
        
        if (responses.statusCode==200) {
            respuesta.statusCode = responses.statusCode;
            respuesta.id = responses.id;
            cotizacion.dtmFolioGis__c = String.valueOf(responses.id);
            update cotizacion;
        } else{
            respuesta.statusCode = responses.statusCode;
            respuesta.userMenssage = responses.userMenssage;
            respuesta.severety = responses.severety;
            respuesta.errors = responses.errors;
            dtmContratacionGis.guardaErrores(jsonRequest, respuesta);
            cotizacion.dtmMensajeError__c = responses.userMenssage;
            update cotizacion;
        }
        System.debug('Se envia respuesta: '+respuesta);
        return respuesta;
    }
    public static void guardaErrores(String jsonEntrada,dtmContratacionGis.dtmContratacionGisResponse respuesta){
        String mensajeError = 'codigoError: '+respuesta.severety +' Mensaje: '+respuesta.userMenssage;
        Integer codigoEstatus = respuesta.StatusCode;
        vlocity_cmt__VlocityErrorLogEntry__c errorNew = new vlocity_cmt__VlocityErrorLogEntry__c();
        errorNew.vlocity_cmt__Action__c = 'POST';
        errorNew.vlocity_cmt__ErrorCode__c = String.valueOf(codigoEstatus);
        errorNew.vlocity_cmt__ErrorMessage__c = mensajeError;
        errorNew.vlocity_cmt__ErrorTime__c = Datetime.Now();
        errorNew.vlocity_cmt__ErrorType__c = 'Callout Error';
        errorNew.vlocity_cmt__InputData__c = jsonEntrada;
        errorNew.Name = 'Contratacion GIS';
        errorNew.vlocity_cmt__ObjectName__c = 'Quote';
        errorNew.vlocity_cmt__SourceType__c = 'Omniscript';
        Insert errorNew;
        System.debug('Id de registro: '+errorNew.Id); 
    }
}