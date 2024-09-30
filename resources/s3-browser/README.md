# s3-browser

A web app to browse a s3 bucket from a VRE.
The aim is to allow users to interact with a s3 bucket.
At startup the frontend list objects at the bucket's root.

Features:
- list objects in a single bucket
- file upload
- file download
- delete a file
- delete a folder

* Backend based on [Nestjs](https://docs.nestjs.com/)
* Frontend based on [Angular](https://v17.angular.io/docs) & Angular material

![img](./screenshot-1.png)
![img](./screenshot-2.png)

## Pre-requisites

* Nodejs v18+

Before running backend, create a .env file with following content:

```bash
ACCESS_KEY_ID=""
SECRET_ACCESS_KEY=""
ENDPOINT=""
REGION=""
JUPYTERHUB_USER=""
```

or give it via environnment variables.

## Install

```bash
cd backend
npm install
```

```bash
cd frontend
npm install
```

## Run

```bash
cd backend
npm start
```

```bash
cd frontend
npm start
```

## TODO

Allow to customize header (App name)
