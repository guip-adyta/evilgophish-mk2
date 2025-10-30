.PHONY: all clean 

SOURCE := egp-mk4
all:
	@docker build -t $(SOURCE) .
	@docker run --name $(SOURCE) -d -p 80:80 -p 443:443 -p 8080:8080 -p 8443:8443 -p 3333:3333 -p 53:53 $(SOURCE)
	@echo "\t[!] docker logs $(SOURCE) \n\n\tevilginx3:\n\t[1] docker exec -it $(SOURCE) /bin/bash \n\t[2] /opt/evilginx3/run.sh"

clean:
	@docker stop $(SOURCE)
	@docker rm $(SOURCE)