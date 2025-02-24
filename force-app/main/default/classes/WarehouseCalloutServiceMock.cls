@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    global static HttpResponse respond(HttpRequest request){
        
        System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());
        // mock response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"_id":"1fhj7hgd726b611100aafssd","replacement":true,"quantity":3,"name":"Generator 6000 kW","maintenanceperiod":37,"lifespan":300,"cost":5000,"sku":"00001"}]');
        response.setStatusCode(200);
        return response;
    }
}