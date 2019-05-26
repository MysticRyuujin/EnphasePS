# EnphasePS
A function to query a local Enphase controller for basic stats

If you have not changed the password to your controller use the SerialNumber, otherwise use CustomPassword. It's up to you to figure out the IP address of your local controller and/or configure a DNS entry for it. The serial number can be found simply by accessing the web console `http://<controller>` and I highly recommend chaning the defaul password :smile:

## EXAMPLE (Default Password)
   Get-SolarStatus -Controller "http://192.168.1.207" -SerialNumber 1234567890
## EXAMPLE (Plain Text Password)
   Get-SolarStatus -Controller "http://enphase.local" -CustomPassword 'MyCustomPassword'
## EXAMPLE (PSCredential)
   Get-SolarStatus -Controller "http://enphase.local" -Credentials (Get-Credential)
   
## Output
```
Name                           Value
----                           -----
Consumption                    3,207
Production                     4,242
Net Usage                      -1,035
```
