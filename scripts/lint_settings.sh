#!/bin/bash
function get_pylint_settings () {
    # cosmetic violations - no excuses or arguments will be upheld
    # ideally we would grab this from a 'central' source

    local result
    # turn off everything
    # (config file does not seem to support this syntax)
    #result=' -d E,C,W,R,F -e C0301 '
    result=' -d E,C,W,R,F'

    # cosmetic
    result+=' --max-line-length 80' # can't assume a default
    # result+=' --max-module-lines 3000' # topping up as existinf code > default
    result+=' --max-module-lines 5000' # temp to support interim OCR fix
    result+=' -e C0301' # long lines
    # need pylint 1+ for C0303 check - can't seem to pip this on hookipa
    result+=' -e C0303' # trailing WS
    result+=' -e C0304' # missing newline on the last line
    result+=' -e C0302' # too many lines

    # code 'smells'
    result+=' -e W0611' # unused import
    # have to suppress unused var for now...even though this is smellu
    # reason is lint complains about 'for i ....' type variable instances...
    #result+=' -e W0612' # unused variable
    result+=' -e E0602' # undefined variable

    echo $result
}
