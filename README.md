# oocsi-pizzamail
A mail-sending bot for OOCSI 🍕

## Setting up the bot
To use the interface, open up the Processing file and make sure you set the following settings:

* **oocsiServer**: The OOCSI server you want to listen on
* **oocsiChannel**: The channel you want to be listening on
* **apiUrl**: Your API endpoint for the email request. Use [Mailgun](https://mailgun.com) for this.
* **apiKey**: The corresponding API key for your API endpoint.

Also make sure you have installed the [OOCSI-processing](https://github.com/iddi/oocsi-processing) package and the [HTTP Requests for Processing](https://github.com/runemadsen/HTTP-Requests-for-Processing) package, or else Processing will nag you with vague errors.

Once you have done so, the interface will listen for events on the specified channel. Once an event is received, it will check the incoming data. If all parameters are present, a request is passed to the Mailgun server, and the email will be sent.

## Sending an email
You need to specify three parameters in order to send an email:
* **to**: The email address you will be sending the email to
* **subject**: The subject of the email
* **content**: The content of the email

If your data is correct and a PizzaMail bot is listening, your email will be sent!

### Example code
```java
import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

void setup()
{
  // Setup processing
  size(100, 100);

  // Setup OOCSI
  OOCSI oocsi = new OOCSI(this, "Harry", "oocsi.id.tue.nl");

  // Subscribe to your own channel, so you will be able to receive replies to emails you sent
  oocsi.subscribe("Harry", "eventHandler");

  // Start sending an OOCSI call
  OOCSICall call = oocsi
    // We call the PizzaMail handler with a 10s timeout
    .call("PizzaMail", 10000)
    // We send an email to someone
    .data("to", "do-not-reply@definitelynotspam.com")
    // With a certain subject
    .data("subject", "Party at my house!")
    // And some email content
    .data("content", "Free pizza and beer. Everyone is invited.");

  // We send the call and wait for a response
  call.sendAndWait();

  // When a new response is received
  if(call.hasResponse()){
    // Read the new response
    OOCSIEvent response = call.getFirstResponse();
    println("Response received!");

    // Check if the email was successfully sent
    if(response.getBoolean("success", false) == true){
      println("The email was sent!");
    }
  } else {
    // If no response is received, there probably is not PizzaMail bot active
    println("Sending email timed out...");
  }
}

// Here we listen for replies to emails we have sent
void eventHandler(OOCSIEvent event){
    // Output any replies we have received from the PizzaMail server!
    System.out.println("Received a new message from PizzaMail:");
    System.out.println("Message: " + event.getString("message"));
    System.out.println("Success: " + event.getString("success"));
    System.out.println("Status: " + event.getString("status"));
    System.out.println("Id: " + event.getString("id"));
    System.out.println("Reply: " + event.getString("reply") + "\n");
}
```

### Responses
Whenever sending an email, PizzaMail will let you know if your message has been sent successfully. It does this by giving a response to your call. You can listen to this response by following the example code. PizzaMail will then send some variables:
* **message**: a string containing whatever PizzaMail wants to tell you
* **success**: a boolean, telling you if an action has succeeded.
* **status**: a short status code detailing what is happening
    * *"missing-parameters"*: You did not supply the correct parameters for sending an email
    * *"error-while-sending"*: Something went wrong while passing your email off to Mailgun.
    * *"sent"*: Your email has been sent!
* **id**: a tracking ID for the email you have just sent *[only included with "sent" status]*

#### For example
```
Message: Your email was successfully sent!
Success: true
Status: sent
Id: <20170305174111.121094.66148.F958E694@your-email-domain.com>
```

## Email replies
If properly set up, PizzaMail will also handle incoming emails too! Whenever you send an email to someone, PizzaMail will respond to you with a tracking ID. When the email you sent is replied to, PizzaMail will relay this message back to you using OOCSI. It will send a message to a channel with your name, containing the message and the tracking ID you received. These replies will containt the following data:

* **message**: a string containing whatever PizzaMail wants to tell you
* **status**: a short status code detailing what is happening
    * *"reply"*: You have received a new reply to an email you have sent
* **id**: a tracking ID for the email that you have received a reply to
* **reply**: the contents of the email

#### For example
```
Message: You received a reply to your email.
Status: reply
Id: <20170305174111.121094.66148.F958E694@your-email-domain.com>
Reply: We are out of pepperoni unfortunately 😰
```
