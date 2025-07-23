FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

<<<<<<< HEAD
# Stage 2: Serve
FROM nginx:alpine
=======
# Stage 2: Serve with nginx
# Build stage
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:stable-alpine
>>>>>>> c55fed3a34a6c63beaec023dca49b953b518bb87
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

