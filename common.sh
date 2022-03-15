_default_project_root=$(dirname $SCRIPT_DIR)
export PROJECT_ROOT=${PROJECT_ROOT:-${_default_project_root}}

ERR_ASSERT_FILE=10
ERR_ASSERT_DIRECTORY=11
ERR_ASSERT_EXISTS=12
ERR_ASSERT_VAR=13

ERR_UNKNOWN=99

function debug {
        # Arguments: debug message strings
        # If LOG_LEVEL contains the substring "DEBUG" _AND_
        # (DEBUG==ALL _OR_ DEBUG contains the scriptname as a substring)
        # then echo the debug message.
        if [ "X${LOG_LEVEL#*DEBUG}" != "X$LOG_LEVEL" ]; then
                if [ "X$DEBUG" = "XALL" -o "X${DEBUG#*$SCRIPT_NAME}" != "X$DEBUG" ]; then
                        local _tag=$SCRIPT_NAME
                        echo "#DEBUG[$_tag] $@" 1>&2
                fi
        fi
}

function debugenv {
        # Arguments: variable_name(s)
        # If debugging is active echo the variable names and their
        # environment variable values.
        if [ "X$DEBUG" = "XALL" -o "X${DEBUG#*$SCRIPT_NAME}" != "X$DEBUG" ]; then
                for _e in $@; do
                        eval _v=\$${_e}
                        echo "#DEBUG[$SCRIPT_NAME] ${_e}=${_v}" 1>&2
                done
        fi
}

function error {
        # Arguments: status error [zero or more message strings]
        # Echo any given given error message and exit with the given status.
        # A default error status and message are used where either is not given.
        local _status=$1
        _status=${_status:-$ERR_UNKNOWN}
        local _errmsg="${@:2}"
        _errmsg=${_errmsg:="Exist Status $_status"}
        echo "#ERROR[$SCRIPT_NAME] $_errmsg" 1>&2
        exit $_status
}

function info() {          
	echo "#INFO $@"
}   

function assert_var {
        # Arguments: one environment variable name
        # Test if the given environment variable is defined and of non-zero length
        # Exit with status $ERR_ASSERT_VAR if it is not.
        debug $FUNCNAME "$*"
        local _var="$1"
        if [ "X${_var}" == "X" ]; then
                error $ERR_ASSERT_VAR "Failed assert var: ${_var}"
        fi
        eval _val=\$${_var}
        if [ "X${_val}" == "X" ]; then
                error $ERR_ASSERT_VAR "Failed assert var: ${_var}"
        fi
}

function assert_vars {
        # Arguments: one or more environment variable names.
        # Test all named environment variable is defined and of non-zero length.
        # Exit with status $ERR_ASSERT_VAR if not.
        debug $FUNCNAME "$*"
        for _v in $@; do
                assert_var $_v
        done
}

function assert_file {
        # Arguments: one filename with path relative to $CWD.
        # Test if the given path is a filename and exists
        # Exit with status $ERR_ASSERT_FILE if it is not.
        debug $FUNCNAME "$*"
        local _f="$1"
        assert_var _f
        if [ "X${_f}" = "X" -o ! -f "${_f}" ]; then
                error $ERR_ASSERT_FILE "Failed assert file: ${_f}"
        fi
}

function assert_directory {
        # Arguments: one directory with path relative to $CWD.
        # Test if the given path is a directory and exists
        # Exit with status $ERR_ASSERT_DIRECTORY if it is not.
        debug $FUNCNAME "$*"
        local _d="$1"
        assert_var _d
        if [ "X${_d}" != "X" -a ! -d "${_d}" ]; then
                error $ERR_ASSERT_DIRECTORY "Failed assert directory: ${_d}"
        fi
}

function assert_exists {
        # Arguments: one filesystem path relative to $CWD.
        # Test if the given path exists (but we don't care what it is)
        # Exit with status $ERR_ASSERT_VAR if it is not.
        debug $FUNCNAME "$*"
        local _f="$1"
        assert_var _f
        if [ "X${_f}" != "X" -a ! -e "${_f}" ]; then
                error $ERR_ASSERT_DIRECTORY "Failed assert exists: ${_f}"
        fi
}

