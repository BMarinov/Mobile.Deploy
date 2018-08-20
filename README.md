# Mobile.Deploy
Android and iOS Packaging Utilities

## Sample Usage (iOS IPA):
```bash
./repackage-ipa.sh \
    '/Users/myuser/package/App.Name.iOS.ipa' \
    'Production' \
    '/Users/myuser/cert/iOS Distribution Cert.p12' \
    'This is my cert name!' \
    'Secret' \
    '/Users/myuser/pp/AgExpert_Field__App_Store__Prod.mobileprovision' \
    'TEAMID' \
    'App.Name.iOS' \
    'My Great App' \
    'com.greatapps.mygreatapp' \
    '1.0.12345' \
    'true'
