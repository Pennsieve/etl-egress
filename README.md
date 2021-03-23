# ETL Egress Lambda Function

Process status updates for ETL/Fynnflow progress

## Dependencies

This projects requires the following:

- [Docker](https://docs.docker.com/docker-for-mac/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Running and Developing Locally

__Starting__

To run this container issue the following: `docker-compose up`

__Developing__

- The source file for this Lambda function is located in `./assets/source/`. 
- Once a change is made, simply run `docker-compose up`

## Build Script

The the build script can build a virtual environment and create the the a requirements file. This is what the Dockerfile uses to install dependencies.
