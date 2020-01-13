# Ecowitt Temperature/Gateway Sensor - Automation
This script can be used to query the https://ecowitt.net website that stores Sensor data for a range of devices.  

Specifically in my use case, I have 2 sensors.  One in separate Freezers that will alert me if temperates go above a certain threshold.  For some reason Ecowiitt can't alert on low battery or lost of WIFI in their sensors.
This script will address those two concers, along with watever other possible scenarios you can come up with.

I'm using this in tandem with 'Azure Automation', which is free as long as you stay under 500 minute consumption a month.

This script is set to run every hour.  The sensors are set to upload their data every 5 minutes to https://Ecowitt.net.
If for some reason the sensor data doesn't get uploaded within 60 minutes (can be adjusted), an email function is called.  I have create a separate Azure Automation runbook for that email function, which I call in this script.  It uses an Office 365 email account to email (phone number)@vtext.com.  This will send whatever phone number you want a text, instead of email.

I've added two 'Credentials' into Azure Automation Credential Vault. 1) Office 365 Email account. 2) Ecowitt login.  The Azure Automation script will call these credentials to obtain access it requires.
