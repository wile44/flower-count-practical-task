docker builder prune -a      
docker build -t mybackend .    
docker run -d --name mycontainer -p 80:80 mybackend
