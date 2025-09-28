# Using a Debian-based Node.js image for better compatibility with native modules
FROM node:18

# Set the working directory
WORKDIR /opt/app

# Install build tools needed for native Node.js modules like @swc/core
# This allows them to be compiled from source if pre-built binaries fail.
RUN apt-get update && apt-get install -y build-essential python-is-python3 --no-install-recommends

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your Strapi application code
COPY . .

# Build the Strapi application for production
# This step should now work as the build tools are available.
RUN npm run build

# Expose the port Strapi runs on
EXPOSE 1337

# Start the Strapi application
CMD ["npm", "run", "start"]
