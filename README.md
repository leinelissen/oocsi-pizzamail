# oocsi-pizzamail
A mail-sending bot for OOCSI 🍕

## Setting up the bot
To use the interface, open up the Processing file and make sure you set the following settings:

* **oocsiServer**: The OOCSI server you want to listen on
* **oocsiChannel**: The channel you want to be listening on
* **apiUrl**: Your API endpoint for the email request. Use [Mailgun](https://mailgun.com) for this.
* **apiKey**: The corresponding API key for your API endpoint.

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
 .data("from", "oocsi-mail@codified.nl")
 // to address
 .data("to", "lei.nelissen94@gmail.com")
 // email subject
 .data("subject", "FEESTEN")
 // email content
 .data("content", "DINGEN")
 // send the email 🍕
 .send();
```
