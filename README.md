# docker-pm2

🐳 Un-official Docker Image for PM2 runtime

## What is pm2 ?

Production ready Docker image including the PM2 runtime.

The goal of this image is to wrap your applications into a proper Node.js production environment. It solves major issues when running Node.js applications inside a container like:

-   Correct PID 1 signals Handling & Forwarding
-   Graceful application Start and Shutdown
-   Seamless application clustering to increase performance and reliability

Further than that, using PM2 as a layer between the container and the application brings PM2 features like application declaration file, customizable log system, source map support and other great features to manage your Node.js application in production environment.

## How to use this image
