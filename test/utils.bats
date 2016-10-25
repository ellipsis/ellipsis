#!/usr/bin/env bats

load _helper
load utils

setup() {
    mkdir -p tmp/ellipsis_home
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf tmp
}

utils_prompt_yes() {
    echo y | utils.prompt "select yes"
}

utils_prompt_no() {
    echo n | utils.prompt "select no"
}

@test "utils.cmd_exists should find command in PATH" {
    run utils.cmd_exists bats
    [ $status -eq 0 ]
}

@test "utils.cmd_exists should not find commands not in PATH" {
    run utils.cmd_exists gobbledygook
    [ $status -eq 1 ]
}

@test "utils.prompt should return true if yes" {
    run utils_prompt_yes
    [ $status -eq 0 ]
}

@test "utils.prompt should return false if not true" {
    run utils_prompt_no
    [ $status -eq 1 ]
}

@test "utils.prompt should return true if no terminal and default true" {
    run utils.prompt "select yes" "yes"
    [ $status -eq 0 ]
}

@test "utils.prompt should return false if no terminal and default false" {
    run utils.prompt "select yes" "no"
    [ $status -eq 1 ]
}

@test "utils.version_compare compares version strings (less-than)" {
    run utils.version_compare "1.2.2" "lt" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.2.1-Alpha" "-lt" "1.2.3.2"
    [ $status -eq 0 ]
    run utils.version_compare "1.1.3" "<" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.4" "lt" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.2.4-rc2" "-lt" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "2.2.3" "<" "1.2.3"
    [ $status -eq 1 ]
}

@test "utils.version_compare compares version strings (less-than or equal)" {
    run utils.version_compare "1.2.3" "le" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.2" "le" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3-rc1" "-le" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "99.2.2" "-le" "100.2.2"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3" "<=" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.2" "<=" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.3.2" "le" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.3.2" "-le" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.20.3" "<=" "1.2.3"
    [ $status -eq 1 ]
}

@test "utils.version_compare compares version strings (greater-than)" {
    run utils.version_compare "1.2.4" "gt" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.4" "-gt" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.3.3" ">" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3" "gt" "2.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.2.3.1" "-gt" "1.2.3.2"
    [ $status -eq 1 ]
    run utils.version_compare "1.2.13" ">" "1.2.33"
    [ $status -eq 1 ]
}

@test "utils.version_compare compares version strings (greater-than or equal)" {
    run utils.version_compare "1.2.3" "ge" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.4" "ge" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "19.0.3" "-ge" "19.0.3"
    [ $status -eq 0 ]
    run utils.version_compare "2.2.4" "-ge" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3" ">=" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.3.3" ">=" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.2" "ge" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.2.2.1" "-ge" "1.2.3.1"
    [ $status -eq 1 ]
    run utils.version_compare "1.2.3" ">=" "1.20.3"
    [ $status -eq 1 ]
}

@test "utils.version_compare compares version strings (equal)" {
    run utils.version_compare "1.2.3" "eq" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3.1" "-eq" "1.2.3.1"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3" "==" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3" "=" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3-rc1" "eq" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "0.0.1-rc3" "-eq" "0.0.1"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.4" "eq" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "2.2.4" "-eq" "9.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.1.3" "==" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "0.2.3" "=" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.2.10-rc1" "eq" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.2.1-rc1" "-eq" "1.20.3"
    [ $status -eq 1 ]
}

@test "utils.version_compare compares version strings (not equal)" {
    run utils.version_compare "1.2.2" "ne" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.2" "-ne" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.1.3" "!=" "1.2.3"
    [ $status -eq 0 ]
    run utils.version_compare "1.2.3" "ne" "1.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "10.2.3" "-ne" "10.2.3"
    [ $status -eq 1 ]
    run utils.version_compare "1.11.3" "!=" "1.11.3"
    [ $status -eq 1 ]
}

@test "utils.is_true correctly evaluates variables" {
    local var=true
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="true"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="True"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="TRUE"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="yes"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="Yes"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="YES"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="y"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="Y"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var="1"
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var=1
    run utils.is_true "$var"
    [ $status -eq 0 ]

    local var=0
    run utils.is_true "$var"
    [ $status -eq 1 ]

    local var="0"
    run utils.is_true "$var"
    [ $status -eq 1 ]

    local var="false"
    run utils.is_true "$var"
    [ $status -eq 1 ]

    local var="random"
    run utils.is_true "$var"
    [ $status -eq 1 ]

    local var=""
    run utils.is_true "$var"
    [ $status -eq 1 ]

    run utils.is_true "$unset"
    [ $status -eq 1 ]
}
