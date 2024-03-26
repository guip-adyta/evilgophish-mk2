.PHONY: clean docker

clean:
	cd evilfeed && go clean
	cd evilginx3 && go clean
	cd gophish && go clean 
	[ -e gophish/gophish_template.crt ] && rm gophish/gophish_template.crt 
	[ -e gophish/gophish_template.key ] && rm gophish/gophish_template.key
	[ -e gophish/gophish.db ] && rm gophish/gophish.db 
	[ -e *.pem ] && rm *.pem
	echo """Stop your services! \
systemctl restart apache2"""

docker:
	docker compose build
	docker compose up gophish
	docker compose run evilginx3