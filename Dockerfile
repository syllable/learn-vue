FROM node:16-alpine as build-stage

# Build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


# production
FROM nginx:1.20.2-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
