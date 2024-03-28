.PHONY: down clean docker

down: docker compose down

clean:
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

docker:
	docker compose up --build -d
	docker attach evilgophish-mk2-evilginx3-1
#docker compose build
#docker compose up gophish
#docker compose run evilginx3