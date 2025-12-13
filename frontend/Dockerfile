FROM node:20-alpine AS dev
WORKDIR /app
ENV NODE_ENV=development
COPY package*.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN chown -R node:node /app
USER node
EXPOSE 5173
CMD ["npm","run","dev","--","--host","0.0.0.0"]

FROM node:20-alpine AS build
WORKDIR /app
ENV NODE_ENV=development
COPY package*.json .
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run build

FROM nginx:alpine AS prod
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir -p \
    /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp \
  && chown -R nginx:nginx /var/cache/nginx \
  && touch /var/run/nginx.pid \
  && chown -R nginx:nginx /var/run/nginx.pid /var/run \
  && chown -R nginx:nginx /var/log/nginx
EXPOSE 8080
USER nginx
CMD ["nginx","-g","daemon off;"]