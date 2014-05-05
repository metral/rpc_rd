import pyrax
import sys
import os

use_snet = sys.argv[1]
region = sys.argv[2].upper()
filepath = sys.argv[3]
basename = os.path.basename(filepath)
image_name = sys.argv[4]

pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
pyrax.set_credential_file(creds_file, region)

imgs = pyrax.images
cf = None

# Only use service net for cloudfiles if on public cloud
if use_snet == "true":
    cf = pyrax.connect_to_cloudfiles(region, public=False)
else:
    cf = pyrax.cloudfiles

cont = cf.create_container("images")
cf.upload_file(cont, filepath)
obj = cont.get_object(basename)

task = imgs.import_task(obj, cont, img_format="VHD", img_name=image_name)

pyrax.utils.wait_until(task, "status", ["success", "failure"],
        verbose=True, interval=30)
print()
if task.status == "success":
    print("Success!")
else:
    print("Image import failed!")
    print("Reason: %s" % task.message)
