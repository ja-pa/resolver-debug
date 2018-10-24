#!/bin/bash

if [ -z "$1" ];then
	luajit -bl src/cbi_tab.lua > /dev/null
else
	luajit -bl $1 > /dev/null
fi


