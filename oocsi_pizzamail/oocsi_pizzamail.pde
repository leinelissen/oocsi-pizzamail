import http.requests.*;
import nl.tue.id.oocsi.*;

// Settings
String apiUrl = "https://api.mailgun.net/v3/domainname.com/messages";
String apiKey = "";
String defaultFrom = "oocsi-mail@codified.nl";
String oocsiServer = "oocsi.id.tue.nl";
String oocsiChannel = "PizzaMail";

void setup()
{
  // Setup processing
  size(100, 100);
  
  // Setup OOCSI
  OOCSI oocsi = new OOCSI(this, "PizzaMail", oocsiServer);
  oocsi.subscribe(oocsiChannel, "eventHandler");
  println('\n');
}

/**
*  ===================================================
*  Handle incoming email request from OOCSI
*  ===================================================
*/
void eventHandler(OOCSIEvent event)
{
  // Notify
  System.out.println("Received new event from: " + event.getRecipient());
  
  // Validate data
  if(!(event.has("from") && event.has("to") && event.has("content") && event.has("subject"))){
    System.out.println("Received request is missing parameters");
    return;
  }
  
  // Send email
  boolean email = sendEmail(event.getString("to"), event.getString("subject"), event.getString("content"), event.getString("from"));
  System.out.println("Email successfully sent!");
  System.out.println("\n");
 
}

/**
*  ===================================================
*  Send API request to Mailgun
*  ===================================================
*/
boolean sendEmail(String to, String subject, String content, String from)
{
  // Create new request
  PostRequest request = new PostRequest(apiUrl);
  
  // Add data to request
  request.addData("from", (from == null) ? defaultFrom : from);
  request.addData("to", to);
  request.addData("subject", subject);
  request.addData("text", content);
  
  // Authenticate request
  request.addUser("api", apiKey);
  
  // Send request
  request.send();
  
  // Log response
  println("Response: " + request.getContent());
  
  return true;
}