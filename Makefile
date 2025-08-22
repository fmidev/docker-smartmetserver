
build:
	$(MAKE) clean
	docker build . --file Dockerfile --tag fmidev/smartmetserver:latest

test:
	docker run --name test --rm -p 127.0.0.1:8080:8080 fmidev/smartmetserver:latest &> debug.log &
	# Wait for the server to start
	sleep 45s
	# Check if the server is running
	curl -f "http://localhost:8080/wms?request=getCapabilities&service=WMS" || exit 1
	docker stop test

clean:
	-docker image rm -f fmidev/smartmetserver
	-docker image prune -f
	rm -f debug.log

build-rhel10:
	$(MAKE) clean-rhel10
	docker build . --file Dockerfile.rh10 --tag fmidev/smartmetserver-rhel10:latest

test-rhel10:
	docker run --name test10 --rm -p 127.0.0.1:8080:8080 fmidev/smartmetserver-rhel10:latest &> debug10.log &
	# Wait for the server to start
	sleep 45s
	# Check if the server is running
	curl -f "http://localhost:8080/wms?request=getCapabilities&service=WMS" || exit 1
	docker stop test10

clean-rhel10:
	-docker image rm -f fmidev/smartmetserver-rhel10
	-docker image prune -f
	rm -f debug10.log

	docker build -t fmidev/smartmetserver:rhel10 -f Dockerfile.rhel10 .
