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

void setup()
{
  // Setup processing
  size(100, 100);

  // Setup OOCSI
  OOCSI oocsi = new OOCSI(this, "Your-name", "oocsi.id.tue.nl");

  // Subscribe to your own channel, so you will be able to receive responses by the PizzaMail server
  oocsi.subscribe("Your-name", "eventHandler");

  // Start sending an OOCSI message
  oocsi
    // We listen to the PizzaMail channel
    .channel("PizzaMail")
    // To whom do you want to send an email?
    .data("to", "lei.nelissen94@gmail.com")
    // What is the subject of your email?
    .data("subject", "Party at my house!")
    // What is the content of your email?
    .data("content", "Free pizza and beer. Everyone is invited.")
    // Send the email! 🍕
    .send();
}

void eventHandler(OOCSIEvent event){
    // Output any response received from the PizzaMail server
    System.out.println("Received a new message from PizzaMail:");
    System.out.println("Message: " + event.getString("message"));
    System.out.println("Success: " + event.getString("success"));
    System.out.println("Status: " + event.getString("status"));
    System.out.println("Id: " + event.getString("id"));
    System.out.println("Reply: " + event.getString("reply") + "\n");
}
```

### Responses
Whenever sending an email, PizzaMail will let you know if your message has been sent successfully. It does this by sending a message to your own channel. You can listen for these messages by subscribing to the channel with your own name. PizzaMail will then send some variables:
* **message**: a string containing whatever PizzaMail wants to tell you
* **success**: a boolean, telling you if an action has succeeded.
* **status**: a short status code detailing what is happening
    * *"missing-parameters"*: You did not supply the correct parameters for sending an email
    * *"error-while-sending"*: Something went wrong while passing your email off to Mailgun.
    * *"sent"*: Your email has been sent!
    * *"reply"*: A reply was received to an email you have previously sent
* **id**: a tracking ID for an email you have sent or a reply you have received. *[only included with "sent" and "reply" status]*
* **reply**: the contents of an email reply you have received. *[only included with "reply" status]*

#### For example
```
Message: Your email was successfully sent!
Success: true
Status: sent
Id: <20170305174111.121094.66148.F958E694@your-email-domain.com>
```

## Email replies
If properly set up, PizzaMail will also handle incoming emails too! Whenever you send an email to someone, PizzaMail will return a tracking ID to you. When the email you sent is replied to, PizzaMail will relay this message back to you using OOCSI. All you need to do is listen for PizzaMail responses as indicated above!

#### For example
```
Message: You received a reply to your email.
Success: true
Status: reply
Id: <20170305174111.121094.66148.F958E694@your-email-domain.com>
Reply: We are out of pepperoni unfortunately 😰
```
