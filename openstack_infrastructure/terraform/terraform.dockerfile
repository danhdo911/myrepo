FROM harbor.iij.com.vn/customized-images/terraform:1.10.3

RUN apk add --no-cache aws-cli oath-toolkit-oathtool jq

RUN aws --version && oathtool -V
