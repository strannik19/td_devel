if [ -r ${HOME}/.sljm.env ]
then
    . ${HOME}/.sljm.env
else
    GROUP=$(id -gn)
    export GROUP

    DWH_DIR=INST_DWH_BASEDIR
    export DWH_DIR

    GROUP_PROFILE=${DWH_DIR}/${GROUP}/.profile
    export GROUP_PROFILE

    if [ -r ${GROUP_PROFILE} ]
    then
        . ${GROUP_PROFILE}
    fi
fi

echo ""
echo "##############################################################"
echo "# SLJM and GCFR environment has been set"
echo "# Base folder is ${DWH_DIR}/${GROUP}"
echo "##############################################################"
echo ""
