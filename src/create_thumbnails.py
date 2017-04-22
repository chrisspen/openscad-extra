#!/usr/bin/env python
"""
Creates PNG thumbnails for all STL files.
"""
from __future__ import print_function
import os, sys, tempfile, argparse, time, csv

PRINTING_GUIDE_FN = 'printing_recommendations.csv'
PRINTING_GUIDE_HEADERS = [
    'filename',
    'wall_thickness',
    'color',
    'infill_percent',
    'platform_adhesion',
    'support_type',
    'obsolete',
]

def generate_thumbnails(force=False, **kwargs):
    
    unique_filenames = set()
    
    for fn in os.listdir('.'):
        if not fn.endswith('.scad'):
            continue
        
        unique_filenames.add(fn)
        #print(unique_filenames)
        
        base_fn, ext = os.path.splitext(fn)
        thumbnail_fn = '../docs/' + base_fn + '.png'

        # Track if STL has been modified since last thumbnail was generated.
        ts_stale = False
        if os.path.isfile(thumbnail_fn):
            stl_ts = os.path.getmtime(fn)
            thumbnail_ts = os.path.getmtime(thumbnail_fn)
            ts_stale = thumbnail_ts < stl_ts

        # Skip if thumbnail exists and it's up to date.
        if not force and os.path.isfile(thumbnail_fn) and not ts_stale:
            continue

#         tmp_fh, tmp_fn = tempfile.mkstemp()
#         tmp_fout = os.fdopen(tmp_fh, 'w')
#         content = 'import("%s");' % os.path.abspath(fn)
#         print(content)
#         tmp_fout.write(content)
#         tmp_fout.close()
        
        cmd = 'openscad --autocenter --projection=ortho --render --viewall --colorscheme=Nature -o %s %s' % (thumbnail_fn, os.path.abspath(fn))
        print(cmd)
        os.system(cmd)
        
if __name__ == '__main__':
        
    parser = argparse.ArgumentParser(description='Creates PNG thumbnails for all OpenSCAD files.')
    parser.add_argument('--force', dest='force', action='store_true',
        help='If given, re-generates a thumbnail even if one already exists.')
    
    args = parser.parse_args()
    
    generate_thumbnails(**args.__dict__)
