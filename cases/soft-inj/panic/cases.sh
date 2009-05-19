#!/bin/sh
#
# Software injection based test cases - panic cases: test cases are
# triggered via bin/inject tool, and they will trigger kernel panic.
#
# Copyright (C) 2008, Intel Corp.
#   Author: Huang Ying <ying.huang@intel.com>
#
# This file is released under the GPLv2.
#

. $ROOT/lib/functions.sh
. $ROOT/lib/dirs.sh
. $ROOT/lib/mce.sh
. $ROOT/lib/soft-inject.sh

enumerate()
{
    soft_inject_enumerate
}

trigger()
{
    soft_inject_trigger
}

get_result()
{
    soft_inject_get_klog
    get_gcov arch/x86/kernel/cpu/mcheck/mce_64.c

    case "$bcase" in
	fatal*)
	    soft_inject_get_mcelog
	    ;;
	*)
	    echo '!!! Unknown case: $this_case !!!'
    esac
}

verify()
{
    local removes="TSC TIME PROCESSOR"
    local general_panic="Machine check"
    local fatal_panic="Fatal machine check"
    local pcc_exp="Processor context corrupt"
    case "$bcase" in
	fatal|fatal_irq|fatal_over)
	    removes="$removes RIP"
	    soft_inject_verify_mcelog
	    verify_klog $klog
	    soft_inject_verify_panic "$fatal_panic"
	    soft_inject_verify_exp "$pcc_exp"
	    ;;
	fatal_ripv|fatal_eipv|fatal_userspace)
	    soft_inject_verify_mcelog
	    verify_klog $klog
	    soft_inject_verify_panic "$fatal_panic"
	    soft_inject_verify_exp "$pcc_exp"
	    ;;
	fatal_no_en)
	    removes="$removes RIP"
	    soft_inject_verify_mcelog
	    verify_klog $klog
	    soft_inject_verify_panic "Machine check from unknown source"
	    ;;
	fatal_timeout)
	    removes="$removes RIP"
	    soft_inject_verify_mcelog
	    verify_klog $klog
	    soft_inject_verify_panic "$general_panic"
	    soft_inject_verify_timeout
	    soft_inject_verify_exp "$pcc_exp"
	    ;;
	fatal_timeout_ripv)
	    soft_inject_verify_mcelog
	    verify_klog $klog
	    soft_inject_verify_panic "$general_panic"
	    soft_inject_verify_timeout
	    soft_inject_verify_exp "$pcc_exp"
	    ;;
	*)
	    echo "!!! Unknown case: $this_case !!!"
    esac
}

soft_inject_main "$@"
