import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.impl.client.DefaultHttpClient;

class Light {

  String l;

  Light(String _lighturl) {
    l = _lighturl;
  }

  void send (String command) {                                          // sends JSON commands via PUT request
    try
    {
      HttpPut httpPut = new HttpPut( l );                               // set HTTP put address to light being accessed
      DefaultHttpClient httpClient = new DefaultHttpClient();

      httpPut.addHeader("Accept", "application/json");                  // tell everyone we are talking JSON
      httpPut.addHeader("Content-Type", "application/json");

      StringEntity entity = new StringEntity(command, "UTF-8");         // pull in the command set already in JSON
      entity.setContentType("application/json");
      httpPut.setEntity(entity); 

      HttpResponse response = httpClient.execute( httpPut );            // check to make sure it went well
      println( response.getStatusLine());

      //      httpClient.getConnectionManager().shutdown();
    } 
    catch( Exception e ) { 
      e.printStackTrace();
    }
  }


  boolean on() {                                                        // check if light is on
    boolean status = false;
    String response = loadStrings( l.substring(0, xx) )[0];             // !! Edit the substring number depending on your IP length (we want to remove /state)
    //    println(response);
    if ( response != null ) {
      // Initialize the JSONObject for the response
      JSONObject root = new JSONObject( response );

      // Get the "state" JSONObject
      JSONObject condition = root.getJSONObject("state");

      // Get the "on/off" value from the state object
      Boolean sat = condition.getBoolean("on");

      // Print the status
      //      println( sat );

      if (sat == true) {
        status = true;
      }
      else {
        status = false;
      }
    }
    return status;
  }

  
  }
    

