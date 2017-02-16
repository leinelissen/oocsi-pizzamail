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
You need to specify four parameters in order to send an email:
* **from**: The email address the email will originate from
* **to**: The email address you will be sending the email to
* **subject**: The subject of the email
* **content**: The content of the email

If your data is correct and a PizzaMail bot is listening, your email will be sent!

### Example code
```java
oocsi
.channel("PizzaMail")
 // from address
 .data("from", "do-not-reply@definitelynotspam.com")
 // to address
 .data("to", "example@email.com")
 // email subject
 .data("subject", "Party at my house!")
 // email content
 .data("content", "Free pizza and beer. Everyone is invited.")
 // send the email 🍕
 .send();
```
