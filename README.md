# ft_server

Codam [42 Network] project: set up a web server in a single docker container

### Instructions
- start docker
- build docker image `docker build -t ft_server .`
- create docker container `docker run --name ft_server -it -p 80:80 -p 443:443 ft_server`
- access wordpress site at `localhost`
- access phpmyadmin at `localhost/phpmyadmin/` and login with `phpmyadmin_user` | `password`
- NOTE - to reclaim space on your computer when done use the command `docker system prune -a`
<br/><br/>

### General information
- Docker is a computer program that performs operating-system-level virtualization, also known as “containerization”
- nginx is a web server that is used to serve your content
- mysql is a database that stores and manages your data
- phpmyadmin processes code and generates dynamic content for the web server 
<br/><br/>

### Skills
- Network & system administration
<br/><br/>

### Objectives
- System administration
<br/><br/>

![Winter](https://github.com/subsp4ce/pics/blob/master/pexels-michiel-alleman-1559117.jpg "Winter")
