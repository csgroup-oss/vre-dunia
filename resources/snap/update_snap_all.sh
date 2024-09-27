#!/bin/bash

#############################
## This script is not used ##
#############################

plugins="org.esa.sen2coral.sen2coral.kit
org.esa.s3tbx.s3tbx.landsat.reader
org.esa.s3tbx.s3tbx.sentinel3.reader
org.esa.chris.chris.noise.reduction
org.esa.snap.snap.zarr
org.esa.s3tbx.s3tbx.spot.vgt.reader
org.esa.s3tbx.s3tbx.sentinel3.reader.ui
org.esa.s2tbx.s2tbx.otb.adapters.kit
org.esa.s3tbx.s3tbx.mphchl
org.esa.snap.idepix.probav
org.esa.s3tbx.s3tbx.meris.l2auxdata
org.esa.s3tbx.s3tbx.o2a.harmonisation
org.esa.s3tbx.s3tbx.aatsr.sst.ui
org.esa.s3tbx.s3tbx.olci.radiometry
org.esa.s3tbx.s3tbx.slstr.regrid
org.esa.s2tbx.Pansharpening.bayes
org.esa.snap.seadas.seadas.reader.ui
org.esa.s2tbx.s2tbx.gdal.reader.ui
org.esa.chris.chris.atmospheric.correction
org.esa.chris.chris.cloud.screening
org.esa.s3tbx.s3tbx.merisl3.reader
org.esa.s3tbx.s3tbx.fub.wew.ui
org.esa.s3tbx.s3tbx.meris.smac
org.esa.smostbx.smos.tools
org.esa.sen2coral.sen2coral.algorithms
org.esa.snap.idepix.modis
org.vito.probavbox.probavbox.kit
org.esa.s3tbx.s3tbx.insitu.client.ui
org.esa.smostbx.smos.gui
org.esa.s2tbx.sen2three
org.esa.snap.snap.jython
org.esa.s3tbx.s3tbx.arc.ui
org.esa.s2tbx.Segmentation.cc
org.esa.s3tbx.s3tbx.atsr.reader
org.esa.chris.chris.atmospheric.correction.lut
org.esa.sen2coral.sen2coral.inversion.ui
org.esa.s2tbx.Pansharpening.rcs
org.esa.chris.chris.toa.reflectance.computation
org.esa.s3tbx.s3tbx.c2rcc
org.esa.snap.idepix.spotvgt
org.esa.snap.idepix.landsat8
org.esa.sen2coral.sen2coral.inversion
org.esa.smostbx.smos.reader
org.esa.s3tbx.s3tbx.meris.brr
org.esa.snap.idepix.viirs
org.esa.snap.seadas.seadas.reader
org.esa.smostbx.smos.kit
org.esa.snap.idepix.olci
org.esa.s3tbx.s3tbx.arc
org.esa.chris.chris.geometric.correction
org.esa.s3tbx.s3tbx.alos.reader
org.esa.s3tbx.s3tbx.fub.wew
org.esa.s3tbx.s3tbx.owt.classification
org.esa.s2tbx.sen2cor280
org.esa.snap.idepix.seawifs
org.esa.s2tbx.MultivariateAlterationDetector
org.vito.probavbox.probavbox.reader
org.esa.s3tbx.s3tbx.avhrr.reader
org.esa.snap.core.gpf.operators.tooladapter.snaphu
org.esa.snap.idepix.meris
org.esa.s3tbx.s3tbx.modis.reader
org.esa.s3tbx.s3tbx.rad2refl
org.esa.s2tbx.Pansharpening.lmvm
org.esa.s3tbx.s3tbx.slstr.pdu.stitching.ui
org.esa.chris.chris.util
org.esa.s3tbx.s3tbx.flhmci
org.esa.s3tbx.s3tbx.aatsr.sst
org.esa.smostbx.smos.ee2netcdf.ui
org.esa.s3tbx.s3tbx.meris.ops
org.esa.snap.idepix.s2msi
org.esa.s2tbx.Segmentation.meanshift
org.esa.s3tbx.s3tbx.flhmci.ui
org.esa.s3tbx.s3tbx.meris.radiometry
org.esa.smostbx.smos.dgg
org.esa.s3tbx.s3tbx.kit
org.esa.s3tbx.s3tbx.meris.radiometry.ui
org.esa.smostbx.smos.lsmask
org.esa.snap.snap.product.library.ui
org.esa.snap.idepix.core
org.esa.chris.chris.kit
org.esa.s3tbx.s3tbx.ppe.operator
org.esa.s2tbx.sen2cor255
org.esa.s2tbx.SFSTextureExtraction
org.esa.sen2coral.sen2coral.algorithms.ui
org.esa.s2tbx.Segmentation.watershed
org.esa.smostbx.smos.ee2netcdf
org.esa.s3tbx.s3tbx.slstr.pdu.stitching
org.esa.s3tbx.s3tbx.meris.sdr
org.esa.s2tbx.Segmentation.mprofiles
org.esa.s3tbx.s3tbx.rad2refl.ui
org.esa.s3tbx.s3tbx.meris.cloud
org.esa.s3tbx.s3tbx.fu.operator
org.esa.chris.chris.reader"

echo "Upgrading SNAP modules..."
snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] && sleep 2 && pkill -TERM -f "snap/jre/bin/java"
done

echo "Installing missing SNAP modules..."
for plugin in $plugins; do
    echo "Installing plugin $plugin..."
    snap --nosplash --nogui --modules --install $plugin 2>&1 | while read -r line; do
        echo $line
        if [[ "$line" == Cannot* ]] || [[ "$line" == Unpacking* ]]; then
            sleep 5
            pkill -9 -f "/usr/local/snap/jre/bin/java"
        fi
    done
done