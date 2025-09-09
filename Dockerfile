# Use official Node.js runtime as base image
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Set build-time environment variables
ARG SUPABASE_URL
ARG SUPABASE_KEY
ENV SUPABASE_URL=$SUPABASE_URL
ENV SUPABASE_KEY=$SUPABASE_KEY

# Build the application
RUN npm run build

# Clean up dev dependencies to reduce image size
RUN npm prune --omit=dev

# Expose port
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production
ENV NITRO_PRESET=node-server

# Start the application
CMD ["npm", "start"]