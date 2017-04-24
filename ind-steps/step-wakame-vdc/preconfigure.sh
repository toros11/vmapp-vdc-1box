#!/bin/bash

hypervisor_setup ${hypervisor}


# sta
chkconfig --list tgtd
chkconfig        tgtd on
chkconfig --list tgtd
