## Convert QCOW disk image into VHD

This series of scripts will take a QCOW disk image, convert it to the VHD format used on Citrix XenServer (the hypervisor used on Rackspace's Public Cloud) and then upload it to Rackspace's Cloud Images for usage on the Public Cloud
 
  __Assumes__: Ubuntu 12.04 bare-metal machine

## Usage
  
  1. __compile_vhdutil.sh__
   * ie `./compile_vhdutil.sh`
   * Pulls Xen 4.4.0 source and *only* compiles the tools sub-directory
   * The tools subdirectory contains the `vhd-util` utility used to convert a RAW disk image into VHD format
  
  2. __modify_qcow.sh \<OPTIONAL_QCOW_IMAGE\>__
   * ie `./modify_qcow.sh`
   * Will download Ubuntu 14.04 UEC QCOW image if an image is not provided
   * Mounts the QCOW
   * Bootstraps the image with the necessary modifications needed for the Rackspace Public Cloud (via chroot)
   * Unmounts the QCOW
  
  3. __qcow_to_vhd.sh \<QCOW_INPUT_PATH\> \<VHD_OUTPUT_PATH\>__
   * i.e `./qcow_to_vhd.sh ./trusty-server-cloudimg-amd64-disk1.img .`
   * Converts the QCOW to RAW
   * Then, converts the RAW image into VHD
  
  4. __upload_to_cloudimages.py \<PUBLIC_CLOUD_REGION\> \<VHD_PATH\> \<CUSTOM_IMAGE_NAME\>__
   * __Assumes__: pyrax creds stored in ~/pyrax_rc formatted as such:
     
     ```
     [rackspace_cloud]
     username = <RAX_USERNAME>
     api_key = <RAX_API_KEY>
     ```
   * i.e `python upload_to_cloudimages.py ORD trusty-server-cloudimg-amd64-disk1.vhd "myubuntu_1404"`
     * __Note__: Takes a while i.e 5-15+ minutes
   * Uploads the new VHD image upto the Rackspace Public Cloud region with the custom image name provided
     * Specifically, uploads the VHD to the Cloud Files in the region provided
     * Then, registers the image with Cloud Images which allows for it to be an option upon instance boot
  5. Boot VM with new image
   * `nova boot --image="myubuntu_1404" --flavor=performance1-4 myubuntu`
