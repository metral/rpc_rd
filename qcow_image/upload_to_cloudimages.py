#!/usr/bin/python

import pyrax
import sys
import os

if len(sys.argv) != 4:
    print "Usage: python " + sys.argv[0] + \
            " <PUBLIC_CLOUD_REGION> <VHD_PATH> <CUSTOM_IMAGE_NAME>"
    sys.exit (1)

region = sys.argv[1].upper()
filepath = sys.argv[2]
basename = os.path.basename(filepath)
image_name = sys.argv[3]

pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
pyrax.set_credential_file(creds_file, region)

imgs = pyrax.images
cf = pyrax.cloudfiles

cont = cf.create_container("images")
cf.upload_file(cont, filepath)
obj = cont.get_object(basename)

task = imgs.import_task(obj, cont, img_format="VHD", img_name=image_name)

pyrax.utils.wait_until(task, "status", ["success", "failure"],
        verbose=True, interval=30)

if task.status == "success":
    print("Success!")
else:
    print("Image import failed!")
    print("Reason: %s" % task.message)
