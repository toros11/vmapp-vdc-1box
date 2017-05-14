#!/bin/bash


vm_run_cmd "initctl restart vdc-collector"
vm_run_cmd "initctl restart vdc-dcmgr"
vm_run_cmd "initctl restart vdc-hva"
