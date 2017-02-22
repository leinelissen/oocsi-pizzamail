import http.requests.*;
import nl.tue.id.oocsi.*;

/**
*  ===================================================
*  Settings
*  ===================================================
*/
String apiUrl = "https://api.mailgun.net/v3/domainname.com/messages";
String apiKey = "";
String replyEmail = "pizzamail-reply@domainname.com";
String oocsiServer = "";
String oocsiChannel = "PizzaMail";

OOCSI oocsi;
PostRequest request;

/**
*  ===================================================
*  Setup Processing
*  ===================================================
*/

void setup()
{
  // Setup processing
  size(100, 100);

  // Setup OOCSI
  OOCSI oocsi = new OOCSI(this, "Lei", oocsiServer);
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

  if(!(event.has("to") && event.has("content") && event.has("subject"))){
    // Check if event contins to, content and subject
    // If that is not the case, return error and exit execution
    System.out.println("Received request is missing parameters");
    sendResponse(event.getSender(), "Your request is missing parameters", false);
    
    return;
  }

  // Send the email
  boolean email = sendEmail(event.getString("to"), event.getString("subject"), event.getString("content"));

  if(!email){
    // Check if the email was succesfully sent
    // If not, log message and send response to client
    System.out.println("Sending email failed! Please check the API response");
    sendResponse(event.getSender(), "An error occured while sending your email. Response: \n"/* + request.getContent()*/, false);
    
    return;
  }
  
  // Log message
  System.out.println("Email successfully sent: {");
  System.out.println("  \"to\": \"" + event.getString("to") + "\"");
  System.out.println("  \"subject\": \"" + event.getString("subject") + "\"");
  System.out.println("  \"content\": \"" + event.getString("content") + "\"");
  System.out.println("} \n");

  // Send response to client
  sendResponse(event.getSender(), "Your email was successfully sent!", true);

}

/**
*  ===================================================
*  Send API request to Mailgun
*  ===================================================
*/
boolean sendEmail(String to, String subject, String content)
{
  // Create new request
  request = new PostRequest(apiUrl);

  // Add data to request
  request.addData("from", replyEmail);
  request.addData("to", to);
  request.addData("subject", subject);
  request.addData("text", content);

  // Authenticate request
  request.addUser("api", apiKey);

  // Send request
  request.send();

  // Log response
  println("Response: " + request.getContent());

  // Return failure or success
  if(request.getContent().contains("\"message\": \"Queued. Thank you.\"")) {
    return true;
  }

  return false;
}

/**
*  ===================================================
*  Send response to OOCSI client
*  ===================================================
*/
void sendResponse(String user, String message, boolean success){
    // Send response to client
    oocsi
      .channel(user)
      .data("message", message)
      .data("success", success)
      .send();
}