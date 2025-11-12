# Coding Agent Instructions for docker-smartmetserver

## Repository Purpose

This repository builds a Docker image for **SmartMet Server**, a high-capacity, high-availability data and product server for MetOcean data developed and maintained by the Finnish Meteorological Institute (FMI).

The SmartMet Server is written in C++ and has been in operational use since 2008. It provides data services for weather forecasting, climate data, and various meteorological products.

## Key Components

### Docker Image
- **Base Image**: Rocky Linux 9
- **Main Purpose**: Package and distribute SmartMet Server and its dependencies as a containerized application
- **Registry**: Images are published to `fmidev/smartmetserver` on Docker Hub
- **Exposed Port**: 8080 (SmartMet Server HTTP interface)

### SmartMet Server Features
The server provides:
- **Input formats**: GRIB (1 and 2), NetCDF, SQL databases
- **Output interfaces**: WMS 1.3.0, WFS 2.0, and custom APIs
- **Output formats**: JSON, XML, ASCII, HTML, SERIAL, GRIB1, GRIB2, NetCDF, raster images
- **Compliance**: INSPIRE compliant

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── docker-image.yml       # CI/CD pipeline for building and testing the Docker image
├── smartmetconf/                  # SmartMet Server configuration files
│   ├── engines/                   # Engine-specific configurations
│   ├── plugins/                   # Plugin-specific configurations
│   └── smartmet.conf             # Main server configuration
├── wms/                          # WMS (Web Map Service) resources
│   ├── customers/                # Customer-specific WMS configurations
│   ├── legends/                  # Map legend files
│   └── resources/                # WMS resource files (styles, layers, etc.)
├── Dockerfile                    # Docker image definition
├── docker-compose.yml            # Docker Compose configuration for local development
├── docker-entrypoint.sh          # Container entry point script
├── .dockerignore                 # Files to exclude from Docker build context
├── README.md                     # User documentation
└── LICENSE                       # MIT License
```

## Key Files and Their Purposes

### Dockerfile
The Dockerfile defines how the SmartMet Server Docker image is built:
- Installs SmartMet packages from FMI's RPM repository
- Configures the base Rocky Linux 9 system
- Installs smartmet-server, engines, plugins, and libraries
- Sets up directory structure for data and configurations
- Runs as non-root user (UID 101010) for security
- Includes healthcheck using the admin plugin

### docker-entrypoint.sh
Entry point script that:
- Creates user entry in /etc/passwd if running in restricted environments (e.g., OpenShift)
- Launches smartmetd with jemalloc for improved memory management
- Allows running custom commands instead of smartmetd

### docker-compose.yml
Provides a complete local development setup with:
- SmartMet Server service
- FMI data downloader service for MEPS model data
- Shared volumes for model data

### .github/workflows/docker-image.yml
CI/CD workflow that:
- Runs daily (6 AM UTC) and on pushes/PRs to master branch
- Builds the Docker image
- Tests the image by starting a container and verifying the WMS endpoint
- Tags images with build date derived from RPM package build times
- Pushes images to Docker Hub

### smartmetconf/
Configuration directory containing:
- **smartmet.conf**: Main server configuration
- **engines/**: Configuration for data engines (observation, querydata, geonames, gis, contour)
- **plugins/**: Configuration for server plugins (admin, timeseries, wms, wfs, download, etc.)

### wms/
WMS-specific resources:
- Layer definitions
- Map styles
- Legend graphics
- Customer-specific configurations

## Build and Test Process

### Building the Image
```bash
docker build . --file Dockerfile --tag fmidev/smartmetserver:latest
```

### Testing the Image
The CI pipeline tests the image by:
1. Starting a container from the built image
2. Waiting 45 seconds for the server to initialize
3. Checking logs for any startup errors
4. Verifying the WMS GetCapabilities endpoint responds successfully
5. Stopping the container

To test locally:
```bash
# Start the container
docker run --name test -p 8080:8080 fmidev/smartmetserver:latest

# In another terminal, test endpoints:
curl "http://localhost:8080/wms?request=getCapabilities&service=WMS"
curl "http://localhost:8080/info?what=qengine"
curl "http://localhost:8080/timeseries?producer=meps&lonlat=24.94,60.17&param=time,temperature,pressure"

