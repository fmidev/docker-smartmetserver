#!/bin/bash

/usr/bin/fmi/radon2config /config/libraries/grid-files "host=$RADON_HOST dbname=$RADON_DATABASE user=$RADON_USER password=$RADON_PASSWORD"

/usr/bin/fmi/radon2smartmet /config/radon-to-smartmet.cfg $1