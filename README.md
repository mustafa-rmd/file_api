# File Storage API

This is a Ruby on Rails application built with version **7.2.1**. It provides an API for managing file uploads and user authentication using JWT for authorization. The application uses **MinIO** for file storage and **MongoDB** for storing file metadata.

## Table of Contents

- [Features](#features)
- [Technologies](#technologies)
- [Installation](#installation)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Controllers](#controllers)
- [License](#license)

## Features

- User authentication with JWT
- File upload and management
- File metadata storage in MongoDB
- File storage in MinIO

## Technologies

- Ruby on Rails 7.2.1
- MongoDB
- MinIO
- JWT for authentication

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/file-storage-api.git
   cd file-storage-api


2. Install the required gems:
   ```bash
   bundle install

3. Set up your MongoDB and MinIO instances.


4. Start the Rails server:
   ```bash
   rails server


## Usage
You can interact with the API using any HTTP client (like Postman or Curl) or integrate it with a frontend application.

# API Endpoints

## Authentication Endpoints

### Sign Up
- **POST** `/v1/auth/signup`
    - **Body:**
      ```json
      {
        "user": {
          "username": "string",
          "password": "string"
        }
      }
      ```

### Login
- **POST** `/v1/auth/login`
    - **Body:**
      ```json
      {
        "username": "string",
        "password": "string"
      }
      ```

### Delete User
- **DELETE** `/v1/auth/delete`
    - **Authorization:** Bearer token

## File Management Endpoints

### Get All Files
- **GET** `/v1/blobs`
    - Returns a list of all uploaded files.

### Upload File
- **POST** `/v1/blobs`
    - **Form Body:**
      ```
        file_upload[data] : "filepath"
      ```

### Get File by ID
- **GET** `/v1/blobs/:id`
    - Returns metadata for the specified file.

### Delete File
- **DELETE** `/v1/blobs/:id`
    - Deletes the specified file.


# Running Dependencies

This project requires two services to be up and running: **MongoDB** and **MinIO**. You can start these services using Docker Compose.

## Prerequisites

Ensure you have the following installed on your machine:
- **Docker**: Make sure you have Docker installed. You can download it from [Docker's official site](https://www.docker.com/get-started).
- **Docker Compose**: This tool is usually bundled with Docker Desktop, but you can also install it separately. Refer to the [Docker Compose installation guide](https://docs.docker.com/compose/install/) for details.

## Docker Compose Configuration

Below is the `docker-compose.yml` configuration for the required services:

```yaml
version: "3.4"
services:
  mongodb:
    image: mongo:6.0.3
    command: "--nojournal"
    ports:
      - "27017:27017"
    volumes:
      - mongodb_vol:/data/db
    logging:
      options:
        max-size: 50m

  minio:
    image: 'bitnami/minio:latest'
    container_name: minio
    environment:
      - MINIO_ROOT_USER=minio
      - MINIO_ROOT_PASSWORD=minio123
    ports:
      - '9000:9000'
      - '9001:9001'
    volumes:
      - data3-1:/data1
      - data3-2:/data2

volumes:
  mongodb_vol:
  data3-1:
  data3-2:
   ```

## Docker Compose Configuration

1. Navigate to the directory containing the docker-compose.yml file. You can do this using the terminal or command prompt:
   ```bash
    cd /path/to/your/project

2. Run the following command to start the services:
   ```bash
    docker-compose up
   
This command will download the necessary Docker images (if not already present), create the containers, and start the services.

3. Access the services:
MongoDB will be available on port 27017. You can connect to it using any MongoDB client or command line tool.
MinIO can be accessed on:
Port 9000: for the web interface (access the MinIO browser)
Port 9001: for the management interface
Use the following credentials to log in to MinIO:
Username: minio
Password: minio123


4. Stopping the Services
   ```bash
    docker-compose down