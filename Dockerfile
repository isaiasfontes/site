 # syntax=docker/dockerfile:1.4
#####################################
# Build stage: clone repo and prepare static site
#####################################
FROM alpine/git AS gitclone
ARG GIT_REPO=git@github.com:isaiasfontes/site.git
ARG GIT_BRANCH=main
# allow use of ssh agent via BuildKit (--ssh)
# clone shallow
RUN apk add --no-cache openssh && \
    mkdir /src
# clone using SSH agent forwarded
# note: requires BuildKit + --ssh
RUN --mount=type=ssh git clone --depth 1 --branch ${GIT_BRANCH} ${GIT_REPO} /src || \
    (echo "git clone failed" && exit 1)

#####################################
# Final stage: nginx serve static files
#####################################
FROM nginx:stable-alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy custom nginx conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy site
COPY --from=gitclone /src /usr/share/nginx/html

# Ensure ownership
RUN chown -R nginx:nginx /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
