import http.requests.*;
import nl.tue.id.oocsi.*;
import java.util.Map;

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
HashMap<String, String> sentEmails;
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
    oocsi = new OOCSI(this, "PizzaMail", oocsiServer);
    oocsi.register(oocsiChannel, "eventHandler");
    println('\n');

    // Initialise list of sent emails
    sentEmails = new HashMap<String, String>();

    // Set framerate
    frameRate(1);

    // Check respones
    checkResponses();
}

/**
*  ===================================================
*  Main Loop
*  ===================================================
*/

void draw()
{
    // Check if responses to emails have been received every 60 seconds
    if(frameCount % 60 == 0) {
        thread("checkResponses");
    }
}

/**
*  ===================================================
*  Handle incoming email request from OOCSI
*  ===================================================
*/
void eventHandler(OOCSIEvent event, OOCSIData response)
{
    // Notify
    log("Received new event from: " + event.getSender());

    if(!(event.has("to") && event.has("content") && event.has("subject"))) {
        // Check if event contains to, content and subject
        // If that is not the case, return error and exit execution
        log("Received request is missing parameters");
        response.data("message", "Your request is missing parameters")
          .data("success", false)
          .data("status", "missing-parameters");

        return;
    }

    // Send the email
    boolean email = sendEmail(event.getString("to"), event.getString("subject"), event.getString("content"));
    JSONObject json = parseJSONObject(request.getContent());

    if(!email) {
        // Check if the email was succesfully sent
        // If not, log message and send response to client including error message
        log("Sending email failed! Please check the API response");
        response.data("message", "An error occured while sending your email Response: \n" + request.getContent())
          .data("success", false)
          .data("status", "error-while-sending");
        return;
    }

    // Register the email with the user id
    registerEmail(event.getSender(), json.getString("id"));

    // Send response to client
    response.data("message", "Your email was successfully sent!")
      .data("success", true)
      .data("status", "sent")
      .data("id", json.getString("id"));
}

/**
*  ===================================================
*  Send API request to Mailgun
*  ===================================================
*/
boolean sendEmail(String to, String subject, String content)
{
    // Create new request
    request = new PostRequest(apiUrl + "messages");

    // Add data to request
    request.addData("from", replyEmail);
    request.addData("to", to);
    request.addData("subject", subject);
    request.addData("text", content);

    // Authenticate request
    request.addUser("api", apiKey);

    // Send request
    request.send();

    // Return failure or success
    if(!request.getContent().contains("\"message\": \"Queued. Thank you.\"")) {
        return false;
    }

    // Log message
    log("Email successfully sent to: " + to);

    return true;
}

/**
*  ===================================================
*  Register sent email with OOCSI user id
*  ===================================================
*/
void registerEmail(String user, String id)
{
    log("Registered email id '" + id + "' with user '" + user + "' \n");
    sentEmails.put(id, user);
}

/**
*  ===================================================
*  Send response to OOCSI client
*  ===================================================
*/
void sendResponse(String user, String message, String status, String id, String reply)
{
    oocsi
        .channel(user)
        .data("message", message)
        .data("success", success)
        .data("id", id)
        .data("reply", reply)
        .send();
}

/**
*  ===================================================
*  Check if there are newly received returned emails
*  ===================================================
*/
void checkResponses()
{
    // Log the initiation
    log("Checking if there are new replies to sent emails...");

    // Instantiate request
    GetRequest request = new GetRequest(apiUrl + "events?event=stored");

    // Authenticate request
    request.addUser("api", apiKey);

    // Send request
    request.send();

    // Parse response
    JSONObject json = parseJSONObject(request.getContent());
    JSONArray items = json.getJSONArray("items");

    // Loop through responses and return emails
    for(int i = 0; i < items.size(); i++) {
        // Retrieve individual message from JSON array
        JSONObject message = items.getJSONObject(i);
        JSONObject storage = message.getJSONObject("storage");

        // Retrieve message from API
        GetRequest messageRequest = new GetRequest(storage.getString("url"));
        messageRequest.addUser("api", apiKey);
        messageRequest.send();

        // Parse response
        JSONObject response = parseJSONObject(messageRequest.getContent());

        // Match email against stored email ids
        String origin = sentEmails.get(response.getString("In-Reply-To"));
        if(origin != null) {
            // If it exists, pass message back to OOCSI user
            sendResponse(origin, "You received a reply to your email.", "reply", response.getString("In-Reply-To"), response.getString("stripped-text"));

            // Log action
            log("Relayed a message with id " + response.getString("In-Reply-To") + " back to user " + origin);

            // Remove email from list
            sentEmails.remove(response.getString("In-Reply-To"));
        }
    }

    // Log completion
    log("Successfully completed checking for new replies to sent emails. \n");
}

/**
*  ===================================================
*  Custom log function prepending timestamps
*  ===================================================
*/

void log(String message)
{
    // Output a timestamp first
    // NOTE: The weird String format thingy is to make sure our numbers have leading zeroes
    System.out.print("[" + String.format("%02d", hour()) + ":" + String.format("%02d", minute()) + ":" + String.format("%02d", second()) + "] ");

    // Output the actual message
    System.out.println(message);
}