# Stop the container
docker stop test
```

### Using Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Making Changes

### When Modifying the Dockerfile
1. **Package Updates**: When adding or updating SmartMet packages, ensure:
   - Packages are available in the FMI smartmet-open repository
   - Dependencies are satisfied
   - The image size impact is considered (use `--setopt=install_weak_deps=False`)

2. **System Dependencies**: When adding system packages:
   - Use Rocky Linux 9 compatible packages
   - Document why the package is needed
   - Clean up after installation with `dnf clean all`

3. **Security**: 
   - Keep running as non-root user (101010)
   - Do not expose unnecessary ports
   - Minimize installed packages
   - Keep base image updated

4. **Testing**: After Dockerfile changes:
   - Build the image locally
   - Test that the server starts successfully
   - Verify key endpoints (WMS, admin, timeseries) work
   - Check image size hasn't grown unnecessarily

### When Modifying Configuration Files

1. **smartmetconf/**: 
   - Understand the impact on SmartMet Server behavior
   - Test with actual data if possible
   - Ensure configurations are valid XML/CONF format
   - Document any non-obvious settings

2. **wms/**:
   - Validate layer definitions against WMS 1.3.0 specification
   - Test map rendering if modifying styles
   - Ensure referenced resources exist

### When Modifying CI/CD Workflow

1. **Testing**:
   - Ensure the test adequately validates the image
   - Consider adding tests for new features
   - Keep test runtime reasonable (currently ~45s wait time)

2. **Tagging Strategy**:
   - The current strategy uses the newest RPM build time as version
   - Don't change this without understanding the impact on users

## Common Tasks

### Adding a New SmartMet Plugin or Engine
1. Add the package to the `dnf install` command in the Dockerfile
2. Add configuration files to `smartmetconf/plugins/` or `smartmetconf/engines/`
3. Update documentation in README.md if user-facing
4. Test the build and verify the plugin loads

### Updating Base Image or SmartMet Repository
1. Update the FROM line or repository URL in Dockerfile
2. Test thoroughly as this can have wide-reaching effects
3. Verify all packages still install correctly
4. Run full test suite

### Modifying Data Directory Structure
1. Update the `mkdir` commands in Dockerfile
2. Update `docker-compose.yml` volume mounts if needed
3. Update documentation in README.md
4. Consider backwards compatibility with existing deployments

## Troubleshooting

### Build Failures
- Check if SmartMet repository is accessible
- Verify package names are correct
- Check for dependency conflicts
- Review DNF error messages carefully

### Runtime Failures
- Check container logs: `docker logs <container-name>`
- Verify configuration files are valid
- Ensure data directories are properly mounted
- Check file permissions (remember: running as UID 101010)
- Use healthcheck endpoint: `curl http://localhost:8080/info?what=qengine`

### Test Failures in CI
- Check if 45-second wait time is sufficient
- Verify endpoint URLs are correct
- Review test logs in GitHub Actions
- Test locally before pushing

## Important Notes

1. **User Permissions**: The container runs as UID 101010, not root. Ensure any new files or directories have appropriate permissions.

2. **Data Volumes**: SmartMet Server expects data in specific directories under `/smartmet/data/`. Maintain this structure.

3. **Configuration Precedence**: Configurations in `/etc/smartmet/` override package defaults. Be aware of what you're customizing.

4. **Memory Management**: The entry point uses jemalloc (`LD_PRELOAD=libjemalloc.so.2`) for better memory management. Don't remove this unless you understand the implications.

5. **Healthcheck**: The Docker healthcheck pings the admin plugin. If you remove or disable the admin plugin, update the healthcheck.

6. **Image Tagging**: Images are tagged with both `latest` and a date-based version. Both tags are pushed to the registry.

## References

- [SmartMet Server GitHub](https://github.com/fmidev/smartmet-server)
- [SmartMet Plugin TimeSeries Guide](https://github.com/fmidev/smartmet-plugin-timeseries/wiki/SmartMet-plugin-TimeSeries)
- [SmartMet Plugin WMS Guide](https://github.com/fmidev/smartmet-plugin-wms/wiki/SmartMet-plugin-WMS-%28Dali-%26-WMS%29)
- [SmartMet Plugin WFS Guide](https://github.com/fmidev/smartmet-plugin-wfs/wiki/SmartMet-plugin-WFS)
- [SmartMet Plugin Download Guide](https://github.com/fmidev/smartmet-plugin-download/wiki/SmartMet-plugin-download)
- [FMI Open Development](https://github.com/fmidev)

## Support and Contributions

This is an open-source project maintained by FMI. When contributing:
- Follow existing code style and conventions
- Test changes thoroughly
- Keep changes minimal and focused
- Document significant changes
- Consider backwards compatibility
