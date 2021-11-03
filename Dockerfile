FROM nodered/node-red

# Copy package.json to the WORKDIR so npm builds all
# of your added nodes modules for Node-RED
COPY package.json .
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production

# Copy _your_ Node-RED project files into place
# NOTE: This will only work if you DO NOT later mount /data as an external volume.
#       If you need to use an external volume for persistence then
#       copy your settings and flows files to that volume instead.
RUN date +%s >> clientid.txt 
RUN export clientid=$(more clientid.txt);curl https://iec-node-red.go.akamai-access.com/signing?clientID=$clientid >> jwt.txt;
COPY --chown=node-red settings.js /data/settings.js
RUN export clientid=$(more clientid.txt);sed -i "s/putclientidhere/$clientid/g" /data/settings.js
RUN export jwt=$(more jwt.txt);sed -i "s/putjwthere/$jwt/g" /data/settings.js
COPY flows_cred.json /data/flows_cred.json
COPY flows.json /data/flows.json

# You should add extra nodes via your package.json file but you can also add them here:
#WORKDIR /usr/src/node-red
#RUN npm install node-red-node-smooth
