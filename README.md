# EnphasePS
A function to query a local Enphase controller for basic stats

If you have not changed the password to your controller use the SerialNumber, otherwise use CustomPassword. It's up to you to figure out the IP address of your local controller and/or configure a DNS entry for it. The serial number can be found simply by accessing the web console `http://<controller>` and I highly recommend changing the defaul password :smile: and the username is always `envoy`

## EXAMPLE (Default Password)
   Get-SolarStatus -Controller "http://192.168.1.207" -SerialNumber 1234567890
## EXAMPLE (PSCredential)
   Get-SolarStatus -Controller "http://enphase.local" -Credentials (Get-Credential)
## EXAMPLE (Plain Text Password)
   Get-SolarStatus -Controller "http://enphase.local" -CustomPassword 'MyCustomPassword'
   
## Output
```
Name                           Value
----                           -----
Consumption                    3,207
Production                     4,242
Net Usage                      -1,035
```

# ClaymoreMiner
I took the lessons learned from the EnphasePS script and wrote a script that will run Claymore's Ethereum mining software only while I'm generating excess power by keeping a moving average over the last minute. :smile:

`"psw": "<redacted>"` is the -mpsw password in the Claymore config, you should totally set this...and then update the script in both places

`$TCPConnection = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 3333)` this is a connection to local host on the default port. You should totally change that port :smile: with `-mport 127.0.0.1:port`

`$SecPassword = ConvertTo-SecureString ('<redacted>') -AsPlainText -Force` I'm going to assume you've changed your controller password here...

`"http://enphase.local/production.json"` replace this with either an IP or a local DNS name

`if (($Global:NetPowerAverage -lt -250) -and !$Running) {` I have two GPUs and they consume roughly 250 watts when mining vs being idle so for me 250 is close enough
