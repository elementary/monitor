#!/usr/bin/env python3

'''
This script is used to generate the list of available CPU features by parsing Linux sources.
'''

import urllib.request
import csv

cpu_features = list()
cpu_bugs = list()

with urllib.request.urlopen('https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/arch/x86/include/asm/cpufeatures.h') as f:
    html = f.read().decode('utf-8')
    
    for line in html.split('\n'):
        if 'X86_FEATURE_' in line and not line.startswith('/*'):
            flag_name = line.split('X86_FEATURE_')[1].split('\t')[0].split(' ')[0]
            flag_description = line.split('X86_FEATURE_')[1].split('\t')[-1].split('/*')[-1].strip('*/').replace('""', '').strip().replace('"', '')
            print(flag_name, flag_description)
            cpu_features.append([flag_name.lower(), flag_description])

        if 'X86_BUG_' in line and not line.startswith('/*'):
            flag_name = line.split('X86_BUG_')[1].split('\t')[0].split(' ')[0]
            flag_description = line.split('X86_BUG_')[1].split('\t')[-1].split('/*')[-1].strip('*/').replace('""', '').strip().replace('"', '')
            print(flag_name, flag_description)
            cpu_bugs.append([flag_name.lower(), flag_description])

with open('cpu_features.csv', 'w') as f:
    # create the csv writer
    writer = csv.writer(f)
    writer.writerows(cpu_features)

with open('cpu_bugs.csv', 'w') as f:
    # create the csv writer
    writer = csv.writer(f)
    writer.writerows(cpu_bugs)