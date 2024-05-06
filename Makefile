.PHONY: docker clean-local test-gophish 

SOURCE := egp-mk2
docker:
	@docker build -t $(SOURCE) .
	@docker run --name $(SOURCE) -d -p 80:80 -p 443:443 -p 8080:8080 -p 8443:8443 -p 3333:3333 -p 53:53 $(SOURCE)
	@echo "\t[!] docker logs $(SOURCE) \n\n\tevilginx3:\n\t[1] docker exec -it $(SOURCE) /bin/bash \n\t[2] /opt/evilginx3/run.sh"

clean-docker:
	@docker stop $(SOURCE)
	@docker rm $(SOURCE)

clean-local:
	docker system prune --all
	cd evilfeed && go clean
	cd evilginx3 && go clean
	cd gophish && go clean 
	[ -e gophish/gophish_template.crt ] && rm gophish/gophish_template.crt 
	[ -e gophish/gophish_template.key ] && rm gophish/gophish_template.key
	[ -e gophish/gophish.db ] && rm gophish/gophish.db 
	[ -e *.pem ] && rm *.pem
	echo """Stop your services! \
systemctl restart apache2"""

test-gophish:
# Ascii QR Code Generation ({{.QR}} - HTML only)
	@cd gophish/models && /usr/bin/go test -check.f "ModelsSuite.TestGenQR" -v
	@cd gophish/models && /usr/bin/go test -check.f "ModelsSuite.TestQRTemplateRendering" -v
# Bcc Integration
	@cd gophish/models && /usr/bin/go test -check.f "ModelsSuite.TestPostSMTPValidHeader"