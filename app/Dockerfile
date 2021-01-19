FROM public.ecr.aws/lambda/nodejs:12

# Only copy the package.json file to work directory
COPY package.json /var/task
# Install all Packages
RUN npm install
# Copy typescript config
COPY tsconfig.json /var/task
# Install TypeScript
RUN npm install typescript -g
# Copy all other source code to work directory
COPY src /var/task
# TypeScript
RUN tsc

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "dist/app.handler" ]
