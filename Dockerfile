<<<<<<< HEAD
# Stage 1: Build the React app
FROM node:16 AS build

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Stage 2: Serve with nginx
=======
# Build stage
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
>>>>>>> a384158f (Initial commit)
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
<<<<<<< HEAD
=======

>>>>>>> a384158f (Initial commit)
