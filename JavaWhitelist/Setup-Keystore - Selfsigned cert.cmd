keytool -genkey -keyalg RSA -alias selfsigned -keystore keystore.jks -storepass changeit -validity 1360 -keysize 2048
keytool -exportcert -keystore keystore.jks -alias selfsigned -file Cert.p12
