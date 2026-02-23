
build:
	docker build . --no-cache --file Dockerfile --tag fmidev/smartmetserver:latest --no-cache

test:
	docker rm -f test 2>/dev/null || true
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
	docker build . --no-cache --file Dockerfile.rhel10 --tag fmidev/smartmetserver-rhel10:latest --no-cache

test-rhel10:
	docker rm -f test10 2>/dev/null || true
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
