#!/usr/bin/env bash

set -exu

certificateFile="codesign"

echo "DEBUG: APPLE_P12_CERTIFICATE: $APPLE_P12_CERTIFICATE"

# Recreate the certificate from the secure environment variable
echo "$APPLE_P12_CERTIFICATE" | base64 --decode > $certificateFile.p12

scripts/codesign/import_certificate_into_new_keychain.sh "$certificateFile" "$APPLE_P12_CERTIFICATE_PASSWORD"
