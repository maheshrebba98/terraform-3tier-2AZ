#! /bin/bash
sudo -i
yum update -y
yum install httpd -y
systemctl start httpd
echo "<html> <body> <h1> WEB TIER SUCCESS </h1>  </body> </html>" > /var/www/html/index.html
