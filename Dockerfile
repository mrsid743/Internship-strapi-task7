# Using a Debian-based Node.js image for better compatibility with native modules
FROM node:18

# Set the working directory
WORKDIR /opt/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
# Using --no-optional to skip unnecessary dependencies and speed up the build
RUN npm install --no-optional

# Copy the rest of your Strapi application code
COPY . .

# Build the Strapi application for production
RUN npm run build

# Expose the port Strapi runs on
EXPOSE 1337

# Start the Strapi application
CMD ["npm", "run", "start"]
