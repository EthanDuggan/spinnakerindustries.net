# Start from the base node image (version 16)
FROM node:16

# Set the working directory to be the /app directory in our docker image
WORKDIR /app

#Install cifs-utils and then mount the smb share on Horton for access to things like 'Horton/reference/Eng Product Log.xls'
RUN ["mkdir", "/horton"]
RUN ["mkdir", "/horton/spin.net-logs"]
RUN apt-get update
RUN apt-get install cifs-utils -y

# Copy any npm package files into our working directory
COPY package*.json ./


# Run 'npm install' on our docker image to install the packages listed in the npm package files
RUN ["npm", "install"]

# Copy the rest of our app into our working directory (anything defined in .dockerignore will be ignored, for example the node_modules folder will be ignored because we already installed our third-party modules when we ran 'npm install')
COPY . .

# Build the svelte app
RUN ["npm", "run", "build"]

# Set the environment variable 'PORT' to 8080, and expose 8080.  This will make our app available over port 8080 of our docker container.
ENV PORT=80
EXPOSE 80

# Start our node app
# Start our node app
ADD start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]