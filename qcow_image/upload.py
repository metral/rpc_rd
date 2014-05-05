import pyrax
import sys
import os

use_snet = sys.argv[1]
region = sys.argv[2].upper()
filepath = sys.argv[3]

pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
pyrax.set_credential_file(creds_file, region)

# Only use service net for cloudfiles if on public cloud
if use_snet == "true":
    cf = pyrax.connect_to_cloudfiles(region, public=False)
else:
    cf = pyrax.cloudfiles


cont = cf.create_container("images")
cf.upload_file(cont, filepath)
