/* createTB.il

Author     Xiwen Zhang
Group      Mobile Computing Power-Intersil
Language   Cadence SKILL
Date       Wed 01 Oct 2014 05:06:22 PM EDT by xzhang02 
Modified   Wed 15 Oct 2014 05:32:39 PM ED by xzhang02 

This code is used to generate a chip companion based on the GUI
***************************************************

*/

/***************************************************************
*                                                              *
*                       tbCreateForm()                       *
*                                                              *
*                     Create the main form                     *
*                                                              *
***************************************************************/
hash_previous_value = makeTable("")
procedure(tbCreateForm(@optional (inst css()))
    let((libName cellName viewName browse readPins sep1 sep2 sep3 copyAllPinsReverse copyAllPins inputPins outputPins 
       inoutPins tgtLibName tgtCellName tgtViewName extract_vams tgtbrowse tgtinputPins tgtoutputPins tgtinoutPins vdd vss testName test_ext
       electrical vsource isource_vss isource_vdd traverse digregs yoffset yoffset1 yoffset2 xoffset2
       genTestBench overridetb check_out override loadSettings saveSettings genSymbol corr genVAMSFile
       viewVAMSFile coVAMSCellView viewVAMSCellView genVAMSCellView removeVAMSFile printDefine setDig top i2c group traditional sourceInstList reloadScript openTestBench
       regInstList getFromDgcv getFromCss loadLast openCellView genWrapper findMismatch)
        ; template loading and saving
        ; cellView specification
        libName=hiCreateStringField(
                ?name 'libName
                ?prompt "Library Name"
                ?callback "ddsUpdateSyncWithForm()"
                ?defValue if(inst~>libName inst~>libName "")
                )
        cellName=hiCreateStringField(
                ?name 'cellName
                ?prompt "Cell Name"
                ?callback "ddsUpdateSyncWithForm()"
                ?defValue if(inst~>cellName inst~>cellName "")
                )
        viewName=hiCreateStringField(
                ?name 'viewName
                ?prompt "View Name"
                ?callback "ddsUpdateSyncWithForm()"
                ?defValue if(inst~>viewName inst~>viewName "")
                )
        getFromDgcv=hiCreateButton(
                ?name 'getFromDgcv
                ?buttonText "From Current CV"
                ?callback "getFromDgcv()"
                )
        getFromCss=hiCreateButton(
                ?name 'getFromCss
                ?buttonText "From Css"
                ?callback "getFromCss()"
                )
        loadLast=hiCreateButton(
                ?name 'loadLast
                ?buttonText "Load Last"
                ?callback "loadLast()"
                )
        browse=hiCreateButton(
                ?name 'browse
                ?buttonText "Browse"
                ?callback "oferSyncBrowser()"
                )
        readPins=hiCreateButton(
                ?name 'readPins
                ?buttonText "Read Pins"
                ?callback "readPins()"
                )
        openCellView=hiCreateButton(
                ?name 'openCellView
                ?buttonText "View CellView"
                ?callback "openCellView()"
                )
        genWrapper=hiCreateButton(
                ?name 'genWrapper
                ?buttonText "Gen Wrapper"
                ?callback "genWrapper()"
                )
        findMismatch=hiCreateButton(
                ?name 'findMismatch
                ?buttonText "Mismatch Pins"
                ?callback "findMismatch()"
                )
        sep1=hiCreateSeparatorField(?name 'sep1)
        inputPins=hiCreateStringField(
                ?name 'inputPins
                ?prompt "input: "
                ?editable nil
                )
        outputPins=hiCreateStringField(
                ?name 'outputPins
                ?prompt "output: "
                ?editable nil
                )
        inoutPins=hiCreateStringField(
                ?name 'inoutPins
                ?prompt "inout: "
                ?editable nil
                )

        tgtLibName=hiCreateStringField(
                ?name 'tgtLibName
                ?prompt "Target Library Name"
                ?callback "ddsUpdateSyncWithForm()"
                ?defValue if(deGetCellView() deGetCellView()~>libName "")
                )
        tgtCellName=hiCreateStringField(
                ?name 'tgtCellName
                ?prompt "Target Cell Name"
                ?callback "ddsUpdateSyncWithForm()"
                ?defValue if(inst~>cellName if(rexMatchp("^STIM_" inst~>cellName) inst~>cellName strcat("STIM_" inst~>cellName)) "")
                )
        tgtViewName=hiCreateCyclicField(
                ?name 'tgtViewName
                ?prompt "Target View Name"
                ?callback "ddsUpdateSyncWithForm()"
                ?defValue "verilogams"
                ?value "verilogams"
                ?choices list("verilogams" "systemVerilog")
                )
        ;tgtViewName=hiCreateStringField(
                ;?name 'tgtViewName
                ;?prompt "Target View Name"
                ;?callback "ddsUpdateSyncWithForm()"
                ;?defValue "verilogams"
                ;)
        extract_vams=hiCreateButton(
                ?name 'extract_vams
                ?buttonText "Extract"
                ?callback "extract_vams()"
                )
        tgtbrowse=hiCreateButton(
                ?name 'tgtbrowse
                ?buttonText "Browse"
                ?callback "tgtoferSyncBrowser()"
                )
        copyAllPins=hiCreateButton(
                ?name 'copyAllPins
                ?buttonText "Copy Pins"
                ?callback "copyAllPins()"
                )
        copyAllPinsReverse=hiCreateButton(
                ?name 'copyAllPinsReverse
                ?buttonText "Copy Pins Rev"
                ?callback "copyAllPinsReverse()"
                )
        copyInPinsOut=hiCreateButton(
                ?name 'copyInPinsOut
                ?buttonText "Copy In->Out"
                ?callback "copyInPinsOut()"
                )
        copyOutPinsIn=hiCreateButton(
                ?name 'copyOutPinsIn
                ?buttonText "Copy Out->In"
                ?callback "copyOutPinsIn()"
                )
        needSensitivity=hiCreateBooleanButton(
                ?name 'needSensitivity
                ?buttonText "Sensitivity"
                ?buttonLocation 'left
                ?defValue t
                )
        top=hiCreateBooleanButton(
                ?name 'top
                ?buttonText "top"
                ?buttonLocation 'left
                ?defValue nil
                )
        i2c=hiCreateBooleanButton(
                ?name 'i2c
                ?buttonText "i2c"
                ?buttonLocation 'left
                ?defValue nil
                )
        group=hiCreateBooleanButton(
                ?name 'group
                ?buttonText "group"
                ?buttonLocation 'left
                ?defValue nil
                ?callback "toggleTraditional()"
                )
        traditional=hiCreateBooleanButton(
                ?name 'traditional
                ?buttonText "traditional"
                ?buttonLocation 'left
                ?defValue t
                )
        override=hiCreateBooleanButton(
                ?name 'override
                ?buttonText "override"
                ?buttonLocation 'left
                ?defValue nil
                )
        check_out=hiCreateBooleanButton(
                ?name 'check_out
                ?buttonText "check out"
                ?buttonLocation 'left
                ?defValue t
                )
        overridetb=hiCreateBooleanButton(
                ?name 'overridetb
                ?buttonText "override?"
                ?buttonLocation 'left
                ?defValue nil
                )
        genSymbol=hiCreateBooleanButton(
                ?name 'genSymbol
                ?buttonText "gen Symbol"
                ?buttonLocation 'left
                ?defValue nil
                )
        sep2=hiCreateSeparatorField(?name 'sep2)
        tgtinputPins=hiCreateStringField(
        ;tgtinputPins=hiCreateMLTextField(
                ?name 'tgtinputPins
                ?prompt "target input: "
                ?focusInCallback "save_current_field_value(\"tgtinputPins\")"
                ?callback "sync_addition_execlusive_removal('tgtinputPins list() list('tgtinoutPins 'tgtoutputPins) list('electrical 'isource_vdd 'isource_vss 'corr 'wires 'digRegs 'vsource))"
                ;?hasHorizontalScrollbar nil
                )
        tgtoutputPins=hiCreateStringField(
                ?name 'tgtoutputPins
                ?prompt "target output: "
                ?focusInCallback "save_current_field_value(\"tgtoutputPins\")"
                ?callback "sync_addition_execlusive_removal('tgtoutputPins list() list('tgtinoutPins 'tgtinputPins) list('electrical 'isource_vdd 'isource_vss 'corr 'wires 'digRegs 'vsource))"
                )
        tgtinoutPins=hiCreateStringField(
                ?name 'tgtinoutPins
                ?prompt "target inout: "
                ?focusInCallback "save_current_field_value(\"tgtinoutPins\")"
                ?callback "sync_addition_execlusive_removal('tgtinoutPins list() list('tgtoutputPins 'tgtinputPins) list('electrical 'isource_vdd 'isource_vss 'corr 'wires 'digRegs 'vsource))"
                )
        vdd=hiCreateStringField(
                ?name 'vdd
                ?prompt "vdd: "
                ?focusInCallback "save_current_field_value(\"vdd\")"
                ?callback "sync_addition_execlusive_removal('vdd list('electrical) list('vss) list())"
                ?defValue "VDD"
                )
        vss=hiCreateStringField(
                ?name 'vss
                ?prompt "vss: "
                ?focusInCallback "save_current_field_value(\"vss\")"
                ?defValue "VSS"
                ?callback "sync_addition_execlusive_removal('vss list('electrical) list('vdd) list())"
                )
        test_ext=hiCreateCyclicField(
                ?name 'test_ext
                ?prompt ""
                ;?callback "ddsUpdateSyncWithForm()"
                ?defValue "vams"
                ?value "vams"
                ?choices list("vams" "sv")
                )
        ;test_ext=hiCreateStringField(
                ;?name 'test_ext
                ;?prompt ""
                ;?defValue "vams"
                ;)
        testName=hiCreateStringField(
                ?name 'testName
                ?prompt "Test_Name: "
                ?defValue "Test_"
                )
        electrical=hiCreateStringField(
                ?name 'electrical
                ?prompt "electrical: "
                ?focusInCallback "save_current_field_value(\"electrical\")"
                ?defValue "VDD VSS"
                ?callback "sync_addition_execlusive_removal('electrical list() list('corr 'wires 'digRegs))"
                )
        vsource=hiCreateStringField(
                ?name 'vsource
                ?prompt "vsource: "
                ?focusInCallback "save_current_field_value(\"vsource\")"
                ?callback "sync_addition_execlusive_removal('vsource list('electrical) list('isource_vdd 'isource_vss 'corr 'wires 'digRegs))"
                )
        isource_vdd=hiCreateStringField(
                ?name 'isource_vdd
                ?prompt "isource_vdd: "
                ?focusInCallback "save_current_field_value(\"isource_vdd\")"
                ?callback "sync_addition_execlusive_removal('isource_vdd list('electrical) list('vsource 'isource_vss 'corr 'wires 'digRegs))"
                )
        isource_vss=hiCreateStringField(
                ?name 'isource_vss
                ?prompt "isource_vss: "
                ?focusInCallback "save_current_field_value(\"isource_vss\")"
                ?callback "sync_addition_execlusive_removal('isource_vss list('electrical) list('vsource 'isource_vdd 'corr 'wires 'digRegs))"
                )
        digRegs=hiCreateStringField(
                ?name 'digRegs 
                ?prompt "dig Regs: "
                ?focusInCallback "save_current_field_value(\"digRegs\")"
                ?callback "sync_addition_execlusive_removal('digRegs list('wires) list('electrical 'vsource 'isource_vss 'isource_vdd 'corr))"
                )
        traverse=hiCreateBooleanButton(
                ?name 'traverse
                ?buttonText "traverse"
                ?buttonLocation 'left
                ?defValue nil
                )
        corr=hiCreateStringField(
                ?name 'corr 
                ?prompt "corr: "
                ?focusInCallback "save_current_field_value(\"corr\")"
                ?callback "sync_addition_execlusive_removal('corr list('wires) list('electrical 'vsource 'isource_vss 'isource_vdd 'digRegs))"
                )
        wires=hiCreateStringField(
                ?name 'wires
                ?prompt "wires: "
                ?focusInCallback "save_current_field_value(\"wires\")"
                ?callback "sync_addition_execlusive_removal('wires list() list('electrical 'vsource 'isource_vss 'isource_vdd))"
                )
        sep3=hiCreateSeparatorField(?name 'sep3)
        genVAMSFile=hiCreateButton(
                ?name 'genVAMSFile
                ?buttonText "Gen VAMS File"
                ?callback "genVAMSFile()"
                )
        viewVAMSFile=hiCreateButton(
                ?name 'viewVAMSFile
                ?buttonText "View VAMS File"
                ?callback "viewVAMSFile()"
                )
        genVAMSCellView=hiCreateButton(
                ?name 'genVAMSCellView
                ?buttonText "Gen VAMS CellView"
                ?callback "genVAMSCellView()"
                )
        viewVAMSCellView=hiCreateButton(
                ?name 'viewVAMSCellView
                ?buttonText "View VAMS CellView"
                ?callback "viewVAMSCellView()"
                )
        coVAMSCellView=hiCreateButton(
                ?name 'coVAMSCellView
                ?buttonText "Checkout VAMS CellView"
                ?callback "coVAMSCellView()"
                )
        removeVAMSFile=hiCreateButton(
                ?name 'removeVAMSFile
                ?buttonText "Remove VAMS File"
                ?callback "removeVAMSFile()"
                )
        printDefine=hiCreateButton(
                ?name 'printDefine
                ?buttonText "Print Define"
                ?callback "printDefine()"
                )
        setDig=hiCreateButton(
                ?name 'setDig
                ?buttonText "SetDig Value"
                ?callback "setDigForm()"
                )
        saveSettings=hiCreateButton(
                ?name 'saveSettings
                ?buttonText "Save Settings"
                ?callback "saveSettings()"
                )
        loadSettings=hiCreateButton(
                ?name 'loadSettings
                ?buttonText "Load Settings"
                ?callback "loadSettings()"
                )
        clearSettings=hiCreateButton(
                ?name 'clearSettings
                ?buttonText "Clear Settings"
                ?callback "clearSettings()"
                )
        genTestBench=hiCreateButton(
                ?name 'genTestBench
                ?buttonText "Gen TestBench"
                ?callback "genTestBench()"
                )
        openTestBench=hiCreateButton(
                ?name 'openTestBench
                ?buttonText "Open TestBench"
                ?callback "openTestBench()"
                )
        view_test_file_btn = hiCreateButton(
                ?name 'view_test_file_btn
                ?buttonText "View Test File"
                ?callback "view_test_file()"
                )
        gen_test_file_btn = hiCreateButton(
                ?name 'gen_test_file_btn
                ?buttonText "Gen Test File"
                ?callback "gen_test_file()"
                )
        reloadScript=hiCreateButton(
                ?name 'reloadScript
                ?buttonText "Reload Script"
                ?callback "reloadScript()"
                )
        yoffset = 0
        yoffset1 = yoffset + 160
        yoffset2 = yoffset1 + 160
        xoffset2 = 0 
        hiCreateAppForm(
            ?name 'tbSelectionForm
            ?formTitle "Choose the cell to generate verilogams view"
            ?callback 'oferExampleFormCB
            ?dontBlock t
            ?fields
                list(
                    list(libName 0:yoffset 300:30 150)
                    list(cellName 300:yoffset 300:30 150)
                    list(viewName 600:yoffset 300:30 150)
                    list(getFromDgcv 100:yoffset+30 100:25)
                    list(getFromCss 200:yoffset+30 100:25)
                    list(loadLast 300:yoffset+30 100:25)
                    list(browse 400:yoffset+30 100:25)
                    list(readPins 500:yoffset+30 100:25)
                    list(openCellView 600:yoffset+30 100:25)
                    list(genWrapper 700:yoffset+30 100:25)
                    list(findMismatch 800:yoffset+30 100:25)
                    ;list(sep1 0:yoffset+125 600:0)
                    list(inputPins 0:yoffset+60 900:30 150)
                    list(outputPins 0:yoffset+90 900:30 150)
                    list(inoutPins 0:yoffset+120 900:30 150)
                    list(sep2 0:yoffset+155 900:0)
                    list(tgtLibName 0:yoffset1 300:30 150)
                    list(tgtCellName 300:yoffset1 300:30 150)
                    list(tgtViewName 600:yoffset1 300:30 150)
                    list(extract_vams 50:yoffset1+30 100:25)
                    list(tgtbrowse 150:yoffset1+30 100:25)
                    list(copyAllPins 100+150:yoffset1+30 100:25)
                    list(copyAllPinsReverse 200+150:yoffset1+30 100:25)
                    ;list(copyInPinsOut 300+150:yoffset1+30 100:25)
                    ;list(copyOutPinsIn 400+150:yoffset1+30 100:25)
                    list(needSensitivity 300+150:yoffset1+30 100:25)
                    list(traditional 400+150:yoffset1+30 100:25)
                    list(group 500+150:yoffset1+30 100:25)
                    list(i2c 600+150:yoffset1+30 100:25)
                    list(top 700+150:yoffset1+30 100:25)
                    list(tgtinputPins 0:yoffset1+60 900:30 150)
                    list(tgtoutputPins 0:yoffset1+90 900:30 150)
                    list(tgtinoutPins 0:yoffset1+120 900:30 150)
                    list(sep3 0:yoffset1+155 900:0)
                    list(vdd 0:yoffset2 300:30 150)
                    list(vss 300:yoffset2 200:30 50)
                    list(testName 500:yoffset2 300:30 100)
                    list(test_ext 800:yoffset2 100:30 100)
                    list(electrical 0:yoffset2+30 900:30 150)
                    list(vsource 0:yoffset2+60 900:30 150)
                    list(isource_vdd 0:yoffset2+90 900:30 150)
                    list(isource_vss 0:yoffset2+120 900:30 150)
                    list(digRegs 0:yoffset2+150 850:30 150)
                    list(traverse 850:yoffset2+150 100:25)
                    list(corr 0:yoffset2+180 900:30 150)
                    list(wires 0:yoffset2+210 900:30 150)
                    list(genVAMSFile xoffset2+150:yoffset2+240 150:25)
                    list(viewVAMSFile xoffset2+300:yoffset2+240 150:25)
                    list(removeVAMSFile xoffset2+450:yoffset2+240 150:25)
                    list(printDefine xoffset2+600:yoffset2+240 150:25)
                    list(setDig xoffset2+750:yoffset2+240 150:25)
                    list(genVAMSCellView xoffset2+150:yoffset2+270 150:25)
                    list(override xoffset2+300:yoffset2+270 100:25)
                    list(genSymbol xoffset2+365:yoffset2+270 100:25)
                    list(saveSettings xoffset2+450:yoffset2+270 150:25)
                    list(loadSettings xoffset2+600:yoffset2+270 150:25)
                    list(clearSettings xoffset2+750:yoffset2+270 150:25)
                    list(viewVAMSCellView xoffset2+150:yoffset2+300 150:25)
                    list(check_out xoffset2+300:yoffset2+300 100:25)
                    list(genTestBench xoffset2+370:yoffset2+300 150:25)
                    list(overridetb xoffset2+520:yoffset2+300 100:25)
                    list(openTestBench xoffset2+600:yoffset2+300 150:25)
                    list(view_test_file_btn xoffset2+600:yoffset2+330 150:25)
                    list(gen_test_file_btn xoffset2+370:yoffset2+330 150:25)
                    list(reloadScript xoffset2+750:yoffset2+300 150:25)
                    list(coVAMSCellView xoffset2+150:yoffset2+330 150:25)
                    )
            ?unmapAfterCB t
            ?minSize 960:700
            )
        ; store the extra fields on the form, ready for later
        tbSelectionForm
        )
    )

/***************************************************************
*                                                              *
*                   oferCreateUserDataForm()                   *
*                                                              *
*                  Creates the user data form                  *
*                                                              *
***************************************************************/
procedure(getFromCss()
    let(()
        getFromInst(css())
    )
)

procedure(getFromDgcv()
    let(()
        getFromInst(deGetCellView())
    )
)

procedure(getFromInst(inst)
    let(()
        if(inst then
            if(inst~>libName get(tbSelectionForm 'libName)->value = inst~>libName)
            if(inst~>cellName get(tbSelectionForm 'cellName)->value = inst~>cellName)
            if(inst~>viewName get(tbSelectionForm 'viewName)->value = inst~>viewName)
            readPins()
            ;clearFields()
        else
            displayErrBox("You didnot specify a valid cell.\n")
        )
    )
)

procedure(readPins()
    let((origLibName origCellName origViewName origObj inTable inoutTable outTable otherTable term allInputPins
    allOutputPins allInoutPins pinIndex allPins vsup vgnd)
        origLibName = get(tbSelectionForm 'libName)->value
        origCellName = get(tbSelectionForm 'cellName)->value
        origViewName = get(tbSelectionForm 'viewName)->value
        if(origObj = dbOpenCellViewByType(origLibName origCellName origViewName) then
            inTable = makeTable("all in pins")
            inoutTable = makeTable("all inout pins")
            outTable = makeTable("all out pins")
            otherTable = makeTable("all other pins")
            foreach(term origObj~>terminals
                case(term~>direction
                    ("input" inTable[term~>name] = 1)
                    ("output" outTable[term~>name] = 1)
                    ("inputOutput" inoutTable[term~>name] = 1)
                    (t otherTable[term~>name] = 1 printf("%s\n" term~>name))
                )
            )
            vsup = car(setof(x origObj~>terminals~>name (rexMatchp("vdd$" lowerCase(x)) || rexMatchp("vdd[a-z]$" lowerCase(x)))))
            unless(vsup vsup = "VDD")
            rexCompile("<.*")
            vsup = rexReplace(vsup "" 0)
            vgnd = car(setof(x origObj~>terminals~>name rexMatchp("vss$" lowerCase(x))  || rexMatchp("vss[a-z]$" lowerCase(x))))
            unless(vgnd vgnd = "VSS")
            vgnd = rexReplace(vgnd "" 0)
            allInputPins = buildString(sort(inTable->? 'alphalessp) " ")
            allOutputPins = buildString(sort(outTable->? 'alphalessp) " ")
            allInoutPins = buildString(sort(inoutTable->? 'alphalessp) " ")
            if(length(otherTable->?) >= 1 then 
                displayWarnBox("Some pins have unknown direction")
            else
                if(length(inTable->?) + length(outTable->?) + length(inoutTable->?) == 0 then 
                    displayWarnBox("No pins in the specified view..")
                else
                )
            )
            pinIndex = 0
            allPins = list(allInputPins allOutputPins allInoutPins)
            foreach(key '(inputPins outputPins inoutPins)
                pinIndex = pinIndex + 1
                get(tbSelectionForm key)->value = nthelem(pinIndex allPins)
            )
            get(tbSelectionForm 'vdd)->value = vsup
            get(tbSelectionForm 'vss)->value = vgnd
            ;get(tbSelectionForm 'electrical)->value = strcat(vsup " " vgnd " SUB")
            get(tbSelectionForm 'electrical)->value = strcat(vsup " " vgnd " SUB")
            printf("All the pins are succefully read\n")
        else
            displayErrBox("You didnot specify a valid cell.\n")
        )
        saveLast()
    )
)

procedure(toggleTraditional()
    let(()
        if(!get(tbSelectionForm 'group)->value 
            get(tbSelectionForm 'traditional)->value = t
            ;if not group together, then if must be traditional such that they run from line to line
        )
        if(!get(tbSelectionForm 'traditional)->value 
            get(tbSelectionForm 'group)->value = t
            ;if not group together, then if must be traditional such that they run from line to line
        )
    )
)

procedure(copyAllPinsReverse()
    let((pinIndex allPins key libName userName)
        copyInPinsOut()
        copyOutPinsIn()
        userName = getShellEnvVar("USER")
        oLibName = get(tbSelectionForm 'libName)->value
        pinIndex = 0
        ;libName = if(deGetCellView() deGetCellView()~>libName if(rexMatchp(strcat(userName "$") oLibName) oLibName strcat(oLibName "_" userName)))
        ;libName = if(rexMatchp(strcat(userName "$") oLibName) oLibName strcat(oLibName "_" userName))
        libName = get_my_lib(oLibName)
        allPins = list(libName strcat("STIM_" get(tbSelectionForm 'cellName)->value) "verilogams")
        foreach(key '(tgtLibName tgtCellName tgtViewName)
            pinIndex += 1
            get(tbSelectionForm key)->value = nthelem(pinIndex allPins)
        )
        get(tbSelectionForm 'traverse)->value = t
        ;get(tbSelectionForm 'corr)->value = get(tbSelectionForm 'tgtinputPins)->value 
        ;if(get(tbSelectionForm 'testName)->value == "" || get(tbSelectionForm 'testName)->value == "Test_"  get(tbSelectionForm 'testName)->value = strcat("Test_" get(tbSelectionForm 'cellName)->value ))
        saveLast()
    )
)

procedure(get_my_lib(in_lib)
    let((my_lib verify_lib lib_name)
        my_lib = ""
        verify_lib = ""
        foreach(lib_name ddGetLibList()~>name
            if(rexMatchp(getShellEnvVar("USER") lib_name) then
                my_lib = lib_name
            )
            if(rexMatchp("verification" lib_name) then
                verify_lib = lib_name
            )
        )
        my_lib = if(my_lib == "" && verify_lib != "" verify_lib if(my_lib == "" in_lib my_lib))
    )
)

procedure(copyInPinsOut()
    let((origInputPins origInoutPins pinIndex allPins key pinIndex)
        origInputPins = get(tbSelectionForm 'inputPins)->value
        origInoutPins = get(tbSelectionForm 'inoutPins)->value

        pinIndex = 0
        allPins = list(origInputPins origInoutPins)
        foreach(key '(tgtoutputPins tgtinoutPins)
            pinIndex += 1
            get(tbSelectionForm key)->value = nthelem(pinIndex allPins)
        )
        printf("All the in/inout pins are succefully reversed copied\n")
    )
)

procedure(copyAllPins()
    let((origInputPins origInoutPins pinIndex allPins key pinIndex origOutputPins)
        origInputPins = get(tbSelectionForm 'inputPins)->value
        origInoutPins = get(tbSelectionForm 'inoutPins)->value
        origOutputPins = get(tbSelectionForm 'outputPins)->value

        pinIndex = 0
        allPins = list(origInputPins origInoutPins origOutputPins)
        foreach(key '(libName cellName)
            allPins = append1(allPins get(tbSelectionForm key)->value)
        )
        ;allPins = append1(allPins "verilogams")
        ;foreach(key '(tgtinputPins tgtinoutPins tgtoutputPins tgtLibName tgtCellName tgtViewName)
        foreach(key '(tgtinputPins tgtinoutPins tgtoutputPins tgtLibName tgtCellName)
            pinIndex += 1
            get(tbSelectionForm key)->value = nthelem(pinIndex allPins)
        )
        get(tbSelectionForm 'traverse)->value = nil
        ;get(tbSelectionForm 'corr)->value = get(tbSelectionForm 'tgtinputPins)->value 
        printf("All the pins are succefully copied\n")
        saveLast()
    )
)

procedure(copyOutPinsIn()
    let((pinIndex allPins key pinIndex origOutputPins)
        origOutputPins = get(tbSelectionForm 'outputPins)->value

        pinIndex = 0
        allPins = list(origOutputPins)
        foreach(key '(tgtinputPins)
            pinIndex += 1
            get(tbSelectionForm key)->value = nthelem(pinIndex allPins)
        )
        saveLast()
        printf("Output pins are succefully reversed copied\n")
    )
)

procedure(genVAMSFile(@optional (topDef 0))
    let((instCellName instLibName instViewName termDirTable termRangeTable extractedRangeTable inputPinList
    inputPinNameList inputPinNameRangeList outputPinList outputPinNameList outputPinNameRangeList inoutPinList
    inoutPinNameList inoutPinNameRangeList allPinList listInd pinList extractedInfoList extractedNameList
    extractedNameRangeList termDir termName vamsFileStr pinInd pin listPinsList electricalInfoList electricalTable vamsFile ofileH instTable test_module_name
    sourceInstList strBefore strAfter termSym corrStr viewExt I2CModuleStr)
        toggleTraditional()
        origLibName = get(tbSelectionForm 'libName)->value
        origCellName = get(tbSelectionForm 'cellName)->value
        origViewName = get(tbSelectionForm 'viewName)->value
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        viewExt = getViewExt(instViewName)
        termDirTable = makeTable("Table for instance pins direction")
        termRangeTable = makeTable("Table for instance pins range")
        extractedRangeTable = makeTable("Table for the storage of extracted range table")
        inputPinList = parseString(get(tbSelectionForm 'tgtinputPins)->value)
        inputPinNameList = list()
        inputPinNameRangeList = list()
        outputPinList = parseString(get(tbSelectionForm 'tgtoutputPins)->value)
        outputPinNameList = list()
        outputPinNameRangeList = list()
        inoutPinList = parseString(get(tbSelectionForm 'tgtinoutPins)->value)
        inoutPinNameList = list()
        inoutPinNameRangeList = list()
        allPinList = list(inputPinList outputPinList inoutPinList)
        listInd = 0
        foreach(pinList allPinList
            listInd += 1
            extractedInfoList = extractPinList(pinList)
            extractedNameList = car(extractedInfoList)
            extractedNameRangeList = cadr(extractedInfoList)
            extractedRangeTable = caddr(extractedInfoList)
            termDir = ""
            case(listInd
                (1
                    termDir = "input"
                    inputPinNameList = extractedNameList
                    inputPinNameRangeList = extractedNameRangeList
                )
                (2
                    termDir = "output"
                    outputPinNameList = extractedNameList
                    outputPinNameRangeList = extractedNameRangeList
                )
                (3
                    termDir = "inout"
                    inoutPinNameList = extractedNameList 
                    inoutPinNameRangeList = extractedNameRangeList
                )
            )
            foreach(termName extractedRangeTable
                if(member(termName termRangeTable->?) then
                    if(termRangeTable[termName] != extractedRangeTable[termName] displayWarnBox(sprintf(nil "%s appeared before and is a different range definition.\n" termName )))
                    if(termDirTable[termName] != termDir displayWarnBox(sprintf(nil "%s appeared before and is a different direction definition.\n" termName )))
                else
                    termDirTable[termName] = termDir
                    termRangeTable[termName] = extractedRangeTable[termName]
                )
            )
        )
        vamsFileStr = sprintf(nil "%s" vamsHeaderTgt())
        if(topDef == 1 then
            vamsFileStr = sprintf(nil "%s%s", vamsFileStr, vamsTopDef())
        )
        electricalInfoList = extractMergePins('(electrical vsource isource_vdd isource_vss vdd vss))
        electricalTable = caddr(electricalInfoList)
        listPinsList = list(inputPinNameRangeList inputPinNameList outputPinNameRangeList outputPinNameList inoutPinNameRangeList inoutPinNameList)
        ;printf("748 i am here. %s.\n", vamsFileStr)
        vamsFileStr = sprintf(nil "%s%s", vamsFileStr, pinListDefs(listPinsList electricalInfoList termDirTable termRangeTable))
        ;printf("750 i am here. %s.\n", pinListDefs(listPinsList electricalInfoList termDirTable termRangeTable))
        ;electricalInfoList is a list of extractedPinList
        test_module_name = get_test_module_name()
        if(rexMatchp("^STIM" get(tbSelectionForm 'tgtCellName)->value) vamsFileStr = sprintf(nil "%s\n    %s %s();\t //Test module to test the design\n", vamsFileStr, test_module_name, "TEST"))
        I2CModuleStr = "wire vSCL, vSDA;\n    i2c_stim I2C(vSCL, vSDA, SDA);\t //I2C module\n"
        I2CModuleStr = strcat(I2CModuleStr "    assign SDA = vSDA? 1'bz : 1'b0; \n    assign SCL = vSCL? 1'bz : 1'b0;")
        if(get(tbSelectionForm 'i2c)->value && rexMatchp("^STIM" get(tbSelectionForm 'tgtCellName)->value) vamsFileStr = sprintf(nil "%s\n    %s\n", vamsFileStr, I2CModuleStr))
        if(rexMatchp("^STIM" get(tbSelectionForm 'tgtCellName)->value) vamsFileStr = sprintf(nil "%s    ground %s;\n", vamsFileStr get(tbSelectionForm 'vss)->value))
        if(rexMatchp("^STIM" get(tbSelectionForm 'tgtCellName)->value) && member("SUB" electricalTable->?) vamsFileStr = sprintf(nil "%s    ground %s;\n", vamsFileStr "SUB"))
        instTable = makeTable("instance tables")
        ;printf("758 i am here. %s.\n", vamsFileStr)
        sourceInstList = getAllSourceStr(instTable)
        regInstList = car(getAllReg(electricalTable->?))
        corrStr = printCorr(electricalTable->?)
        if(corrStr != "" vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr, corrStr))
        if(car(sourceInstList) != "" vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr,car(sourceInstList)))
        if(car(regInstList) != "" vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr,car(regInstList)))
        printf("750 i am here. %s.\n", vamsFileStr)
        if(car(cddr(cddr(sourceInstList))) != "" then
            vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr,car(cddr(cddr(sourceInstList)))) ;print out the initvalue sentenses
            vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr,cadr(cddr(cddr(sourceInstList)))) ;print out set_initial_task
            vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr,car(cdddr(sourceInstList))) ;print out the initial block
        )
        if(cadr(sourceInstList) != "" vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr,cadr(sourceInstList))) ;task string
        if(cadr(regInstList) != "" vamsFileStr = sprintf(nil "%s%s\n", vamsFileStr,cadr(regInstList)))
        vamsFileStr = sprintf(nil "%s\nendmodule\n//end of module %s\n\n", vamsFileStr, get(tbSelectionForm 'tgtCellName)->value)
        ;rexCompile("\\([^ ]\\)  \\([^ ]\\)")
        ;while(rexExecute(vamsFileStr) 
        ;    strBefore = rexSubstitute("\\1")
        ;    strAfter = rexSubstitute("\\2")
        ;    vamsFileStr = rexReplace(vamsFileStr strcat(strBefore " " strAfter) 0)
        ;)
        rexCompile("\\]  ")
        vamsFileStr = rexReplace(vamsFileStr "] " 0)

        printf("%s", vamsFileStr)
        vams_temp_dir = strcat(pwd() "/vams_temp")
        os_makedir(vams_temp_dir)
        vamsFile = sprintf(nil "%s/%s_%s_%s.vams" vams_temp_dir, instLibName, instCellName, instViewName)
        saveLast()
        writeToFile(vamsFileStr vamsFile)
        vamsFile
    )
)

procedure(extractPinList(inList)
    let((pinRangeTable pinNameList pinNameRangeList pin termName termRange singleTerm errMsg term_list)
        saveLast()
        pinRangeTable = makeTable("Table for instance pins range")
        pinList = list()
        pinNameList = list()
        pinNameRangeList = list()
        ;foreach(pin sort(inList 'alphalessp)
        foreach(pin inList
            term_list = extract_pin(pin)
            termName = car(term_list)
            termRange = cadr(term_list)
            unless(member(termName pinList)
                pinList = append1(pinList termName)
            )
            if(member(termName pinRangeTable->?) then
                errMsg = sprintf(nil "%s is double defined as %s vs %s\n" termName pinRangeTable[termName] termRange)
                displayWarnBox(errMsg)
                pinRangeTable[termName] = strcat(termRange pinRangeTable[termName])
            else
                if(termRange == "" pinNameList = append1(pinNameList termName) pinNameRangeList = append1(pinNameRangeList termName))
                pinRangeTable[termName] = termRange
            )
        )
        saveLast()
        list(pinNameList pinNameRangeList pinRangeTable pinList) ;extract the inList to be pins with range, without range, and the range table
    )
)

procedure(extract_pin(in_pin)
    let((termName termRange singleTerm)
        termName = in_pin
        termRange = ""
        rexCompile("\\(..*\\)\\(<.*>\\)")
        if(rexExecute(termName) then
            termName = rexSubstitute("\\1")
            termRange = rexSubstitute("\\2")
        else
            rexCompile("\\(<.*>\\)\\(..*\\)")
            if(rexExecute(termName) then
                termName = rexSubstitute("\\2")
                termRange = rexSubstitute("\\1")
            )
        )
        if(termRange != "" then
            if(rexMatchp("\\*", termRange) then 
                termRange = ""
            else
                rexCompile("<")
                termRange = rexReplace(termRange "[" 0)
                rexCompile(">")
                termRange = rexReplace(termRange "]" 0)
                unless(rexMatchp(":" termRange)
                    rexCompile("\\[\\(.*\\)\\]")
                    rexExecute(termRange)
                    singleTerm = evalstring(rexSubstitute("\\1"))
                    termRange = rexReplace(termRange sprintf(nil "[%d:%d]" singleTerm singleTerm) 0)
                )
                termRange = strcat(termRange " ")
            )
        else
            termRange = ""
        )
        list(termName termRange)
    )
)

procedure(vamsTopDef()
    let((vamsTop instLibName instCellName instViewName inst topName )
        saveLast()
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        vamsTop = sprintf(nil "`ifndef top\n")
        if(deGetCellView() topName = deGetCellView()~>cellName topName = strcat("TB_" get(tbSelectionForm 'cellName)->value))
        vamsTop = sprintf(nil "%s\t`define top%s%s\n", vamsTop printNumOfBlanks(30-strlen("`define top")) topName)
        vamsTop = sprintf(nil "%s`endif\n", vamsTop)
        vamsTop = sprintf(nil "%s`ifndef stim\n", vamsTop)
        companionName = "stim"
        if(deGetCellView() then
            foreach(inst deGetCellView()~>instances
                if(inst~>libName == instLibName && inst~>cellName == instCellName companionName = inst~>name)
            )
        )
        vamsTop = sprintf(nil "%s\t`define stim%s%s.%s\n", vamsTop printNumOfBlanks(30-strlen("`define stim")) "`top" companionName)
        vamsTop = sprintf(nil "%s`endif\n\n", vamsTop)
    )
)

procedure(vamsHeaderWrapper(instCellName)
    let((vamsHeaderStr instLibName instViewName wrapperExplain )
        instLibName = get(tbSelectionForm 'libName)->value
        instViewName = "verilogams"
        vamsHeaderStr = vamsHeaderGeneral(instLibName instCellName instViewName)
        wrapperExplain = "//The internal connections are required such that they will not be simply pass through and the connect modules can be applied.\n"
        vamsHeaderStr = strcat(vamsHeaderStr "\n" wrapperExplain)
    )
)

procedure(vamsHeaderTgt()
    let((vamsHeaderStr instLibName instCellName instViewName)
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        vamsHeaderStr = vamsHeaderGeneral(instLibName instCellName instViewName)
    )
)

procedure(vamsHeaderGeneral(instLibName instCellName instViewName)
    let((vamsHeaderStr viewName viewExt)
        saveLast()
        viewExt = getViewExt(instViewName)
        viewName = getViewName(viewExt)
        vamsHeaderStr = sprintf(nil "//%s HDL for <%L, %L, %L> by %s\n", viewName, instLibName, instCellName, instViewName getShellEnvVar("USER"))
        vamsHeaderStr = sprintf(nil "%s//on %s\n\n", vamsHeaderStr getCurrentTime())
        if(viewExt == "vams" then
            vamsHeaderStr = sprintf(nil "%s`include %L\n", vamsHeaderStr "constants.vams")
            vamsHeaderStr = sprintf(nil "%s`include %L\n", vamsHeaderStr "disciplines.vams")
            vamsHeaderStr = sprintf(nil "%s`timescale 1ns/1ps\n\n", vamsHeaderStr)
        else
            vamsHeaderStr = sprintf(nil "%s`include %L\n", vamsHeaderStr "./rnm_include.sv")
        )
    )
)


procedure(printExtractedPinList(pinDef extractedInfoList @optional (areDigitalPins nil) (execludeList list()))
    let((extractedNameList extractedNameRangeList extractedRangeTable listInd pinInd pin pinList termRanges termRange newPinDef
    printStr vdd vss senseStr endSp termRanges )
        extractedNameList = car(extractedInfoList)
        extractedNameRangeList = cadr(extractedInfoList)
        extractedRangeTable = caddr(extractedInfoList)
        vdd = get(tbSelectionForm 'vdd)->value
        vss = get(tbSelectionForm 'vss)->value
        senseStr = ""
        if(areDigitalPins && getSensitivity() senseStr =  sprintf(nil "(* integer supplySensitivity = %L;integer groundSensitivity = %L;*)", vdd, vss ))

        listInd = 0
        printStr = ""
        if(length(execludeList)>0 then
            foreach(pin execludeList printf("%s\t ",pin))
        )
        foreach(pinList list(extractedNameRangeList extractedNameList )
            listInd += 1
            pinInd = 0
            foreach(pin pinList
                unless(member(pin execludeList)
                    termRange = extractedRangeTable[pin]
                    pinInd += 1
                    if(remainder(listInd, 2) == 1  then
                        newPinDef = strcat(" " pinDef " ")
                        endSp = ";\n"
                        termRanges = if(rexMatchp(" " termRange) list(getTotalRange(termRange)) list(termRange))
                        foreach(termRange termRanges 
                            printStr = sprintf(nil "%s    %s %s %s %s%s", printStr, newPinDef, termRange, senseStr, pin, endSp)
                        )
                    else 
                        endSp = ", "
                        if((remainder(listInd , 2) == 0) && pinInd == 1 then
                            newPinDef = strcat("    " pinDef " ")
                        else
                            newPinDef = ""
                        )
                        if(remainder(pinInd, 8)==6 printStr = sprintf(nil "%s\n          ", printStr))
                        printStr = sprintf(nil "%s%s%s%s%s%s", printStr, newPinDef, termRange, senseStr, pin, endSp)
                    )
                )
            )
        )
        if(rexCompile(", \n* *$") then
            printStr = rexReplace(printStr, "; ", 0)
        )
        printStr = rexReplace(printStr, "; ", 0)
        printStr = sprintf(nil "%s\n", printStr)
        printStr
    )
)

procedure(extractMergePins(mergeList)
    let((pins key extractedpinList pinList)
        saveLast()
        pins = ""
        foreach(key mergeList
            pins = strcat(pins " " get(tbSelectionForm key)->value)
        )
        pinList = parseString(pins)
        pinList = uniqueList(pinList) ;make it a unique list
        extractedPinList = extractPinList(pinList)
        extractedPinList
    )
)

procedure(printMergePins(mergeList pinDef @optional (areDigitalPins nil) (excludeList list()))
    let((pins key extractedpinList pinList mergePrintStr)
        saveLast()
        pins = ""
        foreach(key mergeList
            pins = strcat(pins " " get(tbSelectionForm key)->value)
        )
        pinList = parseString(pins)
        pinList = uniqueList(pinList) ;make it a unique list
        extractedPinList = extractPinList(pinList)
        mergePrintStr = sprintf(nil "%s", printExtractedPinList(pinDef, extractedPinList, areDigitalPins, excludeList))
        list(mergePrintStr extractedPinList)
    )
)

procedure(pinListPrint(inPinList dirTable rangeTable)
    let((pinInd allPinInd listInd allPinComma fileStr1 fileStr2 rangeWireStr
        singleWireStr singleWireStart singleWireLen rangeElecStr singleElecStr
        singleElecStart singleElecLen tableElecPin trad grp vdd vss elecList instViewName viewExt
        pinLen pinList pin termRanges termDDef termRange senseStr isElec pinDis bagSpace endSpace termSym termDir
        strInd str leftElecPinStr termRange2 match )

        pinInd = 0
        match = 0
        allPinInd = 0
        listInd = 0
        allPinComma = ""
        fileStr1 = "" ;pin direction declaration
        fileStr2 = strcat("module " get(tbSelectionForm 'tgtCellName)->value "(")
        rangeWireStr = "" ;ranged wire declaration
        singleWireStr = "" ;single wire declaration
        singleWireStart = 0
        singleWireLen = 0
        rangeElecStr = "" ;ranged wire declaration
        singleElecStr = "" ;single wire declaration
        singleElecStart = 0
        singleElecLen = 0
        tableElecPin = makeTable("table to see if pin is electrical") ;
        trad = get(tbSelectionForm 'traditional)->value
        grp = get(tbSelectionForm 'group)->value
        vdd = get(tbSelectionForm 'vdd)->value
        vss = get(tbSelectionForm 'vss)->value
        electricalInfoList = extractMergePins('(electrical vsource isource_vdd isource_vss vdd vss))
        electricalTable = caddr(electricalInfoList)
        elecList = caddr(electricalInfoList)->?
        tgtCellName = get(tbSelectionForm 'tgtCellName)->value
        tgtLibName = get(tbSelectionForm 'tgtLibName)->value
        tgtViewName = get(tbSelectionForm 'tgtViewName)->value
        instCellName = get(tbSelectionForm 'cellName)->value
        instLibName = get(tbSelectionForm 'libName)->value
        instViewName = get(tbSelectionForm 'viewName)->value
        viewExt = getViewExt(instViewName)
        if(tgtLibName == instLibName && instCellName == tgtCellName  then
            match = 1
        )
        pinLen = 0
        foreach(pin inPinList
        )
        foreach(pinList listPinList
            listInd += 1
            pinInd = 0
            if(length(pinList) > 0 then
                foreach(pin sort(pinList 'alphalessp)
                    allPinInd += 1
                    if(allPinInd == 1 pinLen = strlen(fileStr2))
                    if(pinLen > 60 then
                        allPinComma = strcat(allPinComma "\n" numSpace(4));
                        pinLen = 0
                    ) ; if pinLen > 60 change to new line
                    pinInd += 1
                    senseStr = ""
                    if(member(pin elecList) then 
                        isElec = 1
                        pinDis = "electrical"
                        if(viewExt == "sv" pinDis = "wrealsum")
                    else 
                        isElec = 0
                        pinDis = "wire"
                        if(getSensitivity() senseStr = sprintf(nil "(* integer supplySensitivity = %L;integer groundSensitivity = %L;*) ", vdd, vss))
                    )
                    tableElecPin[pin] = isElec
                    termRange = remove_trailing_following_spaces(rangeTable[pin])
                    ;if(termRange !
                    termDDef = if(rexMatchp(" " termRange) 1 0) ;terminal is double defined
                    termRanges = if(rexMatchp(" " termRange) list(getTotalRange(termRange)) list(termRange))
                    if(termDDef == 1 then
                        foreach(termRange parseString(rangeTable[pin])
                            printf("1004 %s %s\n", pin, termRange)
                            allPinComma = strcat(allPinComma pin termRange ", ");all the pin list in parenthesis
                            pinLen += strlen(pin) + strlen(termRange) + 2
                        )
                    else
                        allPinComma = strcat(allPinComma pin ", ");all the pin list in parenthesis
                        pinLen += strlen(pin) + 2
                    )
                    foreach(termRange termRanges
                        termRange = if(termRange == ""  " " strcat(" " termRange " "))
                        if(remainder(listInd, 2) == 1 then
                            termSym = ";"
                            if(isElec == 1 then
                                rangeElecStr = sprintf(nil "%s    %s%s%s%s\n", rangeElecStr, pinDis, termRange, pin, termSym)
                            else
                                rangeWireStr = sprintf(nil "%s    %s%s%s%s\n", rangeWireStr, pinDis, termRange, pin, termSym)
                            )
                        else
                            termSym = ","
                            if(isElec == 1 then
                                if(singleElecLen >= 60 then
                                    singleElecStr = sprintf(nil "%s\n%s", singleElecStr, numSpace(strlen(pinDis) + 2))
                                    singleElecLen = 0
                                )
                                singleElecLen += strlen(pin) + 2
                                if(singleElecStart == 0 then
                                    singleElecStart = 1
                                    singleElecStr = sprintf(nil "%s    %s%s%s%s", singleElecStr, pinDis, termRange, pin, termSym)
                                else
                                    singleElecStr = sprintf(nil "%s%s%s%s", singleElecStr, termRange, pin, termSym)
                                )
                            else
                                if(singleWireLen >= 60 then
                                    singleWireStr = sprintf(nil "%s\n%s", singleWireStr, numSpace(strlen(pinDis) + 2))
                                    singleWireLen = 0
                                )
                                singleWireLen += strlen(pin) + 2
                                if(singleWireStart == 0 then
                                    singleWireStart = 1
                                    singleWireLen = 0
                                    singleWireStr = sprintf(nil "%s    %s%s%s%s", singleWireStr, pinDis, termRange, pin, termSym)
                                else
                                    singleWireStr = sprintf(nil "%s%s%s%s", singleWireStr, termRange, pin, termSym)
                                )
                            )
                        )
                        if(grp then
                            if(((remainder(listInd, 2) == 1) || ((remainder(listInd , 2) == 0) && pinInd == 1)) then
                                termDir = dirTable[pin]
                            else
                                termDir = ""
                                for(i 0 strlen(dirTable[pin])-1 termDir = sprintf(nil "%s " termDir))
                            )
                            if(remainder(listInd, 2) == 1 then
                                if(!trad termSym = ", " termSym = ";")
                            else
                                if(or(pinInd != length(pinList) !trad) termSym = ", " termSym = ";")
                            )
                            if(termDDef == 1 then
                                foreach(termRange2 parseString(rangeTable[pin])
                                    termRange2 = strcat(" " termRange2 " ")
                                    fileStr1 = sprintf(nil "%s    %s%s%s%s%s\t//\n", fileStr1, termDir, termRange2, senseStr, pin, termSym)
                                )
                            else
                                fileStr1 = sprintf(nil "%s    %s%s%s%s%s\t//\n", fileStr1, termDir, termRange, senseStr, pin, termSym)
                            )
                        else
                            termDir = dirTable[pin]
                            termSym = ";"
                            bagSpace = if(strlen(senseStr) > 10  "\n    " numSpace(16 - strlen(termDir)- strlen(pin) - strlen(termRange)))
                            endSpace = if(strlen(senseStr) > 10  "\t//\n" "\t//\n")
                            fileStr1 = sprintf(nil "%s    %s%s%s%s%s%s%s%s%s%s%s", fileStr1, termDir, termRange, senseStr, pin, termSym, bagSpace, pinDis, termRange, pin, termSym, endSpace)
                        )
                    )
                )
            )
        )
        rexCompile(", $")
        allPinComma = rexReplace(allPinComma, "", 0)
        if(or(!grp trad) then
            fileStr2 = strcat(fileStr2 allPinComma ");\n")
            if(match == 1 && ddGetObj(instLibName instCellName "symbol") then
                sym_module_info = get_pin_order_info_from_symbol(instLibName instCellName)
                fileStr2 = strcat(cadr(sym_module_info) "\n")
            )
            fileStr2 = strcat(fileStr2 fileStr1)
        else
            rexCompile(", *\t//\n$")
            fileStr1 = rexReplace(fileStr1, "" 0)
            fileStr2 = strcat(fileStr2 "\n" fileStr1 "\n);\n")
        )
        if(or(grp !trad) then
            strInd = 0
            foreach(str list(rangeWireStr singleWireStr rangeElecStr singleElecStr)
                strInd += 1
                if(str != "" then 
                    if(remainder(strInd 2) == 0 then
                        rexCompile(", *$")
                        str = rexReplace(str, ";\n" 0)
                    )
                    fileStr2 = strcat(fileStr2 str)
                )
            )
        )
        fileStr2 = strcat(fileStr2 "//end of pin definitions.\n")
        ;leftover electrical pins
        pinDis = if(viewExt == "sv" "wrealsum" "electrical")
        leftElecPinStr = printExtractedPinList(pinDis, elecInfoList, nil, tableElecPin->?)
        fileStr2 = strcat(fileStr2 leftElecPinStr)
        fileStr2
    ) ; let
)

procedure(pinListDefs(listPinList elecInfoList dirTable rangeTable)
    let((pinInd allPinInd listInd allPinComma fileStr1 fileStr2 rangeWireStr instViewName viewExt
        singleWireStr singleWireStart singleWireLen rangeElecStr singleElecStr
        singleElecStart singleElecLen tableElecPin trad grp vdd vss elecList rangesList
        pinLen pinList pin termRanges termDDef termRange senseStr isElec pinDis bagSpace endSpace termSym termDir
        strInd str leftElecPinStr termRange2 pinChkList pinGoodList ichkList pinDefList pinAssignList)

        pinInd = 0
        allPinInd = 0
        listInd = 0
        allPinComma = ""
        fileStr1 = "" ;pin direction declaration
        fileStr2 = strcat("module " get(tbSelectionForm 'tgtCellName)->value "(")
        rangeWireStr = "" ;ranged wire declaration
        singleWireStr = "" ;single wire declaration
        singleWireStart = 0
        singleWireLen = 0
        rangeElecStr = "" ;ranged wire declaration
        singleElecStr = "" ;single wire declaration
        singleElecStart = 0
        singleElecLen = 0
        tableElecPin = makeTable("table to see if pin is electrical") ;
        trad = get(tbSelectionForm 'traditional)->value
        grp = get(tbSelectionForm 'group)->value
        vdd = get(tbSelectionForm 'vdd)->value
        vss = get(tbSelectionForm 'vss)->value
        elecList = caddr(elecInfoList)->?
        pinLen = 0
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        viewExt = getViewExt(instViewName)
        pinChkList = list()
        pinGoodList = list()
        pinDefList = list()
        pinAssignList = list()
        foreach(pinList listPinList
            listInd += 1
            pinInd = 0
            if(length(pinList) > 0 then
                foreach(pin sort(pinList 'alphalessp)
                    allPinInd += 1
                    if(allPinInd == 1 pinLen = strlen(fileStr2))
                    if(pinLen > 60 then
                        allPinComma = strcat(allPinComma "\n" numSpace(4))
                        pinLen = 0
                    ) ; if pinLen > 60 change to new line
                    pinInd += 1
                    senseStr = ""
                    if(member(pin elecList) then
                        isElec = 1
                        pinDis = "electrical"
                        if(viewExt == "sv" pinDis = "wrealsum")
                        ;printf("1215 pinDis = %s, viewExt = %s\n", pinDis, viewExt)
                    else
                        isElec = 0
                        pinDis = "wire"
                        if(and(viewExt == "vams" getSensitivity()) senseStr = sprintf(nil "(* integer supplySensitivity = %L;integer groundSensitivity = %L;*) ", vdd, vss ))
                    )
                    tableElecPin[pin] = isElec
                    termRange = rangeTable[pin]
                    termRange = remove_trailing_following_spaces(termRange)
                    if(and(isElec == 1 dirTable[pin] == "input") then
                        rangesList = getRangesList(termRange)
                        if(length(rangesList) == 0 rangesList = append1(rangesList ""))
                        foreach(rg rangesList
                            ;printf("1250 i am here %s, %s.\n", rg, pin)
                            ichkList = genInputChecks(pin rg)
                            ;printf("1252 i am here.\n")
                            pinChkList = append1(pinChkList car(ichkList))
                            pinGoodList = append1(pinGoodList strcat(cadr(ichkList) "_good"))
                            if(rg != "" then
                                pinDefList  = append1(pinDefList cadr(ichkList))
                                pinAssignList = append1(pinAssignList sprintf(nil "    assign %s = %s[%s];\n", cadr(ichkList), pin, rg))
                            )
                        )
                    )
                    termDDef = if(rexMatchp(" " termRange) 1 0) ;terminal is double defined
                    termRanges = if(rexMatchp(" " termRange) list(getTotalRange(termRange)) list(termRange))
                    if(termDDef == 1 then
                        foreach(termRange parseString(rangeTable[pin]) 
                            allPinComma = strcat(allPinComma pin termRange ", ");all the pin list in parenthesis
                            pinLen += strlen(pin) + strlen(termRange) + 2
                        )
                    else
                        allPinComma = strcat(allPinComma pin ", ");all the pin list in parenthesis
                        pinLen += strlen(pin) + 2
                    )
                    foreach(termRange termRanges
                        termRange2 = termRange
                        termRange2 = if(viewExt == "sv" if(termRange == ""  "" strcat(" " termRange "")) if(termRange == ""  " " strcat(" " termRange " ")))
                        termRange = if(termRange == ""  " " strcat(" " termRange " "))
                        if(remainder(listInd, 2) == 1 then
                            termSym = ";"
                            if(isElec == 1 then
                                if(viewExt == "sv" rangeElecStr = sprintf(nil "%s    %s%s%s%s\n", rangeElecStr, pinDis, pin, termRange, termSym)
                                rangeElecStr = sprintf(nil "%s    %s%s%s%s\n", rangeElecStr, pinDis, termRange, pin, termSym)
                                )
                            else
                                rangeWireStr = sprintf(nil "%s    %s%s%s%s\n", rangeWireStr, pinDis, termRange, pin, termSym)
                            )
                        else
                            termSym = ","
                            if(isElec == 1 then
                                if(singleElecLen >= 60 then
                                    singleElecStr = sprintf(nil "%s\n%s", singleElecStr, numSpace(strlen(pinDis) + 2))
                                    singleElecLen = 0
                                )
                                singleElecLen += strlen(pin) + 2
                                if(singleElecStart == 0 then
                                    singleElecStart = 1
                                    singleElecStr = sprintf(nil "%s    %s%s%s%s", singleElecStr, pinDis, termRange, pin, termSym)
                                else
                                    singleElecStr = sprintf(nil "%s%s%s%s", singleElecStr, termRange, pin, termSym)
                                )
                            else
                                if(singleWireLen >= 60 then
                                    singleWireStr = sprintf(nil "%s\n%s", singleWireStr, numSpace(strlen(pinDis) + 2))
                                    singleWireLen = 0
                                )
                                singleWireLen += strlen(pin) + 2
                                if(singleWireStart == 0 then
                                    singleWireStart = 1
                                    singleWireLen = 0
                                    singleWireStr = sprintf(nil "%s    %s%s%s%s", singleWireStr, pinDis, termRange, pin, termSym)
                                else
                                    singleWireStr = sprintf(nil "%s%s%s%s", singleWireStr, termRange, pin, termSym)
                                )
                            )
                        )
                        if(grp then
                            if(((remainder(listInd, 2) == 1) || ((remainder(listInd , 2) == 0) && pinInd == 1)) then
                                termDir = dirTable[pin]
                            else
                                termDir = ""
                                for(i 0 strlen(dirTable[pin])-1 termDir = sprintf(nil "%s " termDir))
                            )
                            if(remainder(listInd, 2) == 1 then
                                if(!trad termSym = ", " termSym = ";")
                            else
                                if(or(pinInd != length(pinList) !trad) termSym = ", " termSym = ";")
                            )
                            if(termDDef == 1 then
                                foreach(termRange2 parseString(rangeTable[pin])
                                    termRange2 = strcat(" " termRange2 " ")
                                    fileStr1 = sprintf(nil "%s    %s%s%s%s%s\t//\n", fileStr1, termDir, termRange2, senseStr, pin, termSym)
                                )
                            else
                                fileStr1 = sprintf(nil "%s    %s%s%s%s%s\t//\n", fileStr1, termDir, termRange, senseStr, pin, termSym)
                            )
                        else
                            termDir = dirTable[pin]
                            termSym = ";"
                            bagSpace = if(strlen(senseStr) > 10  "\n    " numSpace(16 - strlen(termDir)- strlen(pin) - strlen(termRange)))
                            endSpace = if(strlen(senseStr) > 10  "\t//\n" "\t//\n")
                            if(or(viewExt == "vams" pinDis == "wire")
                                fileStr1 = sprintf(nil "%s    %s%s%s%s%s%s%s%s%s%s%s", fileStr1, termDir, termRange, senseStr, pin, termSym, bagSpace, pinDis, termRange, pin, termSym, endSpace)
                                fileStr1 = sprintf(nil "%s    %s%s%s%s%s%s%s%s%s%s%s", fileStr1, termDir, termRange, senseStr, pin, termSym, bagSpace, pinDis, strcat(" " pin), termRange2, termSym, endSpace)
                            )
                        )
                    )
                )
            )
        )
        rexCompile(", $")
        allPinComma = rexReplace(allPinComma, "", 0)
        if(or(!grp trad) then
            fileStr2 = strcat(fileStr2 allPinComma ");\n")
            fileStr2 = strcat(fileStr2 fileStr1)
        else
            rexCompile(", *\t//\n$")
            fileStr1 = rexReplace(fileStr1, "" 0)
            fileStr2 = strcat(fileStr2 "\n" fileStr1 "\n);\n")
        )
        if(or(grp !trad) then
            strInd = 0
            foreach(str list(rangeWireStr singleWireStr rangeElecStr singleElecStr)
                strInd += 1
                if(str != "" then 
                    if(remainder(strInd 2) == 0 then
                        rexCompile(", *$")
                        str = rexReplace(str, ";\n" 0)
                    )
                    fileStr2 = strcat(fileStr2 str)
                )
            )
        )
        fileStr2 = strcat(fileStr2 "//end of pin definitions.\n")
        ;leftover electrical pins
        ;printf("1371 i am here.\n")
        pinDis = if(viewExt == "sv" "wrealsum" "electrical")
        leftElecPinStr = printExtractedPinList(pinDis, elecInfoList, nil, tableElecPin->?)
        fileStr2 = strcat(fileStr2 leftElecPinStr)
        if(and(viewExt == "sv" length(pinChkList) > 0) then
            if(length(pinDefList) > 0 fileStr2 = strcat(fileStr2 "    real " buildString(pinDefList ", ") ";\n"))
            fileStr2 = strcat(fileStr2 buildString(pinAssignList "") "\n")
            fileStr2 = strcat(fileStr2 buildString(pinChkList "\n") "\n\n")
            fileStr2 = strcat(fileStr2 "    wire block_en = " buildString(pinGoodList " & ") ";\n")
        )
        ;printf("1368 i am here. %s\n", fileStr2)
        fileStr2
    ) ; let
)

procedure(genInputChecks(pinName subNum)
    let((gn agn accu slim sacur spin)
        gn = guessNum(pinName)
        agn = abs(gn)
        if(agn <= 1e-10 then
            accu = 0.1
        else
            if(agn <= 2e-3 then
                accu = agn
            else
                if(agn <= 0.1 then
                    accu = agn / 10
                else
                    accu = 0.1
                )
            )
        )
        slim = sprintf(nil "%1.2e", gn)
        if(gn == 100 slim = sprintf(nil "`sup1_val") if(agn >= 10e-2 slim = sprintf(nil "%1.4f", gn)))
        sacur = if(accu >= 10e-2 sprintf(nil "%1.4f" accu) sprintf(nil "%1.2e" accu))
        spin = sprintf(nil "%s", pinName)
        if(subNum != "" spin = sprintf(nil "%s_%s", spin, subNum))
        list(sprintf(nil "    `def_chk_val(%s, %s, %s)", spin, cleanSNum(slim), cleanSNum(sacur)) spin)
    )
)

procedure(cleanSNum(snum)
    let((mp ep)
        ;printf("%L\n" snum)
        if(! rexMatchp(".*e.*" snum) then
            rexCompile("\\(.*\\.[0-9]*\\)\\(00*\\)$")
            while(rexExecute(snum) snum = rexSubstitute("\\1"))
            ;printf(snum)
            rexCompile("\\(.*\\.\\)$")
            if(rexExecute(snum) snum = strcat(snum "0"))
        else
            rexCompile("\\(.*\\)e\\(.*\\)")
            if(rexExecute(snum) then
                mp = rexSubstitute("\\1")
                ep = rexSubstitute("\\2")
                mp = cleanSNum(mp)
                ep = cleanSNum(ep)
                snum = strcat(mp "e" ep)
            )
        )
        if(snum == "0.0e+00" "0.0" snum)
    )
)

procedure(guessNum(pinName)
    let((lpin pval rval sn)
        lpin = lc(pinName)
        pval = atof(extract_init_value(lpin))
        rval = pval
        sn = 1
        if(or(rexMatchp("^vss", lpin) rexMatchp("^sub", lpin)) then
            rval = 0.0
        else
            if(rexMatchp("^i", lpin) lpin = substring(lpin, 2))
            if(or(rexMatchp("^n", lpin) rexMatchp("^p", lpin)) then
                if(rexMatchp("^n", lpin) sn = -1)
                if(length(lpin) > 2 lpin = substring(lpin, 2))
                pval = atof(extract_init_value(lpin))
                if(pval >= 50 pval = pval / 1000)
                rval = pval * 1e-6 * sn
            else
                if(and(rexMatchp("^vdd", lpin) rval <= 1e-6) rval = 100.0)
            )
        )
        rval
    )
)

procedure(printCorr(@optional (execludeList list()))
    let((pins pinList extractedInfoList extractedNameList extractedNameRangeList extractedRangeTable listInd printStr termDDef pinDef pin pinInd pin termRanges pinTerm2 termRange2 termRange pinCorr newPinDef )
        saveLast()
        pins = get(tbSelectionForm 'corr)->value
        pinList = parseString(pins)
        pinList = uniqueList(pinList)
        extractedInfoList = extractPinList(pinList)
        extractedNameList = car(extractedInfoList)
        extractedNameRangeList = cadr(extractedInfoList)
        extractedRangeTable = caddr(extractedInfoList)
        listInd = 0
        printStr = "\n"
        pinDef = "wire"
        if(length(execludeList)>0 then
            foreach(pin execludeList printf("%s\t ",pin))
        )
        foreach(pinList list(extractedNameRangeList extractedNameList )
            listInd += 1
            pinInd = 0
            foreach(pin pinList
                if(member(pin execludeList) then
                    printf("You should not put electrical pin %s in the digital list" pin)
                else
                    termRange = extractedRangeTable[pin]
                    pinInd += 1
                    pinCorr = strcat(pin "_corr")
                    if(remainder(listInd, 2) == 1  then
                        newPinDef = pinDef
                        termDDef = if(rexMatchp(" " termRange) 1 0) ;terminal is double defined
                        termRanges = if(rexMatchp(" " termRange) list(getTotalRange(termRange)) list(termRange))
                        foreach(termRange termRanges 
                            if(termDDef == 1 then
                                printStr = sprintf(nil "%s    %s %s %s;\n", printStr, newPinDef, termRange, pinCorr)
                                foreach(termRange2 parseString(extractedRangeTable[pin])
                                    pinTerm2 = sprintf(nil "%s%s", pin, termRange2)
                                    printStr = sprintf(nil "%s    %s %s%s = (^%s === 1'bx || ^%s === 1'bz)? 0 : %s;\n", printStr, "assign", pinCorr, termRange2, pinTerm2, pinTerm2, pinTerm2)
                                )
                            else
                                printStr = sprintf(nil "%s    %s %s %s = (^%s === 1'bx || ^%s === 1'bz)? 0 : %s;\n", printStr, newPinDef, termRange, pinCorr, pin, pin, pin)
                            )
                        )
                    else 
                        newPinDef = pinDef
                        printStr = sprintf(nil "%s    %s %s = (%s === 1'bx || %s === 1'bz)? 0 : %s;\n", printStr, newPinDef, pinCorr, pin, pin, pin)
                    ) ;if
                ) ;if pin is in execludeList
            ) ;foreach
        )
        printStr = sprintf(nil "%s", printStr)
        printStr
    )
)

procedure(getSourcesStr(instTable sourceName firstNode secondNode)
    let((vdd vss firstNode0 secondNode0 instName pinName instName0 instInd sourceStr taskNames
            instrinsicTaskNames taskStr taskDefineStr taskInd taskName  enableValue initValueStr initValue initialTaskStr taskDomDes en_task ucfPinName)
        saveLast()
        vdd = get(tbSelectionForm 'vdd)->value
        vss = get(tbSelectionForm 'vss)->value
        firstNode0 = flatternNode(firstNode)
        secondNode0 = flatternNode(secondNode)
        if(secondNode0 == vdd || secondNode0 == vss instName = firstNode0 instName = secondNode0)
        pinName = instName
        ucfPinName = ucFirst(instName)
        instName = ucFirst(instName)
        rexCompile("^ams_")
        ;instName = strcat(rexReplace(sourceName "" 0) "_" instName)
        instName = strcat(rexReplace(sourceName "" 0) "" instName)
        instName = ucFirst(instName)
        ;pinName = ucFirst(pinName)
        instName0 = instName
        instInd = 0
        while(member(instName instTable->?)
            instInd += 1
            ;instName = sprintf(nil "%s_%d" instName0 instInd)
            instName = sprintf(nil "%s%d" instName0 instInd)
        )
        instTable[instName] = instInd
        initialTaskStr = "    initial begin"
        ;printf("%L\n" sourceName)
        case(sourceName
            ("ams_vsrc"
                ;taskNames = list(strcat("disable" instName) strcat("enable" instName) strcat("set" instName "Vol") strcat("ramp" instName "Vol"))
                ;en_task = strcat("en_" pinName)
                en_task = strcat("en" ucfPinName)
                ;taskNames = list(strcat("dis_" pinName) strcat("en_" pinName) strcat("set_" pinName) strcat("ramp_" pinName))
                taskNames = list(strcat("dis" ucfPinName) strcat("en" ucfPinName) strcat("set" ucfPinName) strcat("ramp" ucfPinName))
                instrinsicTaskNames = list("setEnable" "setEnable" "setVolt" "rampVolt")
                taskDomDes = "Vol"
                sourceStr = sprintf(nil "    %s #(.startEnabled(1)) %s(.p(%s), .n(%s));\n", sourceName, instName, firstNode, secondNode)
                initValue = strcat(pinName "InitValue")
            )
            ("ams_isrc"
                en_task = strcat("en" instName)
                taskNames = list(strcat("dis" instName) strcat("en" instName) strcat("set" ucfPinName "Cur") strcat("ramp" ucfPinName "Cur"))
                instrinsicTaskNames = list("setEnable" "setEnable" "setCurrent" "rampCurrent")
                taskDomDes = "Cur"
                sourceStr = sprintf(nil "    %s #(.startEnabled(0)) %s(.p(%s), .n(%s));\n", sourceName, instName, firstNode, secondNode)
                initValue = strcat(pinName "CurInitValue")
            )
            (t
                en_task = ""
                taskNames = list()
                instrinsicTaskNames = list()
            )
        )
        ;initValue = strcat("real " pinName "_InitValue = 0;\n")
        taskStr = sprintf(nil "")
        taskDefineStr = sprintf(nil "")
        taskInd = 0
        unless(en_task == "" en_task = strcat("        " en_task ";\n"))
        foreach(taskName taskNames
            ;printf("%s\n" taskName)
            taskDefineStr = sprintf(nil "%s`define %s%s`stim.%s\n" taskDefineStr taskName printNumOfBlanks(30-strlen(strcat("`define " taskName))) taskName)
            taskInd += 1
            if(taskName then
                taskStr = sprintf(nil "%s    task %s;\n" taskStr taskName)
                case(taskInd
                    ((1 2)
                        enableValue = taskInd - 1
                        taskStr = sprintf(nil "%s    begin\n        %s.%s(1'b%d);\n    end\n    endtask    //%s\n\n" taskStr instName nthelem(taskInd instrinsicTaskNames) enableValue taskName)
                    )
                    (3
                        taskStr = sprintf(nil "%s    input real newVal;\n    begin\n%s        %s.%s(newVal);\n    end\n    endtask    //%s\n\n" taskStr en_task instName nthelem(taskInd instrinsicTaskNames) taskName)
                        initialTaskStr = sprintf(nil "        %s(%s);\n" taskName initValue)
                    )
                    (4
                        taskStr = sprintf(nil "%s    input real newVal;\n    input real rampTime;\n    begin\n%s        %s.%s(newVal, rampTime);\n    end\n    endtask    //%s\n\n" taskStr en_task instName nthelem( taskInd instrinsicTaskNames) taskName)
                    )
                )
            )
        )
        initValueStr = strcat("    real " initValue " = " extract_init_value(pinName) ";\n")
        ;printf("%s %s\n",taskStr taskDefineStr)

        list(sourceStr taskStr taskDefineStr initialTaskStr initValueStr initValue)
    )
)

procedure(extract_init_value(in_str)
    let((extract_value)
        rexCompile("\\([0-9]*p[0-9][0-9]*\\)")
        if(rexExecute(in_str) then
            extract_value = rexSubstitute("\\1")
            if(rexMatchp("^p", extract_value) then
                extract_value = strcat("0" extract_value)
            )
            rexCompile("p")
            extract_value = rexReplace(extract_value "." 0)
        else
            rexCompile("\\([0-9][0-9]*\\)")
            if(rexExecute(in_str) then
                extract_value = rexSubstitute("\\1")
            else
                extract_value = "0.0"
            )
        )
        extract_value
    )
)

procedure(uc(var)
    let(()
        upperCase(var)
    )
)

procedure(getAllReg(@optional (execludeList list()))
    let((listInd regStr taskStr defineStr key pins pinList extractedPinList extractedNameList extractedNameRangeList
            extractedRangeTable vdd vss sNode sourceName fNode pin termRanges termRange termMul start end temp1 pinSubInd sourceList pin_index
            regName taskName thisTask numOfBits traverse_max_number reg_pin_info_list reg_pin_info)
        saveLast()
        listInd = 0
        regStr = ""
        taskStr = ""
        defineStr = ""
        reg_pin_info_list = list()
        foreach(key '(digRegs)
            pins = get(tbSelectionForm key)->value
            pinList = parseString(pins)
            pinList = uniqueList(pinList)
            extractedPinList = extractPinList(pinList)
            extractedNameList = car(extractedPinList)
            extractedNameRangeList = cadr(extractedPinList)
            extractedRangeTable = caddr(extractedPinList)
            pinList = cadr(cddr(extractedPinList))

            pin_index = 0
            ;foreach(pinList list(extractedNameRangeList extractedNameList)
            foreach(pin pinList
                pin_index += 1
                unless(member(pin execludeList)
                    termRange = extractedRangeTable[pin]
                    termRanges = if(rexMatchp(" " termRange) list(getTotalRange(termRange)) list(termRange))
                    foreach(termRange termRanges
                        if(termRange == "" then
                            termMul = 0
                            start = 0
                            end = 0
                        else
                            termMul = 1
                            rexCompile("\\[\\(.*\\):\\(.*\\)\\]")
                            if(rexExecute(termRange) then
                                start = evalstring(rexSubstitute("\\1"))
                                end = evalstring(rexSubstitute("\\2"))
                                if(start > end then 
                                    temp1 = start
                                    start = end
                                    end = temp1
                                )
                            )
                        )
                        numOfBits = end - start + 1
                        regName = strcat(pin "_reg")
                        taskName = strcat("set_" pin)
                        thisTask = sprintf(nil "    task %s;\n    input %s inVal;\n    begin\n" taskName termRange)
                        thisTask = sprintf(nil "%s        %s = inVal;\n    end\n    endtask    //%s\n" thisTask regName taskName)
                        if(get(tbSelectionForm 'traverse)->value then
                            traverse_max_number = 2 ** numOfBits
                            thisTask = sprintf(nil "%s%s\n\n", thisTask, buildString(gen_reg_traverse(pin, traverse_max_number, pin_index), "\n"))
                            ;reg_pin_info = list(pin traverse_max_number pin_index)
                            reg_pin_info_list = append1(reg_pin_info_list list(pin traverse_max_number pin_index))
                        )
                        regStr = sprintf(nil "%s    reg %s %s = %d'b0;\n    assign %s = %s;\n" regStr termRange regName numOfBits pin regName)
                        taskStr = sprintf(nil "%s%s" taskStr thisTask)
                        defineStr = sprintf(nil "%s`define %s%s`stim.%s\n" defineStr taskName printNumOfBlanks(30-strlen(strcat("`define " taskName))) taskName)
                    )
                )
            )
            ;)
        )
        list(list(regStr taskStr defineStr) reg_pin_info_list)
    )
)

procedure(extract_vams()
    let((instLibName instCellName instViewName vams_hash_pin_info dig_ss_list sources vams_ports_info_full vams_pin_list_full vams_obj )
        instLibName = get(tbSelectionForm 'libName)->value
        instCellName = get(tbSelectionForm 'cellName)->value
        instViewName = get(tbSelectionForm 'viewName)->value
        vams_hash_pin_info = extract_pin_info_from_vams_view(instLibName instCellName "verilogams")
        vams_obj = dbOpenCellViewByType(instLibName instCellName "verilogams" "" "r")
        vams_ports_info_full = gen_pin_list_hash_from_view(vams_obj)
        vams_pin_list_full = cadr(vams_ports_info_full)
        dig_ss_list = extract_ss_from_hash(vams_hash_pin_info)
        if(length(dig_ss_list) >= 1 then
            sources = parseString(cadr(dig_ss_list), ",")
            ;printf("%s|%s\n", car(sources) cadr(sources))
            get(tbSelectionForm 'vdd)->value = car(sources)
            get(tbSelectionForm 'vss)->value = cadr(sources)
        )
        get(tbSelectionForm 'electrical)->value = buildString(extract_domain_from_hash(vams_hash_pin_info vams_pin_list_full), " ")
        dig_list = extract_domain_from_hash(vams_hash_pin_info vams_pin_list_full, "digital")
        get(tbSelectionForm 'wires)->value = buildString(dig_list, " ")
        sync_dig_pins('tgtoutputPins 'digRegs)
        sync_dig_pins('tgtinputPins 'corr)
    )
)

procedure(remove_duplicates(key)
    let(()
        get(tbSelectionForm key)->value = buildString(uniqueList(parseString(get(tbSelectionForm key)->value)), " ")
    )
)
;sync the digtal pins from in/out/pins exclude electrical
procedure(sync_dig_pins(key key2)
    let((key_pins electrical_pins key_dig_pins pin )
        remove_duplicates(key)
        key_pins = parseString(get(tbSelectionForm key)->value)
        electrical_pins = parseString(get(tbSelectionForm 'electrical)->value)
        key_dig_pins = list()
        foreach(pin key_pins
            if(not(member(pin electrical_pins)) then
                key_dig_pins = append1(key_dig_pins pin)
            )
        )
        get(tbSelectionForm key2)->value = buildString(key_dig_pins " ")
        remove_duplicates(key2)
    )
)

procedure(extract_domain_from_hash(in_hash orig_pin_list @optional (domain "analog"))
    let((pin pin_name domain_list out_list item item_value)
        out_list = list()
        domain_list = list()

        foreach(item in_hash->?
            item_value = cadr(in_hash[item])
            if(((domain == "analog" && not(rexMatchp("," item_value))) || (domain != "analog" && rexMatchp("," item_value))) && not(member(item, domain_list)) then
                domain_list = append1(domain_list item)
            )
        )
        foreach(pin orig_pin_list
            pin_name = car(extract_pin_orig(pin))
            ;printf("%s\n", pin_name)
            if(member(pin_name domain_list)
                out_list = append1(out_list pin)
            )
        )
        out_list
    )
)


;generate the test traverse of the reg
procedure(gen_reg_test_traverse(in_list)
    let((iter_vars delay_time_vars reg_test_array reg_pin_info reg_name max_tr_number pin_index front_space_filler reg_list_array)
        iter_vars = list()
        delay_time_vars = list()
        reg_test_array = list()
        foreach(reg_pin_info reverse(in_list)
            reg_name = car(reg_pin_info)
            max_tr_number = cadr(reg_pin_info)
            pin_index = caddr(reg_pin_info)
            front_space_filler = numSpace(pin_index * 4 - 4)
            reg_list_array = gen_reg_traverse(reg_name max_tr_number pin_index front_space_filler 0)
            iter_vars = cons(car(reg_list_array) iter_vars)
            delay_time_vars = cons(cadr(reg_list_array) delay_time_vars)
            this_reg_main_array = caddr(reg_list_array)
            reg_test_array = append(list(car(this_reg_main_array) cadr(this_reg_main_array) caddr(this_reg_main_array)) reg_test_array)
            reg_test_array = append(reg_test_array cdddr(this_reg_main_array))
        )
        list(iter_vars delay_time_vars reg_test_array)
    )
)

;generate the traverse of the reg
procedure(gen_reg_traverse(reg_name max_tr_number @optional (pin_index 1)(space_filler "    ")(test_or_task 1))
    let((new_max_tr_number task_stim task_main_array task_name set_task_name task_vars_list task_str task_out_array delay_time_var iter_var)
        task_main_array = list()
        iter_var = gen_iter_var(pin_index)
        task_name = strcat("traverse_" reg_name)
        set_task_name = strcat("set_" reg_name)
        delay_time_var = sprintf(nil "delay_time%d", pin_index)
        task_vars_list = list(list("input real" list(delay_time_var)) list("integer" list(iter_var)))
        new_max_tr_number = max_tr_number
        if(test_or_task == 0 then
            task_stim = "`stim."
            if(pin_index == 1 new_max_tr_number = 2 * max_tr_number)
        else
            task_stim = ""
        )
        ;if(test_or_task == 0 then
            ;task_str = sprintf(nil "    #10_000;\n")
            ;task_main_array = append1(task_main_array task_str)
        ;)
        task_str = sprintf(nil "    for(%s = 0; %s < %d; %s = %s + 1) begin", iter_var, iter_var, new_max_tr_number, iter_var, iter_var)
        task_main_array = append1(task_main_array task_str)
        task_str = sprintf(nil "        %s%s(%s);", task_stim, set_task_name, iter_var)
        task_main_array = append1(task_main_array task_str)
        task_str = sprintf(nil "        #%s; //delay for a %s ns and continue next set.", delay_time_var, delay_time_var)
        task_main_array = append1(task_main_array task_str)
        task_str = sprintf(nil "    end //loop %s for %s", iter_var, reg_name)
        task_main_array = append1(task_main_array task_str)
        if(test_or_task == 0 then
            task_str = sprintf(nil "    #10_000;")
            task_main_array = append1(task_main_array task_str)
        )
        test_out_array =list(iter_var sprintf(nil "real %s = 100_000;" delay_time_var) add_space_filler_to_lines(task_main_array space_filler))
        task_out_array = add_space_filler_to_lines(gen_task_function(0 task_name task_vars_list task_main_array) space_filler)
        if(test_or_task == 1 task_out_array test_out_array)
    )
)

procedure(gen_iter_var(@optional (in_num 1))
    let((start_char start_num end_char end_num total_num num_repeats num_index out_char out_string)
        start_char = "i"
        start_num = charToInt(stringToSymbol(start_char))
        end_char = "z"
        end_num = charToInt(stringToSymbol(end_char))
        total_num = end_num - start_num + 1
        if(mod(in_num total_num) == 0 then
            num_repeats = in_num / total_num + 1
            num_index = total_num
        else
            num_repeats = in_num / total_num + 2
            num_index = mod(in_num total_num)
        )
        out_char = symbolToString(intToChar(start_num - 1 + num_index))
        out_string = ""
        for(ii 1 num_repeats
            out_string = sprintf(nil "%s%s" out_string out_char)
        )
        out_string
    )
)

procedure(add_space_filler_to_lines(in_array @optional (space_filler ""))
    let((new_array line line_lines)
        new_array = list()
        foreach(line in_array
            if(not(rexMatchp("\n$", line)) then
                line = strcat(line "\n")
            )
            line_lines = parseString(line "\n")
            foreach(line line_lines
                new_array = append1(new_array strcat(space_filler line))
            )
        )
        new_array
    )
)

procedure(gen_task_function(task_or_function task_function_name var_dec_list task_main_list)
    let((str_array def_type list_index pin_dir pin_list_info pin_list)
        str_array = list()
        def_type = ""
        if(task_or_function == 0 then
            def_type = "task"
        else
            if(task_or_function == 1 then
                def_type = "function"
            )
        )
        task_def = sprintf(nil "//begin task %s", task_function_name)
        str_array = append1(str_array, task_def)
        task_def = sprintf(nil "%s %s;", def_type, task_function_name, task_function_name)
        str_array = append1(str_array, task_def)
        foreach(pin_list_info var_dec_list
            pin_dir = car(pin_list_info)
            pin_list = cadr(pin_list_info)
            str_array = attach_arrays(str_array, gen_pin_list_dec(pin_dir pin_list))
        )
        str_array = append1(str_array, "begin")
        foreach(task_str task_main_list
            str_array = append1(str_array, task_str)
        )
        str_array = append1(str_array, "end")
        str_array = append1(str_array, strcat("end" def_type))
        str_array = append1(str_array, strcat("//end " def_type " " task_function_name))
        str_array
    )
)


;takes the pin direction and a list
procedure(gen_pin_list_dec(pin_dir pin_list)
    let((out_array extractedPinList extractedNameList extractedNameRangeList extractedRangeTable pin_dec_str pin)
        out_array = list()
        extractedPinList = extractPinList(pin_list)
        extractedNameList = car(extractedPinList)
        extractedNameRangeList = cadr(extractedPinList)
        extractedRangeTable = caddr(extractedPinList)
        if(length(extractedNameList) >= 1 then
            pin_dec_str = strcat(pin_dir " " buildString(extractedNameList, ", ") ";\n")
            out_array = append1(out_array pin_dec_str)
        else
            pin_dec_str = ""
        )
        pin_dec_str = ""
        if(length(extractedNameRangeList) >= 1 then
            foreach(pin extractedNameRangeList
                pin_dec_str = strcat(pin_dir " " extractedRangeTable[pin] "" pin ";\n")
                out_array = append1(out_array pin_dec_str)
            )
        )
        out_array
    )
)

;attach arrays to form a new array. if we want to remove duplicates. by default duplicates is removed
procedure(attach_arrays(list1 list2 @optional (remove_duplicates 1))
    let((item new_list)
        new_list = list()
        if(length(list1) >= 1 then
            foreach(item list1
                ;if(not(member(item new_list)) || remove_duplicates != 1 then
                    new_list = append1(new_list item)
                ;)
            )
        )
        if(length(list2) >= 1 then
            foreach(item list2
                if(not(member(item new_list)) || remove_duplicates != 1 then
                    new_list = append1(new_list item)
                )
            )
        )
        new_list
    )
)

procedure(setDigForm()
    let((taskList numStr taskField taskIndex fieldsList task taskLoc key pins pinList extractedPinList extractedNameList extractedNameRangeList
            extractedRangeTable vdd vss sNode sourceName fNode pin termRange termMul start end temp1 pinSubInd sourceList 
            regName taskName thisTask numOfBits dacList numOfBitsList taskNameList
            buttonList genCode randomize fieldsList listIndex tList buttonIndex buttonLoc button0 xoffset yoffset
            binField binList )
        saveLast()
        taskList = list()
        dacList = list()
        binList = list()
        numOfBitsList = list()
        taskNameList = list()
        foreach(key '(digRegs)
            pins = get(tbSelectionForm key)->value
            pinList = parseString(pins)
            pinList = uniqueList(pinList)
            extractedPinList = extractPinList(pinList)
            extractedNameList = car(extractedPinList)
            extractedNameRangeList = cadr(extractedPinList)
            extractedRangeTable = caddr(extractedPinList)

            foreach(pinList list(extractedNameRangeList extractedNameList )
                foreach(pin pinList
                    termRange = extractedRangeTable[pin]
                    termRanges = if(rexMatchp(" " termRange) list(getTotalRange(termRange)) list(termRange))
                    foreach(termRange termRanges 
                        if(termRange == "" then
                            termMul = 0
                            start = 0
                            end = 0
                        else
                            termMul = 1
                            rexCompile("\\[\\(.*\\):\\(.*\\)\\]")
                            if(rexExecute(termRange) then
                                start = evalstring(rexSubstitute("\\1"))
                                end = evalstring(rexSubstitute("\\2"))
                                if(start > end then 
                                    temp1 = start
                                    start = end
                                    end = temp1
                                )
                            )
                        )
                        numOfBits = end - start + 1
                        regName = strcat(pin "_reg")
                        taskName = strcat("set_" pin)
                        numStr = sprintf(nil "%d'd" numOfBits)
                        taskField = hiCreateStringField(
                                    ?name stringToSymbol(taskName)
                                    ?prompt strcat(upperCase(taskName) printNumOfBlanks(40-2*strlen(taskName)-strlen(numStr)) numStr)
                                    ?defValue "0"
                                        ?callback sprintf(nil "convertDecToHexValue(%L %d)" taskName numOfBits)
                                    )
                        dacField =  hiCreateStringField(
                                    ?name stringToSymbol(strcat(taskName "HEX"))
                                    ?prompt " "
                                    ?defValue "0"
                                    )
                        binField =  hiCreateStringField(
                                    ?name stringToSymbol(strcat(taskName "BIN"))
                                    ?prompt " "
                                    ?defValue "0"
                                    )
                        taskList = append1(taskList taskField)
                        dacList = append1(dacList dacField)
                        binList = append1(binList binField)
                        numOfBitsList = append1(numOfBitsList sprintf(nil "%d" numOfBits)) ;inorder to build a string
                       ;list has to be of string values
                        taskNameList = append1(taskNameList taskName)
                    )
                )
            )
        )
        buttonList = list()
        genCode=hiCreateButton(
                ?name 'genCode
                ?buttonText "Gen Code"
                ?callback sprintf(nil "genCode(%L %L)" buildString(taskNameList " ") buildString(numOfBitsList " "))
                )
        buttonList = append1(buttonList genCode)
        randomize=hiCreateButton(
                ?name 'randomize
                ?buttonText "Randomize"
                ?callback sprintf(nil "randomize(%L %L)" buildString(taskNameList " ") buildString(numOfBitsList " "))
                )
        buttonList = append1(buttonList randomize)
        fieldsList = list()
        listIndex = 0
        foreach(tList list(taskList dacList binList)
            listIndex += 1
            taskIndex = 0
            case(listIndex
                (1
                    xoffset = 0
                    fieldWidth = 300
                    fieldOffset = 200
                )
                (2
                    xoffset = 300
                    fieldWidth = 100
                    fieldOffset = 0
                )
                (3
                    xoffset = 400
                    fieldWidth = 150
                    fieldOffset = 0
                )
            )
            foreach(task tList
                taskIndex += 1
                taskLoc = list(task xoffset:30*taskIndex-30 fieldWidth:30 fieldOffset)
                fieldsList = append1(fieldsList taskLoc)
            )
        )
        buttonIndex = 0
        foreach(button0 buttonList
            buttonIndex += 1
            xoffset = 150 * buttonIndex
            yoffset = 30*length(taskList)
            buttonLoc = list(button0 xoffset:yoffset 150:30)
            fieldsList = append1(fieldsList buttonLoc)
        )
        unless(boundp('setRegValueForm)
            hiCreateAppForm(
                ?name 'setRegValueForm
                ?formTitle "Set the registers value form"
                ?callback sprintf(nil "genRegValueForm(%L %L)" buildString(taskNameList " ") buildString(numOfBitsList " "))
                ?fields fieldsList
            )
        )
        hiDisplayForm(setRegValueForm)
    )
)

procedure(genRegValueForm(keyNames numBits)
    let(()
        hiRegTimer("setRegValueForm = 'unbound" 10)
        genCode(keyNames numBits)
    )
)
procedure(genCode(keyNames numBits)
    let((keyNameList numBitsList keyIndex outCode keyName numOfBitsValue keyValue hexKeyValue )
        saveLast()
        keyNameList = parseString(keyNames)
        numBitsList = parseString(numBits)
        if(length(keyNameList) != length(numBitsList) displayWarnBox("You have a different length of keys and num of bits.\n"))
        keyIndex = 0
        outCode = ""
        foreach(keyName keyNameList
            keyIndex += 1
            keyValue = evalstring(get(setRegValueForm stringToSymbol(keyName))->value)
            numOfBitsValue = evalstring(nthelem(keyIndex numBitsList))
            if(numberp(keyValue) && numberp(numOfBitsValue) then
                if(keyValue >= pow(2, numOfBitsValue) keyValue = pow(2, numOfBitsValue) - 1)
                hexKeyValue = sprintf(nil "%d'h%x" numOfBitsValue keyValue)
                sprintf(outCode "%s    `%s(%s);\t//decimal value: %d, bin value: %s \n" outCode keyName hexKeyValue keyValue ccsDec2Bin(keyValue))
                ;sprintf(outCode "%s    `%s(%s);\t//decimal value: %d, bin value: \n" outCode keyName hexKeyValue keyValue)
            else
                displayWarnBox("either keyValue or numofbits is not number.\n")
            )
        )
        printf("%s\n" outCode)
        outCode

    )
)

procedure(randomize(keyNames numBits)
    let((keyNameList numBitsList keyIndex keyName numOfBitsValue )
        saveLast()
        keyNameList = parseString(keyNames)
        numBitsList = parseString(numBits)
        if(length(keyNameList) != length(numBitsList) displayWarnBox("You have a different length of keys and num of bits.\n"))
        keyIndex = 0
        foreach(keyName keyNameList
            keyIndex += 1
            numOfBitsValue = evalstring(nthelem(keyIndex numBitsList))
            printf("%d %s\n" numOfBitsValue keyName)
            get(setRegValueForm stringToSymbol(keyName))->value = sprintf(nil "%d" random(pow(2 numOfBitsValue)))
            ;get(setRegValueForm stringToSymbol(keyName))->value = "234"
            printf("task %s\n" get(setRegValueForm stringToSymbol(keyName))->value )
        )
        genCode(keyNames numBits)
    )
)

procedure(convertDecToHexValue(keyName numBits)
    let((hexValue decValue binValue )
        ;printf("%s\n" keyName)
        decValue = evalstring(get(setRegValueForm stringToSymbol(keyName))->value)
        if(decValue >= pow(2, numBits) decValue = pow(2,numBits) - 1)
        hexValue = sprintf(nil "%x" decValue)
        binValue = ccsDec2Bin(decValue)
        printf("%s" binValue)
        get(setRegValueForm stringToSymbol(strcat(keyName "HEX")))->value =  hexValue
        get(setRegValueForm stringToSymbol(strcat(keyName "BIN")))->value =  binValue
        list(hexValue binValue)
    )
)

procedure(ccsDec2Bin(num "x")
    let(((binstr ""))
        while(!zerop(num)
            binstr = strcat(if(zerop(num & 1) "0" "1") binstr)
            num = num>>1
        )
        if(binstr == "" "0" binstr)
    )
)

procedure(convertDecToDacValue(keyName)
    let((vref dacValue decValue)
        vref = 2.304
        decValue = evalstring(get(setRegValueForm stringToSymbol(keyName))->value)
        dacValue = vref * decValue / (2 ** 12) * 1.0
        get(setRegValueForm stringToSymbol(strcat(keyName "DAC")))->value = sprintf(nil "%1.3f" dacValue)
    )
)


procedure(printNumOfBlanks(inNum)
    let((i ostring numOfSpace)
        saveLast()
        if(inNum >= 1 numOfSpace = inNum numOfSpace = 1)
        ostring = ""
        for(i 1 numOfSpace ostring=sprintf(nil "%s " ostring))
        ostring
    )
)

procedure(getAllSourceStr(instTable @optional (topDef 0))
    let((listInd sourceStr taskStr defineStr key pins pinList extractedPinList extractedNameList extractedNameRangeList
            extractedRangeTable vdd vss sNode sourceName fNode pin termRanges termRange termMul start end temp1 pinSubInd
            sourceList initValuesStr initialStr initial_values_array set_initial_task initValue
            init_index in_values in_value set_initial_task_body )
        saveLast()
        listInd = 0
        sourceStr = ""
        taskStr = ""
        initialStr = "    task initialize;\n    begin\n"
        set_initial_task = "    task setInitialValue;\n    input real "
        set_initial_task_body = "    begin\n"
        initial_values_array = list()
        initValuesStr =  ""
        if(topDef == 0 then
            if(deGetCellView() defineStr = sprintf(nil "`define top%s%s\n" printNumOfBlanks(30-strlen("`define top")) deGetCellView()~>cellName) defineStr = "")
            defineStr = sprintf(nil "%s`define stim%s`top.stim\n" defineStr printNumOfBlanks(30-strlen("`define stim")))
        else
            defineStr = vamsTopDef()
        )
        foreach(key '(vsource isource_vdd isource_vss)
            listInd += 1
            pins = get(tbSelectionForm key)->value
            vdd = get(tbSelectionForm 'vdd)->value
            vss = get(tbSelectionForm 'vss)->value
            ;if(rexMatchp("^stim" get(tbSelectionForm 'tgtCellName)->value) && listInd == 1 pins = strcat(pins " " vdd))
            pinList = parseString(pins)
            pinList = uniqueList(pinList)
            extractedPinList = extractPinList(pinList)
            extractedNameList = car(extractedPinList)
            extractedNameRangeList = cadr(extractedPinList)
            extractedRangeTable = caddr(extractedPinList)

            case(listInd
                (1
                    sNode = vss
                    sourceName = "ams_vsrc"
                )
                (2
                    fNode = vdd
                    sourceName = "ams_isrc"
                )
                (3
                    sNode = vss
                    sourceName = "ams_isrc"
                )
            )
            foreach(pinList list(extractedNameRangeList extractedNameList )
                foreach(pin pinList
                    termRange = extractedRangeTable[pin]
                    termRanges = if(rexMatchp(" " termRange) parseString(termRange) list(termRange))
                    foreach(termRange termRanges 
                        if(termRange == "" then
                            termMul = 0
                            start = 0
                            end = 0
                        else
                            termMul = 1
                            rexCompile("\\[\\(.*\\):\\(.*\\)\\]")
                            if(rexExecute(termRange) then
                                start = evalstring(rexSubstitute("\\1"))
                                end = evalstring(rexSubstitute("\\2"))
                                if(start > end then 
                                    temp1 = start
                                    start = end
                                    end = temp1
                                )
                            )
                        )
                        for(pinSubInd start end
                            if(termMul == 0 then
                                case(listInd
                                    (1
                                        fNode = pin
                                    )
                                    (2
                                        sNode = pin
                                    )
                                    (3
                                        fNode = pin
                                    )
                                )
                            else
                                case(listInd
                                    (1
                                        fNode = sprintf(nil "%s[%d]" pin,pinSubInd)
                                    )
                                    (2
                                        sNode = sprintf(nil "%s[%d]" pin,pinSubInd)
                                    )
                                    (3
                                        fNode = sprintf(nil "%s[%d]" pin,pinSubInd) 
                                    )
                                )
                            )
                            ;printf("%s %s %s\n" sourceName fNode sNode)
                            sourceList = getSourcesStr(instTable sourceName fNode sNode)
                            sourceStr = sprintf(nil "%s%s" sourceStr car(sourceList))
                            taskStr = sprintf(nil "%s%s" taskStr cadr(sourceList))
                            defineStr = sprintf(nil "%s%s" defineStr caddr(sourceList))
                            initialStr = sprintf(nil "%s%s" initialStr car(cdddr(sourceList)))
                            initValuesStr = sprintf(nil "%s%s" initValuesStr car(cddr(cddr(sourceList))))
                            initValue = nthelem(6 sourceList)
                            initial_values_array = append1(initial_values_array initValue)
                        )
                    )
                 )
             )
        )
        init_index = 0
        in_values = list()
        foreach(initValue initial_values_array
            init_index += 1
            in_value = sprintf(nil, "inVal%d", init_index)
            in_values = append1(in_values, in_value)
            set_initial_task_body = sprintf(nil, "%s        %s = %s;\n", set_initial_task_body, initValue, in_value)
        )
        set_initial_task = sprintf(nil, "%s %s;\n", set_initial_task, buildString(in_values, ", "))
        set_initial_task_body = sprintf(nil, "%s    end\n    endtask //%s\n", set_initial_task_body, "set_initial_value")
        set_initial_task = sprintf(nil, "%s%s", set_initial_task, set_initial_task_body)
        initialStr = sprintf(nil "%s%s" initialStr "    end\n    endtask\n")
        list(sourceStr taskStr defineStr initialStr initValuesStr set_initial_task)
    )
)


procedure(printDefine()
    let((instTable srcList )
        saveLast()
        instTable = makeTable("instance tables")
        srcList = getAllSourceStr(instTable 1)
        regList = car(getAllReg())
        printf("%s\n%s\n" caddr(srcList) caddr(regList))
        ofileH = outfile("tb_defines.sv")
        fprintf(ofileH "%s\n%s\n" caddr(srcList) caddr(regList))
        close(ofileH)
    )
)

procedure(ucFirst(inStr)
    let((firstChar restStr newStr )
        saveLast()
        firstChar = substring(inStr 1 1)
        firstChar = upperCase(firstChar)
        restStr = substring(inStr 2 strlen(inStr) - 1)
        unless(restStr restStr = "")
        newStr = strcat(firstChar restStr)
    )
)

procedure(flatternNode(node)
    let((flatNode)
        saveLast()
        flatNode = node
        rexCompile("\\[\\(.*\\)\\]")
        flatNode = rexReplace(flatNode "_\\1" 0)
    )
)
procedure(getSensitivity()
    let((sensValue)
        saveLast()
        sensValue = get(tbSelectionForm 'needSensitivity)->value
    )
)

procedure(uniqueList(inList)
    let((listTable item newList)
        ;saveLast()
        ;listTable = makeTable("unique list")
        newList = list()
        foreach(item inList
            ;listTable[item] = 1
            unless(member(item newList)
                newList = append1(newList item)
            )
        )
        newList
    )
)


procedure(openCellView()
    let((obj instCellName instLibName instViewName vamsFile)
        saveLast()
        instCellName = get(tbSelectionForm 'cellName)->value
        instLibName = get(tbSelectionForm 'libName)->value
        instViewName = get(tbSelectionForm 'viewName)->value
        if(obj = ddGetObj(instLibName instCellName instViewName) then
            deOpenCellView(instLibName instCellName instViewName "" list() "r")
            ;vamsFile = strcat(obj~>readPath "/verilog.vams")
            ;if(isFile(vamsFile) then
                ;shell(strcat("gvim " vamsFile)) 
            ;)
        else
            displayErrBox(sprintf(nil "%s %s %s does not exist.\n",instLibName instCellName instViewName))
        )
    )
)

procedure(coVAMSCellView()
    let((obj instCellName instLibName instViewName vamsFile)
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        check_out_cell(instLibName instCellName instViewName)
    )
)
procedure(viewVAMSCellView()
    let((obj instCellName instLibName instViewName vamsFile state_list state spec)
        saveLast()
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        if(obj = ddGetObj(instLibName instCellName instViewName) then
            state_list = get_co_state(instLibName instCellName instViewName)
            state = car(state_list)
            spec = cadr(state_list)
            when(state == "gdmStateCI" && get(tbSelectionForm 'check_out)->value 
                displayWarnBox(sprintf(nil "Checking out %s %s %s.\n",instLibName instCellName instViewName))
                check_out_spec(spec)
            )
            deOpenCellView(instLibName instCellName instViewName "" list() "r")
            ;vamsFile = strcat(obj~>readPath "/verilog.vams")
            ;if(isFile(vamsFile) then
                ;shell(strcat("gvim " vamsFile)) 
            ;)
        else
            displayErrBox(sprintf(nil "%s %s %s does not exist.\n",instLibName instCellName instViewName))
        )
    )
)

procedure(viewVAMSFile()
    let((vamsFile instCellName instLibName instViewName vams_temp_dir okBox )
        saveLast()
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        vams_temp_dir = strcat(pwd() "/vams_temp")
        vamsFile = sprintf(nil "%s/%s_%s_%s.vams" vams_temp_dir, instLibName, instCellName, instViewName)
        if(isFile(vamsFile) then
            shell(strcat("gvim " vamsFile)) 
        else
            okBox = hiDisplayAppDBox(?name 'fileNotExist 
                             ?dboxBanner "File doesnot exist!" 
                             ?dboxText strcat(vamsFile "\ndoesnot exist! Please generate file first!" )
                             ?callback "genVAMSFile()"
                            )
            displayErrBox(sprintf(nil "%s is not a file, please generate vams file first\n" vamsFile)))
    )
)


procedure(getViewExt(viewName)
    let((ret)
        ret = "vams"
        if(or(viewName == "systemVerilog" viewName == "systemverilog") ret = "sv")
        ret
    )
)

procedure(getViewName(extName)
    let((ret)
        ret = "Verilog-AMS"
        if(extName == "sv" ret = "SystemVerilog")
        ret
    )
)


procedure(genVAMSCellView()
    let((obj instCellName instLibName instViewName vamsFile cv1 viewExt ofile)
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        viewExt = getViewExt(instViewName)
        if(obj = ddGetObj(instLibName instCellName instViewName strcat("verilog." viewExt) nil "r") && !get(tbSelectionForm 'override)->value then
            displayErrBox(sprintf(nil "%s %s %s exists and should not be overiding.\n",instLibName instCellName instViewName))
        else
            vamsFile = genVAMSFile()
            genVAMSCellViewGeneral(instCellName instLibName instViewName vamsFile t)
            if(get(tbSelectionForm 'genSymbol)->value schViewToView(instLibName instCellName instLibName instCellName instViewName "symbol" "_vmsVmsToPinList" "schPinListToSymbolGen")
            )
        )
    )
)

procedure(genVAMSCellViewGeneral(instCellName instLibName instViewName sourceFile @optional (overwrite nil))
    let((obj cv1 ofile viewExt overRideFile)
        saveLast()
            viewExt = getViewExt(instViewName)
            if(and(obj = ddGetObj(instLibName instCellName instViewName  strcat("verilog." viewExt) nil "w") !overwrite) then
                overRideFile = hiDisplayAppDBox(?name 'overRideFile
                             ?dboxBanner "Overiding exist cell"
                             ?dboxText strcat("Do you want to overriding the existing cell " instLibName " " instCellName " " instViewName " "  "?" )
                             ?dialogType hicQuestionDialog
                             ?buttonLayout 'YesNo
                            )
            else
                overRideFile = t
            )
            if(overRideFile then
                cv1 = dbOpenCellViewByType(instLibName instCellName instViewName "netlist" "ac")
                dbSave(cv1)
                dbClose(cv1)
                ofile = strcat(ddGetObj(instLibName)~>readPath "/" instCellName "/" instViewName strcat("/verilog." viewExt))
                system(sprintf(nil "/bin/cp %s %s" sourceFile ofile))
                printf("/bin/cp %s %s" sourceFile ofile)
            else
                displayErrBox(sprintf(nil "%s %s %s exists and is not overiding.\n",instLibName instCellName instViewName))
            )
    )
)

procedure(CCScopyAsk(fromLib fromCell fromView toLib toCell toView @optional (overWrite t) )
    let((overRideFile)
        if(!overWrite then
            overRideFile = hiDisplayAppDBox(?name 'overRideFile
                             ?dboxBanner "Overiding exist cell"
                             ?dboxText strcat("Do you want to overriding the existing cell" toLib " " toCell " " toView " "  "?" )
                             ?dialogType hicQuestionDialog
                             ?buttonLayout 'YesNo
                            )
        else
            overRideFile = t
        )
        if(overRideFile then
            CCScopyViewCV(fromLib fromCell fromView toLib toCell toView  overRideFile)
        else
            displayWarnBox(sprintf(nil "%s %s %s exists and is not overiding.\n",toLib toCell toView ))
        )
    )
)
procedure(CCScopyViewCV(fromLib fromCell fromView toLib toCell toView @optional  (overWrite t) )
    let( (srcSpecList srcSpec dstSpecList dstSpec)
      srcSpecList = gdmCreateSpecList()
      srcSpec = gdmCreateSpec(fromLib fromCell fromView nil "CDBA")
      gdmAddSpecToSpecList( srcSpec srcSpecList)

      dstSpecList = gdmCreateSpecList()
      dstSpec = gdmCreateSpec(toLib toCell toView nil "CDBA")
      gdmAddSpecToSpecList( dstSpec dstSpecList)

      ccpCopy( srcSpecList dstSpecList overWrite 'CCP_EXPAND_ALL )
      gdmResetSpecList(srcSpecList)
      gdmResetSpecList(dstSpecList)
   ) ;let
) ;procedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procedure(get_co_state(cell_lib cell_name cell_view)
    let((objId spec state)
        objId = ddGetObj(cell_lib cell_name cell_view "*")
        spec = gdmCreateSpecFromDDID(objId)
        state = car(reverse(parseString(caar(reverse(gdmstatus(spec 6))))))
        list(state spec)
    )
)

procedure(check_out_spec(spec)
    let((specList)
        specList = gdmCreateSpecList()
        gdmAddSpecToSpecList(spec specList)
        when(specList != nil gdmco(specList))
    )
)

procedure(check_out_cell(cell_lib cell_name cell_view)
    let((state_list spec state specList)
        state_list = get_co_state(cell_lib cell_name cell_view)
        spec = cadr(state_list)
        state = car(state_list)
        when(state == "gdmStateCI"
            check_out_spec(spec)
        )
    )
)

procedure(updateVAMSCellView()
    let((obj instCellName instLibName instViewName vamsFile ofile vamsIn vamsFileStr vamsStr noPrintStart emptyNoPrintStart emptyLine cv1 viewExt vams_temp_dir)
        saveLast()
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        vamsFileStr = ""
        viewExt = getViewExt(instViewName)
        ofile = strcat(pwd() "/" instLibName "/" instCellName "/" instViewName strcat("/verilog." viewExt))
        if(obj = ddGetObj(instLibName instCellName instViewName  strcat("verilog." viewExt) nil "r")  then
            vamsIn = infile(ofile)
            noPrintStart = 0
            emptyLine = 0
            emptyNoPrintStart = 0
            while(gets(vamsStr vamsIn)
                if(rexMatchp("`ifndef top" vamsStr) || rexMatchp("`ifndef stim" vamsStr) then 
                    noPrintStart = 1
                )
                if(rexMatchp("^\n$" vamsStr) emptyLine += 1 emptyLine = 0)
                if(emptyLine >=2 emptyNoPrintStart = 1 emptyNoPrintStart = 0)
                ;if(rexMatchp("`if" vamsStr) || rexMatchp("`endif" vamsStr) || rexMatchp("`define top" vamsStr) || rexMatchp("`define stim" vamsStr) then 
                if(noPrintStart == 0 && emptyNoPrintStart == 0 then
                    printf(vamsStr)
                    if(rexMatchp("^[ \t]*module" vamsStr) vamsStr = strcat(vamsTopDef() vamsStr))
                    vamsFileStr = sprintf(nil "%s%s" vamsFileStr vamsStr)
                else
                    if(rexMatchp("`endif" vamsStr) then 
                        noPrintStart = 0
                    )
                )
            )
            vams_temp_dir = strcat(pwd() "/vams_temp")
            vamsFile = sprintf(nil "%s/%s_%s_%s.vams" vams_temp_dir, instLibName, instCellName, instViewName)
            ofileH = outfile(vamsFile "w")
            fprintf(ofileH "%s" vamsFileStr)
            close(ofileH)
            close(vamsIn)
        else
            obj = ddGetObj(instLibName instCellName instViewName  strcat("verilog." viewExt) nil "w")
            cv1 = dbOpenCellViewByType(instLibName instCellName instViewName "netlist" "ac")
            dbSave(cv1)
            dbClose(cv1)
            vamsFile = genVAMSFile(1)
        )
        ;printf("%s" vamsFile)
        system(sprintf(nil "/bin/cp %s %s" vamsFile ofile))
    )
)

procedure(saveSettings(@optional (override_here nil))
    let((instCellName instLibName instViewName oport saveFile key keyValue overRideFile keyValueList vams_temp_dir)
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        vams_temp_dir = strcat(pwd() "/vams_temp")
        os_makedir(vams_temp_dir)
        if(instCellName == "" displayErrBox("cell name cannot be blank\n") saveFile = sprintf(nil "%s/%s_%s_%s.txt" vams_temp_dir, instLibName,
            instCellName, instViewName))
        overRideFile = t
        if(and(override_here == nil isFile(saveFile)) then 
        ;if(isFile(saveFile) then 
            overRideFile = hiDisplayAppDBox(?name 'overRideFile
                             ?dboxBanner "Overiding exist file"
                             ?dboxText strcat("Do you want to overriding the existing file" saveFile "?" )
                             ?dialogType hicQuestionDialog
                             ?buttonLayout 'YesNo
                            )
        )
        if(overRideFile then
            oport = outfile(saveFile)
            fprintf(oport "tbKeys='(nil\n")
            foreach(key '(overridetb override needSensitivity vdd vss testName electrical vsource isource_vdd
            isource_vss genSymbol digRegs traditional top i2c group )
                keyValue =  get(tbSelectionForm key)->value
                if(stringp(keyValue) then
                    keyValueList = parseString(keyValue)
                    keyValue = buildString(sort(keyValueList 'alphalessp) " ")
                )
                fprintf(oport " %s %L\n" key keyValue)
            )
            fprintf(oport ")\n")
            close(oport)
            printf("saved settings to %s.\n" saveFile)
        else
            displayWarnBox("File exists, and you donot want to save..\n")
        )
    )
)

procedure(displayErrBox(inMsg)
    displayBox(inMsg "error")
)

procedure(displayWarnBox(inMsg)
    displayBox(inMsg "warning")
)

procedure(displayBox(inMsg msgType)
    let((errMsgReturn )
        errMsgReturn = hiDisplayAppDBox(?name 'errMsgButton
                         ?dboxBanner msgType
                         ?dboxText inMsg
                         ?dialogType hicMessageDialog
                         ?buttonLayout 'Close
                        )
        if(msgType == "error" error(inMsg) warn(inMsg))
    )
)

procedure(clearSettings()
    let((instCellName instLibName instViewName oport saveFile key keyValue )
        saveLast()
        foreach(key '(needSensitivity overridetb override 
                vdd vss testName electrical vsource isource_vdd isource_vss genSymbol corr digRegs traditional top i2c group)
            keyValue =  get(tbSelectionForm key)->value
            if(stringp(keyValue) then
                get(tbSelectionForm key)->value = ""
            else
                get(tbSelectionForm key)->value = nil
            )
        )
        foreach(key '(needSensitivity traditional)
            get(tbSelectionForm key)->value = t
        )
        get(tbSelectionForm 'vdd)->value = ""
        get(tbSelectionForm 'vss)->value = ""
    )
)

procedure(loadSettings()
    let((instCellName instLibName instViewName saveFile key loadFileList vams_temp_dir)
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        vams_temp_dir = strcat(pwd() "/vams_temp")
        os_makedir(vams_temp_dir)
        if(instCellName == "" displayErrBox("cell name cannot be blank\n") saveFile = sprintf(nil "%s/%s_%s_%s.txt" vams_temp_dir, instLibName, instCellName, instViewName))
        unless(isFile(saveFile) 
            loadFileList = hiDisplayFileDialog(
                                ?dialogName 'myFileDialog
                                ?caption "Load from file..."
                                ?filter "text (*.txt)"
                                ?mode 'existingFile
                                ?acceptMode 'open
                               )
            if(loadFileList then
                saveFile = buildString(loadFileList "/")
            else
                displayErrBox("you didnot choose any file.. please reload.")
            )
        )
        if(isFile(saveFile) then
            load(saveFile)
            foreach(key '(overridetb override needSensitivity vdd vss testName electrical vsource isource_vdd isource_vss
            genSymbol corr digRegs traditional top i2c group)
                when(get(tbKeys key) get(tbSelectionForm key)->value = get(tbKeys key))
            )
        )
    )
)

procedure(genTestBench()
    let((origViewName tgtLibName tgtCellName tgtViewName tbLibName tbCellName tbViewName symbolView symbolOpenView
    origSymView tgtSymView tbObj cv win inst1 x1 x2 y1 y2 inst2 config_name)
        saveLast()
        origLibName = get(tbSelectionForm 'libName)->value
        origCellName = get(tbSelectionForm 'cellName)->value
        origViewName = get(tbSelectionForm 'viewName)->value
        tgtLibName = get(tbSelectionForm 'tgtLibName)->value
        tgtCellName = get(tbSelectionForm 'tgtCellName)->value
        tgtViewName = get(tbSelectionForm 'tgtViewName)->value
        if(tgtCellName == origCellName displayErrBox("You should have a cell and stim to create tb\n"))
        if(tgtLibName == origLibName && not(rexMatchp(getShellEnvVar("USER") origLibName)) displayErrBox("You should have a different design and sim library\n"))
        unless(rexMatchp(strcat(getShellEnvVar("USER") "$") tgtLibName) displayErrBox("You test bench should be in your own directory"))
        tbLibName = get(tbSelectionForm 'tgtLibName)->value
        tbCellName = strcat("TB_" origCellName)
        tbViewName = "schematic"
        symbolView = "symbol"
        symbolOpenView = "schematicSymbol"
        origSymView = dbOpenCellViewByType(origLibName origCellName symbolView symbolOpenView "r")
        unless(origSymView displayErrBox(sprintf(nil "%s-%s-%s doesnot exist!" origLibName origCellName symbolView)))
        tgtSymView = dbOpenCellViewByType(tgtLibName tgtCellName symbolView symbolOpenView "r")
        unless(tgtSymView displayErrBox(sprintf(nil "%s-%s-%s doesnot exist!" tgtLibName tgtCellName symbolView)))
        tbObj = ddGetObj(tbLibName tbCellName tbViewName)
        if((!tbObj) || (tbObj && get(tbSelectionForm 'overridetb)->value) then
            if(!tbObj  then 
                win = deNewCellView(tbLibName tbCellName tbViewName tbViewName nil) 
                cv = win~>cellView
            else
                cv = dbOpenCellViewByType(tbLibName tbCellName tbViewName "" "w")
            )
            inst1 = schCreateInst(cv tgtSymView "" 0:0 "R0")
            inst1~>name = "STIM"
            dbSave(cv)
            x1 = caar(inst1~>bBox)
            x2 = caadr(inst1~>bBox)
            y1 = cadar(inst1~>bBox)
            y2 = cadadr(inst1~>bBox)

            inst2 = schCreateInst(cv origSymView "" x2+0.9:y1 "R0")
            inst2~>name = "DUT"
            dbSave(cv)
            dbClose(cv)
            win = deOpenCellView(tbLibName tbCellName tbViewName tbViewName nil "a")
            cv1 = win ~> cellView
            foreach(inst cv1~>instances
                geSelectObject(inst)
                schHiCreateWireStubs()
            )
            schHiCheckAndSave()
            dbSave(cv1)
            ;dbClose(cv1)
            ;hiCloseWindow(win)
            ;schViewToView(tbLibName tbCellName tbLibName tbCellName "schematic" "symbol" "schSchemToPinList" "schPinListToSymbol")
            ;genTB()

        else
            ;deOpenCellView(tbLibName tbCellName tbViewName tbViewName nil "a")
            printf("Cannot create cellview %s in %s since it exists.\n" tbCellName tbLibName)
        )
        ;updateVAMSCellView()
        create_sim_dirs()
        gen_test_file()
        ;create_update_config(lib_name cell_name config_name top_view_name @optional (override nil)(in_lib_list list()))
        foreach(config_name list("config_FM" "config_FS")
            printf("2463 creating config %s.\n", config_name)
            create_update_config(tbLibName tbCellName config_name tbViewName)
        )
    )
)

procedure(genTestView(topName)
    let((testLibName testCellName testViewName testFileStr moduleName allPreDefines
        trueDefines defines dindex preDefine trueDefine includes mainTest endModule
        testFile vams_temp_dir)

        testLibName = get(tbSelectionForm 'tgtLibName)->value
        ;testCellName = get(tbSelectionForm 'testName)->value
        testCellName = strcat("TEST_" get(tbSelectionForm 'cellName)->value)
        testViewName = "verilogams"
        testFileStr = vamsHeaderGeneral(testLibName testCellName testViewName)
        moduleName = sprintf(nil "module %s" testCellName)
        allPreDefines = list("top" "MOD" "SCH" "MOD_STIM" "SCH_STIM")
        trueDefines = list(topName "`top.TS_MOD" "`top.TS_SCH" "`MOD.stim" "`SCH.stim")
        defines = ""
        dindex = 0
        foreach(preDefine allPreDefines
            dindex += 1
            trueDefine = nthelem(dindex trueDefines)
            defines = sprintf(nil "%s`ifndef %s\n    `define %s%s%s\n`endif\n", defines, preDefine, preDefine, numSpace(30 - strlen(preDefine)) , trueDefine)
        )
        testFileStr = sprintf(nil "%s%s", testFileStr, defines)
        testFileStr = sprintf(nil "%s%s();\n", testFileStr, moduleName)
        includes = "`include \"./functional_verification/tasks/commonTasks.vams\"\n"
        testFileStr = sprintf(nil "%s%s", testFileStr, includes)
        mainTest = sprintf(nil "initial begin\n    testName = %L;\n    startTest;\n    fork\n        `MOD_STIM.Test;\n        `SCH_STIM.Test;\n    join\n    #1_000_000;\n    finishTest;\n    #100_000;\n    $finish;\nend\n" topName)
        testFileStr = sprintf(nil "%s%s", testFileStr, mainTest)
        endModule = strcat("endmodule\n//end of module " testCellName "\n")
        testFileStr = sprintf(nil "%s%s", testFileStr, endModule)
        vams_temp_dir = strcat(pwd() "/vams_temp")
        testFile = sprintf(nil "%s/test.vams" vams_temp_dir)
        writeToFile(testFileStr testFile)
        genVAMSCellViewGeneral(testCellName testLibName testViewName testFile)
        schViewToView(testLibName testCellName testLibName testCellName testViewName "symbol" "_vmsVmsToPinList" "schPinListToSymbolGen")
    )
)

procedure(genTB()
    let((tsLibName tsCellName tsViewName tbLibName tbCellName tbViewName testLibName
        testCellName testViewName symbolView symbolOpenView tsView s testView
        tbObj win cv inst1 name x1 x2 y1 y2 inst2 inst3 cv1 )

        tsLibName = get(tbSelectionForm 'tgtLibName)->value
        tsCellName = strcat("TS_" origCellName)
        tsViewName = "symbol"
        tbLibName = get(tbSelectionForm 'tgtLibName)->value
        tbCellName = strcat("TB_" origCellName)
        tbViewName = "schematic"
        testLibName = get(tbSelectionForm 'tgtLibName)->value
        ;testCellName = get(tbSelectionForm 'testName)->value
        testCellName = strcat("TEST_ " get(tbSelectionForm 'cellName)->value)
        testViewName = "verilogams"
        unless(ddGetObj(testLibName testCellName "symbol")
            genTestView(tbCellName)
        )
        symbolView = "symbol"
        symbolOpenView = "schematicSymbol"
        tsView = dbOpenCellViewByType(tsLibName tsCellName symbolView symbolOpenView "r")
        unless(tsView displayErrBox(sprintf(nil "%s-%s-%s doesnot exist!" tsLibName tsCellName symbolView)))
        testView = dbOpenCellViewByType(testLibName testCellName symbolView symbolOpenView "r")
        unless(testView displayErrBox(sprintf(nil "%s-%s-%s doesnot exist!" testLibName testCellName symbolView)))
        tbObj = ddGetObj(tbLibName tbCellName tbViewName)
        if((!tbObj) || (tbObj && get(tbSelectionForm 'overridetb)->value) then
            if(!tbObj  then 
                win = deNewCellView(tbLibName tbCellName tbViewName tbViewName nil) 
                cv = win~>cellView
            
            else 
                cv = dbOpenCellViewByType(tbLibName tbCellName tbViewName "" "w")
            )
            inst1 = schCreateInst(cv tsView "" 0:0 "R0")
            inst1~>name = "TS_MOD"
            dbSave(cv)
            x1 = caar(inst1~>bBox)
            x2 = caadr(inst1~>bBox)
            y1 = cadar(inst1~>bBox)
            y2 = cadadr(inst1~>bBox)
            inst2 = schCreateInst(cv tsView "" 0:-y2-0.2 "R0")
            inst2~>name = "TS_SCH"
            inst3 = schCreateInst(cv testView "" x2+0.2:-y2/2-0.1 "R0")
            inst3~>name = "TEST"
            dbSave(cv)
            dbClose(cv)
            win = deOpenCellView(tbLibName tbCellName tbViewName tbViewName nil "a")
            cv1 = win ~> cellView
            schHiCheckAndSave()
            dbSave(cv1)
        )
    )
)

procedure(reloadScript()
    load("~xzhang02/skill/createTB.il")
)

procedure(genWrapper()
    let((pinDefList listInd origName instCellName wrapperVams moduleDef allPinDef
        allPinComma pinCommaLen intDef instInst instPinLen pinDef fieldValue
        pinList extractedInfoList extractedNameList extractedNameRangeList
        extractedRangeTable termDir subListInd extractedList pin termRange
        termDDef termRanges termSym pinDis senseStr instInstPin intPinName
        pinComma termRange2 assignStat endModule instInstStat dirDisplayed
        power_list vams_temp_dir)

        readPins()
        pinDefList = '(inputPins outputPins inoutPins)
        listInd = 0
        origName = strcat(get(tbSelectionForm 'cellName)->value "")
        instLibName = get(tbSelectionForm 'libName)->value 
        instCellName = strcat(get(tbSelectionForm 'cellName)->value "_wrapper")
        instViewName = "verilogams"
        wrapperVams = vamsHeaderWrapper(instCellName)
        moduleDef = strcat("module " instCellName)
        ;wrapperVams = strcat(wrapperVams moduleDef "(")
        allPinDef = "\n    //Global power and ground for digtop signals\n"
        allPinDef = strcat(allPinDef "    wire (* integer inh_conn_prop_name = \"vdd\";integer inh_conn_def_value = \"cds_globals.\\\\vdd! \"; *) powr;\n    wire (* integer inh_conn_prop_name = \"vss\";integer inh_conn_def_value = \"cds_globals.\\\\vss! \"; *) grnd;\n")
        ;main pin wire/direction definition string
        allPinComma  = strcat(moduleDef "(")
        pinCommaLen = strlen(allPinComma)
        intDef = "" ;internal nodes definitions
        instInstStat = strcat("\n    // beginning of " origName " instantiation\n")
        instInst = strcat("    " origName " " origName "(")
        instPinLen = strlen(instInst)
        power_list = list("vdd" "vss")

        foreach(pinDef pinDefList
            listInd += 1
            fieldValue = get(tbSelectionForm pinDef)->value
            pinList = parseString(fieldValue)
            pinList = uniqueList(pinList)
            extractedInfoList = extractPinList(pinList)
            extractedNameList = car(extractedInfoList)
            extractedNameRangeList = cadr(extractedInfoList)
            extractedRangeTable = caddr(extractedInfoList)
            case(listInd
                (1
                    termDir = "input"
                )
                (2
                    termDir = "output"
                )
                (3
                    termDir = "inout"
                )
            )
            subListInd = 0
            dirDisplayed = 0
            foreach(extractedList list(extractedNameList extractedNameRangeList)
                subListInd += 1
                if(length(extractedList) > 0 then
                    if(dirDisplayed == 0 then
                        dirDisplayed = 1
                        allPinDef = sprintf(nil "%s\n    //%s pins\n", allPinDef, termDir)
                        intDef = sprintf(nil "%s\n    //internal %s pins\n", intDef, termDir)
                    )
                    foreach(pin extractedList
                        printf("%s\n", pin)
                        termRange = remove_trailing_following_spaces(extractedRangeTable[pin])
                        termDDef = if(rexMatchp(" " termRange) 1 0) ;terminal is double defined
                        termRanges = if(rexMatchp(" " termRange) list(getTotalRange(termRange)) list(termRange))
                        if(pinCommaLen > 60 then
                            allPinComma = strcat(allPinComma "\n" numSpace(4))
                            pinCommaLen = 0
                        )
                        if(instPinLen > 60 then
                            instInst = strcat(instInst "\n" numSpace(8))
                            instPinLen = 0
                        )
                        foreach(termRange termRanges 
                            termRange = if(termRange == ""  " " strcat(" " termRange " "))
                            termSym = ";"
                            if(!member(pin power_list) then
                                pinDis = "wire"
                                senseStr =  sprintf(nil "(* integer supplySensitivity = %L;integer groundSensitivity = %L;*) ", "powr", "grnd" )
                            else
                                pinDis = "electrical"
                                senseStr =  sprintf(nil "")
                            )
                            instInstPin = ""
                            intPinName = strcat(pin "_int")
                            pinComma = ""
                            if(termDDef == 1 then
                                foreach(termRange2 parseString(extractedRangeTable[pin])
                                    termRange2 = strcat(" " termRange2 " ")
                                    allPinDef = sprintf(nil "%s    %s%s%s%s%s\n", allPinDef, termDir, termRange2, senseStr, pin, termSym)
                                    if(!member(pin power_list) then instInstPin = sprintf(nil "%s.%s%s(%s%s), ", instInstPin, pin, termRange2, intPinName, termRange2))
                                    pinComma = strcat(pinComma pin termRange2 ", ")
                                )
                            else
                                allPinDef = sprintf(nil "%s    %s%s%s%s%s\n", allPinDef, termDir, termRange, senseStr, pin, termSym)
                                if(!member(pin power_list) then instInstPin = sprintf(nil "%s.%s(%s), ", instInstPin, pin, intPinName))
                                pinComma = strcat(pinComma pin ", ");all the pin list in parenthesis
                            )
                            pinCommaLen += strlen(pinComma)
                            allPinComma = strcat(allPinComma pinComma);all the pin list in parenthesis
                            instPinLen += strlen(instInstPin)
                            instInst = sprintf(nil "%s%s", instInst, instInstPin)
                            ;inistance instanstiation
                            allPinDef = sprintf(nil "%s    %s%s%s%s\t//\n", allPinDef, pinDis, termRange, pin, termSym)
                            ;wire sensitivity definition
                            if(!member(pin power_list) then intDef = sprintf(nil "%s    %s%s%s%s\t//internal node of %s pin %s\n", intDef, pinDis, termRange, intPinName, termSym, termDir, pin))
                            ;internal wire definition
                            case(listInd
                                (1
                                    assignStat = sprintf(nil "    assign %s = %s;\n", intPinName, pin)
                                )
                                (2
                                    assignStat = sprintf(nil "    assign %s = %s;\n", pin, intPinName)
                                )
                                (3
                                    assignStat = sprintf(nil "    assign %s = %s;\n", pin, intPinName)
                                )
                            );case
                            if(!member(pin power_list) then intDef = strcat(intDef assignStat)) ;assign statements
                        );termRange
                    );pin
                );length extractedpin > 0
            );each list
        );pindef
        rexCompile(", $")
        allPinComma = rexReplace(allPinComma, "", 0)
        instInst = rexReplace(instInst, "", 0)
        allPinComma = strcat(allPinComma ");\n")
        instInst = strcat(instInstStat instInst ");\n    // end of " origName " instantiation\n\n")
        endModule = strcat("endmodule \n//end of module " instCellName "\n")
        wrapperVams = strcat(wrapperVams allPinComma allPinDef intDef instInst endModule)
        vams_temp_dir = strcat(pwd() "/vams_temp")
        wrapperFile = sprintf(nil "%s/%s_%s_%s.vams" vams_temp_dir, instLibName, instCellName, instViewName)
        writeToFile(wrapperVams wrapperFile)
        genVAMSCellViewGeneral(instCellName instLibName instViewName wrapperFile)
        ahdlUpdateViewInfo(instLibName ?cell instCellName ?view instViewName)
        if(ddGetObj(instLibName origName "symbol") then
            CCScopyAsk(instLibName origName "symbol" instLibName instCellName "symbol" nil)
        )
        wrapperFile
    )
)

procedure(findMismatch()
    let((origLibName origCellName origViewName missingPorts extraPorts origSymObj
        origamsObj symPortsTable amsPortsTable port missingPortsStr missingPortsPrintStr pin_defs
        extraPortsStr extraPortsPrintStr newViewName vdd vss senseStr port_info_list analog_pins digital_pins pin_name pin_range)
        origLibName = get(tbSelectionForm 'libName)->value
        origCellName = get(tbSelectionForm 'cellName)->value
        origViewName = get(tbSelectionForm 'viewName)->value
        newViewName = get(tbSelectionForm 'tgtViewName)->value
        missingPorts = list()
        extraPorts = list()
        if(origSymObj = dbOpenCellViewByType(origLibName origCellName origViewName "" "r") then
            if(origamsObj = dbOpenCellViewByType(origLibName origCellName newViewName "" "r") then
                copyAllPins()
                symPortsTable = car(getTermTable(origSymObj))
                amsPortsTable = car(getTermTable(origamsObj))
                foreach(port symPortsTable->?
                    unless(and(member(port amsPortsTable->?) symPortsTable[port] == amsPortsTable[port])
                        missingPorts = append1(missingPorts port)
                    )
                )
                foreach(port amsPortsTable->?
                    unless(member(port symPortsTable->?)
                        extraPorts = append1(extraPorts port)
                    )
                )
            else 
                displayErrBox(sprintf(nil "Verilogams view doesnot exist for %s %s", origLibName,origCellName))
            )
        else
            displayErrBox(sprintf(nil "Symbol view doesnot exist for %s %s", origLibName,origCellName))
        )
        if(length(missingPorts) > 0 then
            vdd = get(tbSelectionForm 'vdd)->value
            vss = get(tbSelectionForm 'vss)->value
            senseStr = ""
            if(getSensitivity() senseStr =  sprintf(nil "(* integer supplySensitivity = %L;integer groundSensitivity = %L;*)", vdd, vss ))
            analog_pins = ""
            digital_pins = ""
            pin_defs = list()
            foreach(port missingPorts
                port_info_list = extract_pin(port)
                pin_name = car(port_info_list)
                pin_range = cadr(port_info_list)
                analog_pins = sprintf(nil "%s    %s %s%s;    electrical %s%s;\n",analog_pins, symPortsTable[port], pin_range, pin_name, pin_range, pin_name)
                digital_pins = sprintf(nil "%s    %s %s%s %s;\n    wire %s%s;\n",digital_pins, symPortsTable[port], pin_range, senseStr, pin_name, pin_range, pin_name)
                pin_defs = append1(pin_defs, pin_name)
            )
            missingPortsStr = buildString(pin_defs ", ")
            missingPortsPrintStr = strcat("Add missing pins: " missingPortsStr "\n")
            displayWarnBox(missingPortsPrintStr)
            printf(missingPortsPrintStr)
            printf(gen_pin_def_from_symbol(origSymObj))
            printf(analog_pins)
            printf(digital_pins)
        )
        if(length(extraPorts) > 0 then
            extraPortsStr = buildString(extraPorts " ")
            extraPortsPrintStr = strcat("Remove extra pins: " extraPortsStr "\n")
            displayWarnBox(extraPortsPrintStr)
        )
        if(length(missingPorts) > 0 || length(extraPorts) > 0 then
            update_vamsfile_from_symbol(origLibName origCellName origViewName newViewName)
        )
        if(and(length(missingPorts) == 0 length(extraPorts) == 0) then
            displayWarnBox("Symbol & Verilogams Match...\n")
        )
    )
)

procedure(getTermTable(thisObj)
    let((thisTable term terms_array term_dir)
        thisTable = makeTable("instance pin table")
        terms_array = list()
        if(thisObj~>terminals then
            foreach(term thisObj~>terminals
                term_dir = if(term~>direction == "inputOutput" "inout" term~>direction)
                thisTable[term~>name] = term_dir
                terms_array = append1(terms_array term~>name)
            )
        )
        printf(buildString(terms_array, ", "))
        printf("\n")
        list(thisTable, terms_array)
    )
)

procedure(gen_pin_def_from_symbol(this_obj)
    let((term terms_array thisTable terms_name_array term_info term_name term_range cell_name module_def)
        thisTable = makeTable("instance pin table")
        terms_array = list()
        terms_name_array = list()
        if(this_obj~>terminals then
            foreach(term this_obj~>terminals
                thisTable[term~>name] = term~>direction
                terms_array = append1(terms_array term~>name)
                term_info = extract_pin(term~>name)
                term_name = car(term_info)
                term_range = cadr(term_info)
                terms_name_array = append1(terms_name_array term_name)
            )
            cell_name = this_obj~>cellName
            module_def = split_string_by_number(strcat("module " cell_name "(" buildString(reverse(terms_name_array), ", ") ");\n"), 60)
        )
    )
)

procedure(split_string_by_number(in_str, number_col)
    let((str_array out_str_array num_char ch)
        str_array = parseString(in_str "")
        out_str_array = list()
        num_char = 0
        foreach(ch str_array
            num_char += 1
            if(ch == " " then
                if(num_char > number_col then
                    out_str_array = append1(out_str_array, "\n")
                    num_char = 0
                else
                    out_str_array = append1(out_str_array, ch)
                )
            else
                out_str_array = append1(out_str_array, ch)
            )
        )
        out_str = buildString(out_str_array, "")
    )
)

procedure(getTermTableDirSeq(thisObj)
    let((dirTable term_list rangeTable term_dir)
        dirTable = makeTable("instance pin dir table")
        rangeTable = makeTable("instance range table")
        term_list = list()
        if(thisObj~>terminals then
            foreach(term thisObj~>terminals
                term_info = extract_pin(term~>name)
                term_name = car(term_info)
                term_range = cadr(term_info)
                term_list = append1(term_list term_name)
                term_dir = term~>direction
                if(term_dir == "inputOutput" then
                    term_dir = "inout"
                )
                if(member(term_name dirTable->?) then
                    dirTable[term_name] = append1(dirTable[term_name] term_dir)
                    rangeTable[term_name] = append1(rangeTable[term_name] term_range)
                else
                    dirTable[term_name] = list(term_dir)
                    rangeTable[term_name] = list(term_range)
                )
            )
        )
        list(dirTable rangeTable term_list)
    )
)

procedure(getTermTableSeqFromForm()
   let((dirTable term_list rangeTable term_dir)
        dirTable = makeTable("instance pin dir table")
        rangeTable = makeTable("instance range table")
        term_list = list()
        pin_fields = '(tgtinputPins tgtoutputPins tgtinoutPins)
        field_index = 0
        foreach(pin_field pin_fields
            field_index += 1
            case(field_index
                (1
                    term_dir = "input"
                )
                (2
                    term_dir = "output"
                )
                (3
                    term_dir = "inout"
                )
            )
            pin_list = parseString(get(tbSelectionForm pin_field)->value)
            foreach(pin pin_list
                term_info = extract_pin(pin)
                term_name = car(term_info)
                term_range = cadr(term_info)
                term_list = append1(term_list term_name)
                if(member(term_name dirTable->?) then
                    dirTable[term_name] = append1(dirTable[term_name] term_dir)
                    rangeTable[term_name] = append1(rangeTable[term_name] term_range)
                else
                    dirTable[term_name] = list(term_dir)
                    rangeTable[term_name] = list(term_range)
                )
            )
        )
        list(dirTable rangeTable term_list)
    )
)

procedure(gen_pin_def()
    let((pin_info module_name)
        pin_info = get_pin_info()
        module_name = get(tbSelectionForm 'tgtCellName)->value
       )
)

procedure(get_pin_info()
    let((pin_info)
        if(is_cell_model() then
            pin_info = getTermTableDirSeq(get_orig_obj())
        else
            pin_info = getTermTableSeqFromForm()
        )
        pin_info
    )
)

procedure(check_pin_info(term_info_list)
    let((dir_table range_table term_list err_msg term term_range term_dir)
        dir_table = car(term_info_list)
        range_table = cadr(term_info_list)
        term_list = caddr(term_info_list)
        err_msg = ""
        foreach(term term_list
            term_range = range_table[term]
            term_dir = dir_table[term]
            if(length(term_range) != length(term_dir) then
                err_msg = sprintf(nil "%s%s has different length of range(%0d) and direction(%0d) spec.\n", err_msg, term, length(term_range), length(term_dir))
            )
        )
        if(err_msg != "" then
            displayErrBox(err_msg)
            nil
        else
            t
        )
   )
)

procedure(group_pins(term_info_list)
    let((dir_table range_table term_list term_group_table term_group_range_table term_freq_table term term_range_list term_dir_list term_range term_dir group_name)
        dir_table = car(term_info_list)
        range_table = cadr(term_info_list)
        term_list = caddr(term_info_list)
        term_group_table = makeTable("table for terminal groups.")
        term_group_range_table = makeTable("table for terminal groups.")
        term_freq_table = makeTable("table for terminal groups.")
        foreach(term term_list
            term_range_list = range_table[term]
            term_dir_list = dir_table[term]
            if(length(term_range_list) == 1 && length(term_dir_list) == 1 then
                term_range = car(term_range_list)
                term_dir = car(term_dir_list)
            else
                if(member(term term_freq_table->?) then
                        term_freq_table[term] += 1
                else
                        term_freq_table[term] = 1
                )
                term_range = nthelem(term_freq_table[term] term_range_list)
                term_dir = nthelem(term_freq_table[term] term_dir_list)
            )
            if(term_range != "" then
                group_name = strcat(term_dir "__range")
            else
                group_name = term_dir
            )
            if(member(group_name term_group_table->?) then
                term_group_table[group_name] = append1(term_group_table[group_name] term)
            else
                term_group_table[group_name] = list(term)
            )
            if(rexMatchp("__range" group_name) then
                if(member(group_name term_group_range_table->?) then
                    term_group_range_table[group_name] = append1(term_group_range_table[group_name] term_range)
                else
                    term_group_range_table[group_name] = list(term_range)
                )
            )
        )
    list(term_group_table, term_group_range_table)
    )
)

procedure(gen_trad_pin_list(module_name term_info_list)
        dir_table = car(term_info_list)
        range_table = cadr(term_info_list)
        term_list = caddr(term_info_list)
        pin_def = strcat("module " module_name "(")
        pin_len = strlen(pin_def)
        term_index_table = makeTable("# of term appearance time")
        term_overall_range_table = makeTable("overall range of the terminal")
        term_index = 0
        foreach(term term_list
            term_index += 1
            if(length(range_table[term]) == 1 then
                term_def = term
            else
                if(member(term term_index_table->?) then
                    term_index_table[term] += 1
                else
                    term_index_table[term] = 1
                )
                term_range_index = term_index_table[term]
                term_range = nthelem(term_range_index range_table[term])
                term_def = strcat(term_range " " term)
            )
            pin_def = strcat(pin_def term_def)
            if(term_index < length(term_list) then
                pin_def = strcat(pin_def ",")
                pin_len += strlen(term_def) + 2
                if(pin_len > 60 then
                    pin_def = strcat(pin_def "\n    ")
                    pin_len = 0
                else
                    pin_def = strcat(pin_def " ")
                )
            else
                pin_def = strcat(pin_def ");\n")
            )
        )
)

procedure(is_cell_model()
    let((tgtLibName tgtCellName tgtViewName origLibName origCellName origViewName cell_model_match)
        tgtLibName = get(tbSelectionForm 'tgtLibName)->value
        tgtCellName = get(tbSelectionForm 'tgtCellName)->value
        tgtViewName = get(tbSelectionForm 'tgtViewName)->value
        origLibName = get(tbSelectionForm 'libName)->value
        origCellName = get(tbSelectionForm 'cellName)->value
        origViewName = get(tbSelectionForm 'viewName)->value
        cell_model_match = (tgtLibName == origLibName) && (tgtCellName == origCellName)
    )
)
procedure(get_tgt_obj()
    let((tgtLibName tgtCellName tgtViewName tgtObj)
        tgtLibName = get(tbSelectionForm 'tgtLibName)->value
        tgtCellName = get(tbSelectionForm 'tgtCellName)->value
        tgtViewName = get(tbSelectionForm 'tgtViewName)->value
        tgtObj = dbOpenCellViewByType(tgtLibName tgtCellName tgtViewName "" "r")
    )
)

procedure(get_orig_obj( @optional (view nil))
    let((origLibName origCellName origViewName origObj)
        origLibName = get(tbSelectionForm 'libName)->value
        origCellName = get(tbSelectionForm 'cellName)->value
        if(view then
            origViewName = view
        else
            origViewName = get(tbSelectionForm 'viewName)->value
        )
        origObj = dbOpenCellViewByType(origLibName origCellName origViewName "" "r")
    )
)

procedure(writeToFile(inStr inFile)
    let((ofileH)
        printf("Writing %s to %s.\n", inStr, inFile)
        system(buildString(list("chmod" "755" inFile) " "))
        ofileH = outfile(inFile "w")
        fprintf(ofileH "%s" inStr)
        close(ofileH)
        inFile
    )
)

;create the simulation directories for block level simulations
procedure(create_sim_dirs()
    let((tbCellName tb_block_dir all_block_sim_dirs all_dirs dir sub_dir_items sub_dir block_dir block_template_dir file)
        block_dir = strcat(getShellEnvVar("ISIL_PROJ_HOME") "/block_verification")
        block_template_dir = strcat(block_dir "/templates/")
        tb_block_dir = get_tb_block_dir()
        os_makedir(tb_block_dir)
        all_block_sim_dirs = "defines functions optionFiles outputs plan probes simvision tasks tests connectRules"
        all_dirs = parseString(all_block_sim_dirs)
        foreach(dir all_dirs
            sub_dir = strcat(tb_block_dir "/" dir)
            os_makedir(sub_dir)
        )
        copy_file_list = list("/tasks/block_specific_include.sv" "/tasks/block_specific_include.vams" "/optionFiles/rtl.opt" "/connectRules/ie_card.scs" "/optionFiles/cov.opt" "/optionFiles/connect.opt" "/optionFiles/opt.opt" "/probes/probe.tcl" "/defines/tb_defines.vams")
        foreach(file copy_file_list
            os_copyfile(strcat(block_template_dir file) strcat(tb_block_dir file) nil)
            update_file_from_template(strcat(tb_block_dir file))
        )
    )
)

procedure(update_file_from_template(in_file)
    let((origCellName tbCellName out_lines in_h line)
        origCellName = get(tbSelectionForm 'cellName)->value
        tbCellName = strcat("TB_" origCellName)
        out_lines = list()
        if(isFile(in_file) then
            ;printf("Test 3091.%s\n", in_file)
            in_h = infile(in_file)
            while(gets(line in_h)
                rexCompile("\\$templates\\$")
                if(rexExecute(line) then
                    line = rexReplace(line, tbCellName, 0)
                )
                out_lines = append1(out_lines line)
            )
            close(in_h)
            out_str = buildString(out_lines "")
            writeToFile(out_str in_file)
            ;printf("Test 3091.\n%s\n", out_str)
            ;printf("%s", buildString(out_lines ""))
            out_str
        )
    )
)

procedure(gen_test_file()
    let((vams_lines test_module_name vams_file_line test_file_name overRideFile test_file_list test_ext test_file)
        test_lines = list()
        test_module_name = get_test_module_name()
        reg_info_list = cadr(getAllReg())
        reg_test_info_list = gen_reg_test_traverse(reg_info_list)
        test_file_name = get_test_file_name()
        test_file_path = get_test_file_path_noext()
        printf("Test path...%s\n", test_file_path)
        foreach(test_ext get_test_ext()
            printf("%s, Test...\n", test_ext)
            overRideFile = nil
            test_file = strcat(test_file_path "." test_ext)
            printf("%s, Test...\n", test_file)
            test_lines = gen_test_file_lines(test_module_name test_file_name test_ext)
            if(test_file then
                unless(isFile(test_file) && not(get(tbSelectionForm 'override)->value)
                    if(isFile(test_file) then
                        overRideFile = hiDisplayAppDBox(?name 'overRideFile
                                 ?dboxBanner "Overiding exist file"
                                 ?dboxText strcat("Do you want to overriding the existing file " test_file "?" )
                                 ?dialogType hicQuestionDialog
                                 ?buttonLayout 'YesNo
                                )
                    else
                            overRideFile = t
                    )
                    if(overRideFile == t then
                        writeToFile(buildString(test_lines "\n") test_file)
                    )
                )
            )
        )
        unless(overRideFile
            printf("%s\n", buildString(test_lines "\n"))
        )
    )
)

procedure(gen_test_file_lines(test_module_name test_file_name @optional (file_ext "vams"))
    let((file_full_ext test_file_line test_lines )
        file_full_ext = ""
        if(file_ext == "vams" file_full_ext = "verilogams")
        if(file_ext == "sv" file_full_ext = "systemverilog")
        if(file_ext == "v" file_full_ext = "verilog")
        test_file_line = vamsHeaderGeneral(test_module_name test_file_name file_full_ext)
        test_lines = append1(test_lines test_file_line)
        test_lines = append1(test_lines sprintf(nil "module %s();", test_module_name))
        if(file_ext == "vams" then
            test_lines = append1(test_lines sprintf(nil "`include \"./functional_verification/tasks/common_block_tasks.vams\""))
            test_lines = append1(test_lines sprintf(nil "`include \"./block_verification/%s/tasks/block_specific_include.vams\"", strcat("TB_" get(tbSelectionForm 'cellName)->value)))
        )
        if(file_ext == "sv" then
            test_lines = append1(test_lines sprintf(nil "import type_i2c::*"))
            test_lines = append1(test_lines sprintf(nil "import checker_pkg::*"))
            test_lines = append1(test_lines sprintf(nil "`include \"./block_verification/%s/tasks/block_specific_include.sv\"", strcat("TB_" get(tbSelectionForm 'cellName)->value)))
        )
        ; traverse variables
        if(length(car(reg_test_info_list)) >= 1 then
            test_lines = append1(test_lines sprintf(nil "integer %s;", buildString(car(reg_test_info_list), ",")))
        )
        ; delays of traverse
        test_lines = append(test_lines cadr(reg_test_info_list))
        test_lines = append1(test_lines sprintf(nil "initial begin"))
        test_lines = append1(test_lines sprintf(nil "    //start the simulation after 100us"))
        test_lines = append1(test_lines sprintf(nil "    #100_000;"))
        test_lines = append1(test_lines sprintf(nil "    testName = %L;", test_file_name))
        test_lines = append1(test_lines sprintf(nil "    startTest;"))
        test_lines = append1(test_lines sprintf(nil "    `stim.setInitialValue();"))
        test_lines = append1(test_lines sprintf(nil "    `stim.initialize;"))
        test_lines = append1(test_lines sprintf(nil "    #100_000;"))
        test_lines = append(test_lines caddr(reg_test_info_list))
        ;test_lines = append1(test_lines sprintf(nil "    fork"))
        ;test_lines = append1(test_lines sprintf(nil "    join"))
        test_lines = append1(test_lines sprintf(nil "    #100_000;"))
        test_lines = append1(test_lines sprintf(nil "    finishTest;"))
        test_lines = append1(test_lines sprintf(nil "    #10_000;"))
        test_lines = append1(test_lines sprintf(nil "    $finish;"))
        test_lines = append1(test_lines sprintf(nil "end"))
        test_lines = append1(test_lines sprintf(nil "endmodule //%s", test_module_name))
        test_lines
    )
)

procedure(get_test_file_path_noext()
    let((tb_block_dir test_file_name test_file_path)
        tb_block_dir = get_tb_block_dir()
        test_file_name = get_test_file_name()
        ;printf("test_file_name: %s\n", test_file_name)
        if(!test_file_name then
            test_file_name = "Test_temp"
        )
        test_file_path = strcat(tb_block_dir "/tests/" test_file_name)
        ;else
            ;test_file_path = nil
        ;)
        test_file_path
    )
)

procedure(get_test_file_paths()
    let((test_file_name file_ext test_file_list test_file)
        test_file_name = get_test_file_name()
        test_file_list = list()
        if(test_file_name then
            foreach(file_ext get_test_ext()
                test_file = strcat(get_test_file_path_noext() "." file_ext)
                test_file_list = append1(test_file_list test_file)
            )
        else
            test_file = nil
        )
        test_file_list
    )
)

procedure(get_block_specific_include_sv()
    let((tb_block_dir block_specific_include)
        tb_block_dir = get_tb_block_dir()
        block_specific_include = strcat(tb_block_dir "/tasks/block_specific_include.sv")
        unless(isFile(block_specific_include)
            writeToFile("//Empty block_specific_include \n", block_specific_include)
        )
        block_specific_include
    )
) ;end of procedure get_block_specific_include_sv

procedure(get_block_define_file()
    let((tb_block_dir block_specific_include)
        tb_block_dir = get_tb_block_dir()
        block_specific_include = strcat(tb_block_dir "/defines/tb_defines.vams")
        unless(isFile(block_specific_include)
            writeToFile("//Empty tb_defines \n", block_specific_include)
        )
        block_specific_include
    )
) ;end of procedure get_block_define_file

procedure(get_block_specific_include()
    let((tb_block_dir block_specific_include)
        tb_block_dir = get_tb_block_dir()
        block_specific_include = strcat(tb_block_dir "/tasks/block_specific_include.vams")
        unless(isFile(block_specific_include)
            writeToFile("//Empty block_specific_include \n", block_specific_include)
        )
        block_specific_include
    )
) ;end of procedure get_block_specific_include

procedure(get_sv_files()
    let((func_dir_i2c sv_files out_files)
        func_dir_i2c = buildString(list(getShellEnvVar("ISIL_PROJ_HOME"), "functional_verification", "i2c"), "/")
        sv_files = list("type_i2c", "type_i2c_project", "checker_pkg")
        out_files = list()
        foreach(sv_file sv_files
            full_sv_file = strcat(func_dir_i2c "/" sv_file ".sv")
            if(isFile(full_sv_file) then
                out_files = append1(out_files full_sv_file)
            )
        )
        out_files
    )
) ;end of procedure get_block_tasks_file

procedure(get_common_block_tasks_file()
    let((func_dir_items common_block_tasks_file)
        func_dir_items = list(getShellEnvVar("ISIL_PROJ_HOME"), "functional_verification", "tasks", "common_block_tasks.vams")
        common_block_tasks_file = buildString(func_dir_items, "/")
        ;printf("3410 common block task file %s\n", common_block_tasks_file)
        unless(isFile(common_block_tasks_file)
            writeToFile("//Empty common_block_tasks \n", common_block_tasks_file)
        )
        common_block_tasks_file
    )
) ;end of procedure get_common_block_tasks_file

procedure(get_test_file_name()
    let((test_file_name)
        test_file_name = get(tbSelectionForm 'testName)->value
        if(uc(test_file_name) == "TEST_" || test_file_name == "" then
            test_file_name = nil
        else
            if(not(rexMatchp("^TEST_" uc(test_file_name))) then
                test_file_name = strcat("Test_" test_file_name)
            )
        )
        test_file_name
    )
)

procedure(get_test_module_name()
    let((origCellName test_module_name)
        origCellName = get(tbSelectionForm 'cellName)->value
        test_module_name = strcat("TEST_" origCellName)
    )
)

procedure(get_tb_block_dir()
    let((origCellName tbCellName tb_block_dir_items tb_block_dir)
        origCellName = get(tbSelectionForm 'cellName)->value
        tbCellName = strcat("TB_" origCellName)
        tb_block_dir_items = list(getShellEnvVar("ISIL_PROJ_HOME"), "block_verification", tbCellName)
        tb_block_dir = buildString(tb_block_dir_items, "/")
    )
)

procedure(remove_test_file()
    let((test_file_list test_file)
        test_file_list = get_test_file_paths()
        foreach(test_file test_file_list
            if(test_file && isFile(test_file) then
                system(strcat("/bin/rm " test_file))
            )
        )
    )
)

procedure(get_vams_path()
    let((instLibName instCellName  instViewName obj viewExt view_path)
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        obj = ddGetObj(instLibName instCellName instViewName)
        viewExt = getViewExt(instViewName)
        if(obj then
            view_path = strcat(obj~>readPath  strcat("/verilog." viewExt))
        else
            printf("%s-%s-%s is not found.\n", instLibName, instCellName, instViewName)
            view_path = ""
        )
    )
)

procedure(get_test_ext()
    let((all_exts test_ext_field_value)
        test_ext_field_value = get(tbSelectionForm 'test_ext)->value
        if(rexMatchp(",", test_ext_field_value) then
            all_exts = remove_tr_fol_spaces_list(parseString(test_ext_field_value ","))
        else
            all_exts = parseString(test_ext_field_value)
        )
        unless(all_exts all_exts = list("vams"))
        all_exts
    )
) ;end of procedure get_test_ext

procedure(view_test_file()
    let((test_ext gvim_files test_file_path test_file)
        test_file_path = get_test_file_path_noext()
        gvim_files = list()
        foreach(test_ext get_test_ext()
            test_file = strcat(test_file_path "." test_ext)
            if(test_file then
                unless(isFile(test_file)
                    gen_test_file()
                )
                if(isFile(test_file) then
                    gvim_files = append1(gvim_files test_file)
                )
                if(test_ext == "sv" then
                    gvim_files = append(gvim_files get_sv_files())
                    gvim_files = append1(gvim_files get_block_specific_include_sv())
                )
                if(test_ext == "vams" then
                    gvim_files = append(gvim_files list(get_common_block_tasks_file() get_block_specific_include()))
                    printf("3492 test file is %s.\n", test_file)
                )
            )
        )
        if(length(gvim_files) >= 1 then
            gvim_files = append1(gvim_files get_vams_path())
            gvim_files = append1(gvim_files get_block_define_file())
            printf("3436 test file is %s.\n", buildString(gvim_files " "))
            system(strcat("gvim " buildString(gvim_files " ")))
            printf("3440 test file is %s.\n", buildString(gvim_files " "))
        else
            printf("3139 not a valid test file to look at.")
        )
    )
)

procedure(create_update_config(lib_name cell_name config_name top_view_name @optional (override nil)(in_lib_list list()))
    let((obj1 hier_cv lib_list view_list obj_path config_expand_file config_expand_hash)
        if(in_lib_list lib_list = in_lib_list lib_list = list(lib_name))
        obj1 = ddGetObj(lib_name cell_name config_name)
        if(obj1 && not(override) then
            ;obj1 = ddGetObj(lib_name cell_name config_name)
            ;printf("3216 path(%L)\n", obj1->readPath)
            ;printf("3215 ddGetObj(%L %L %L)\n", lib_name, cell_name, config_name)
            obj_path = obj1~>readPath
            hier_cv = hdbOpen(lib_name cell_name config_name "a")
            config_expand_file = strcat(obj_path "/expand.cfg")
            printf("3217 config expand file %s.\n" config_expand_file)
            config_expand_hash = extract_expand_file(config_expand_file)
            if(member("liblist" config_expand_hash) then
                lib_list = append(lib_list config_expand_hash["liblist"])
            )
        else
            hier_cv = hdbOpen(lib_name cell_name config_name "w")
        )
        hdbSetTopCellViewName(hier_cv lib_name cell_name top_view_name)
        hdbSetDefaultLibListString(hier_cv buildString(uniqueList(lib_list) " "))
        view_list = "schematic spectre schematic_sim verilogams functional veriloga verilog vhdl behavioral"
        if(rexMatchp("FS" config_name) then
            view_list = "schematic spectre schematic_sim verilogams functional veriloga verilog vhdl behavioral"
        else
            if(rexMatchp("FM" config_name) then
                view_list = "verilogams functional veriloga verilog vhdl behavioral spectre schematic schematic_sim"
            )
        )
        hdbSetDefaultViewListString(hier_cv view_list)
        hdbSetDefaultStopListString(hier_cv "spectre symbol")

        ;spec = list(list(dut_lib_name dut_cell_name nil nil));  //specify cell for binding
        ;host_view = dut_view_name
        ;rule = list('hdbcBindingRule list(nil nil host_view));  //specify view for binding
        ;hdbSetObjBindRule(hier_cv spec rule);  //Executing the bind rule
        hdbSave(hier_cv)
        hdbClose(hier_cv)
        re_gen_config_prop_cfg(lib_name cell_name config_name)
    )
)

procedure(re_gen_config_prop_cfg(lib_name cell_name config_name)
    let((obj1 obj_path config_prop_file)
        if(obj1 = ddGetObj(lib_name cell_name config_name) then
            obj_path = obj1~>readPath
            config_prop_file = strcat(obj_path "/prop.cfg")
            re_gen_prop_cfg(config_prop_file)
        )
    )
)
procedure(extract_config_list_set(lib_name cell_name config_name)
    let(()
        if(obj1 = ddGetObj(lib_name cell_name config_name) then
            obj_path = obj1~>readPath
            config_expand_file = strcat(obj_path "/expand.cfg")
            extract_expand_file(config_expand_file)
            config_prop_file = strcat(obj_path "/prop.cfg")
        )
    )
)


procedure(extract_prop_file(in_file)
    let((prop_hash in_h line all_lines all_line_items line_items item0 item1 item_index)
        prop_hash = makeTable("")
        if(isFile(in_file) then
            in_h = infile(in_file)
            all_lines = ""
            while(gets(line in_h)
                line = remove_trailing_following_spaces(line)
                rexCompile("\n")
                line = rexReplace(line, "", 0)
                rexCompile("//.*")
                line = rexReplace(line, "", 0)
                all_lines = strcat(all_lines line)
            )
            close(in_h)
            all_line_items = parseString(all_lines "{}")
            item_index = 0
            foreach(item all_line_items
                item_index += 1
                line_items = parseString(item)
                item0 = car(line_items)
                if(item0 && item0 == "cell" then
                    item1 = cadr(line_items)
                    if(item1 then
                        if(member(item1 prop_hash) then
                            prop_hash[item1] = append1(prop_hash[item1], nthelem(item_index + 1, all_line_items))
                        else
                            prop_hash[item1] = list(nthelem(item_index + 1, all_line_items))
                        )
                    )
                )
            )
        )
        prop_hash
    )
)

procedure(gen_analog_models_array()
    let((models_dir all_modules_names module_files file file_path module_names)
        models_dir = strcat(getShellEnvVar("ISIL_PROJ_HOME") "/functional_verification/models")
        all_modules_names = list()
        if(isDir(models_dir) then
            module_files = getDirFiles(models_dir)
            foreach(file module_files
                if(rexMatchp("vams$" file) then
                    file_path = strcat(models_dir "/" file)
                    module_names = extract_module_names(file_path)
                    all_modules_names = append(all_modules_names module_names)
                )
            )
        )
        all_modules_names = uniqueList(all_modules_names)
    )
)

procedure(extract_module_names(in_file)
    let((file_pin_module_info all_module_names)
        file_pin_module_info = gen_pin_info_hash_from_file(in_file)
        ;printf("3310 processing %L %d.\n", in_file, length(file_pin_module_info))
        all_module_names = nthelem(4 file_pin_module_info)
        ;printf("3313 %s.\n", buildString(all_module_names " "))
        all_module_names
    )
)

procedure(re_gen_prop_cfg(in_file)
    let((prop_array set_external prop_hash ams_module_names ams_module cell prop)
        prop_array = list("file-format-id 1.1;" "default" "{" "}")
        set_external = "non-inherited string prop externalTextAMSOSS = \"digital\";"
        if(isFile(in_file) then
            prop_hash = extract_prop_file(in_file)
        else
            prop_hash = makeTable("prop table")
        )
        ams_module_names = gen_analog_models_array()
        ams_module_names = append1(ams_module_names get_test_module_name())
        foreach(ams_module ams_module_names
            if(member(ams_module prop_hash) && not(member(set_external prop_hash[ams_module])) then
                prop_hash[ams_module] = append1(prop_hash[ams_module] set_external)
            else
                if(not(member(ams_module prop_hash)) then
                    prop_hash[ams_module] = list(set_external)
                )
            )
        )
        foreach(cell sort(prop_hash->? 'alphalessp)
            prop_array = append1(prop_array strcat("cell " cell))
            prop_array = append1(prop_array "{")
            foreach(prop prop_hash[cell]
                prop_array = append1(prop_array strcat("    " prop))
            )
            prop_array = append1(prop_array "}")
        )
        writeToFile(buildString(prop_array "\n"), in_file)
    )
)

procedure(extract_expand_file(in_file)
    let((expand_hash in_h line line_items item0)
        expand_hash = makeTable("")
        if(isFile(in_file) then
            in_h = infile(in_file)
            while(gets(line in_h)
                line = remove_trailing_following_spaces(line)
                rexCompile("\n")
                line = rexReplace(line, "", 0)
                rexCompile("//.*")
                line = rexReplace(line, "", 0)
                line_items = parseString(line "\t, ;")
                item0 = car(line_items)
                if(item0 && rexMatchp("list" item0) && cdr(line_items) then
                    if(member(item0 expand_hash) then
                        expand_hash[item0] = append(expand_hash[item0] cdr(line_items))
                    else
                        expand_hash[item0] = cdr(line_items)
                    )
                )
            )
            foreach(item0 expand_hash->?
                expand_hash[item0] = uniqueList(expand_hash[item0])
            )
            close(in_h)
        )
        expand_hash
    )
)

procedure(gen_probe_file()
    let(()
    )
)

procedure(gen_simvision_file()
    let(()
    )
)

procedure(gen_define_file()
    let(()
    )
)


procedure(get_all_nets(@optional (cv dgcv()))
    let((nets_list net_name net_name_list net_name1 name_no_lt )
        nets_list = list()
        foreach(net_name cv~>nets~>name
            if(rexMatchp(",", net_name) then
                net_name_list = parseString(net_name, ",")
            else
                net_name_list = list(net_name)
            )
            foreach(net_name1 net_name_list
                rexCompile("<.*>")
                name_no_lt = rexReplace(net_name1, "", 0)
                unless(member(name_no_lt nets_list)
                    nets_list = append1(nets_list name_no_lt)
                )
            )
        )
        nets_list
    )
)

procedure(os_copyfile(orig_file new_file @optional (overwrite t))
    let(()
        if(isFile(orig_file) && (overwrite || not(isFile(new_file)))
            system(buildString(list("/bin/cp" "-L" orig_file new_file) " "))
            system(buildString(list("chmod" "755" new_file) " "))
        )
    )
)

procedure(os_makedir(in_dir)
    let(()
        unless(isDir(in_dir)
            system(strcat("mkdir " in_dir))
        )
    )
)

procedure(openTestBench()
    let((origViewName tgtLibName tgtCellName tgtViewName tbLibName tbCellName tbViewName symbolView symbolOpenView origSymView tgtSymView tbObj)
        saveLast()
        origLibName = get(tbSelectionForm 'libName)->value
        origCellName = get(tbSelectionForm 'cellName)->value
        origViewName = get(tbSelectionForm 'viewName)->value
        tgtLibName = get(tbSelectionForm 'tgtLibName)->value
        tgtCellName = get(tbSelectionForm 'tgtCellName)->value
        tgtViewName = get(tbSelectionForm 'tgtViewName)->value
        if(tgtCellName == origCellName displayErrBox("You should have a cell and stim to create tb\n"))
        if(tgtLibName == origLibName && not(rexMatchp(getShellEnvVar("USER") origLibName)) displayErrBox("You should have a different design and sim library\n"))
        unless(rexMatchp(strcat(getShellEnvVar("USER") "$") tgtLibName) displayErrBox("You test bench should be in your own directory"))
        tbLibName = get(tbSelectionForm 'tgtLibName)->value
        tbCellName = strcat("TB_" origCellName)
        tbViewName = "schematic"
        tbObj = ddGetObj(tbLibName tbCellName tbViewName)
        if(tbObj then
            deOpenCellView(tbLibName tbCellName tbViewName tbViewName nil "r")
        )
    )
)

procedure(getTotalRange(inRange)
    let((imax imin ranges range start end iarray inum oRange)
        imax = 0
        imin = 10000
        oRange = inRange
        if(rexMatchp(" " inRange) then
            ranges = parseString(inRange)
            foreach(range ranges
                rexCompile("\\[\\(.*\\):\\(.*\\)\\]")
                if(rexExecute(range) then
                    start = evalstring(rexSubstitute("\\1"))
                    end = evalstring(rexSubstitute("\\2"))
                    iarray = list(start end)
                    foreach(inum iarray
                        if(inum > imax imax = inum)
                        if(inum < imin imin = inum)
                    )
                )
            )
            oRange = sprintf(nil "[%0d:%0d]",imax, imin)
        )
        oRange
    )
)

procedure(getRangesList(inRanges)
    let((rangeTable ranges range cRangeTable kk ret)
        rangeTable = makeTable("table list")
        rexCompile("\\[")
        inRanges = rexReplace(inRanges " [" 0)
        rexCompile("\\[\\(.*\\):\\(.*\\)\\]")
        if(rexExecute(inRanges) then
            if(rexMatchp(" " inRanges) then
                ranges = parseString(inRanges)
                foreach(range ranges
                    cRangeTable = getRangeTable(range)
                    foreach(kk cRangeTable->?
                        rangeTable[kk] = 1
                    )
                )
            else
                rangeTable = getRangeTable(inRanges)
            )
        )
        ret = list()
        foreach(kk sort(rangeTable->? 'lessp)
            ret = append1(ret sprintf(nil "%d", kk))
        )
        ret
    )
)

procedure(getRangeTable(inRange)
    let((range rangeTable start end iend ii)
        range = inRange
        rangeTable = makeTable("table list")
        rexCompile("\\[\\(.*\\):\\(.*\\)\\]")
        if(rexExecute(range) then
            start = evalstring(rexSubstitute("\\1"))
            end = evalstring(rexSubstitute("\\2"))
            if(start > end then
                iend = end
                end = start
                start = iend
            )
            for(ii start end
                rangeTable[ii] = 1
            )
        )
        rangeTable
    )
)

procedure(clearFields()
    let((instCellName instLibName instViewName saveFile key)
        saveLast()
            foreach(key '(tgtLibName tgtCellName tgtViewName needSensitivity overridetb override tgtinputPins tgtoutputPins
                    tgtinoutPins vdd vss testName electrical vsource isource_vdd isource_vss genSymbol corr digRegs
                    traditional top i2c group )
                if(stringp(get(tbSelectionForm key)->value) get(tbSelectionForm key)->value = "" get(tbSelectionForm key)->value = nil)
            )
            get(tbSelectionForm 'tgtCellName)->value = get(tbSelectionForm 'cellName)->value
            get(tbSelectionForm 'tgtLibName)->value = get(tbSelectionForm 'libName)->value
            get(tbSelectionForm 'tgtViewName)->value = "verilogams"
            copyAllPins()
    )
)

procedure(save_current_field_value(key)
    let(()
        hash_previous_value[key] = get(tbSelectionForm key)->value
        ;printf("current key value: %s\n", previous_key_value)
    )
)

;list1 for sync addition, list2 for execlusive removal, list3 for sync removal
procedure(sync_addition_execlusive_removal(key1 list_keys1 list_keys2 @optional (list_keys3 list()))
    let((orig_pins_list previous_pins_list compare_info removal_list additional_list )
        remove_duplicates(key1)
        printf("previous key value 251 : %s\n", hash_previous_value[symbolToString(key1)])
        previous_pins_list = parseString(hash_previous_value[symbolToString(key1)])
        orig_pins_list = parseString(get(tbSelectionForm key1)->value)
        compare_info = compare_list(previous_pins_list orig_pins_list)
        removal_list = car(compare_info)
        additional_list = cadr(compare_info)

        if(length(additional_list) >= 1 then
            printf("to be added 200: %s\n", car(additional_list))
            sync_addition(additional_list list_keys1)
            execlusive_removal(additional_list list_keys2)
        )

        if(length(removal_list) >= 1 then
            printf("to be removed 199: %s\n", car(removal_list))
            sync_removal(removal_list list_keys3)
        )

    )
)

procedure(sync_addition(additional_list list_keys)
    let((orig_pins_list key orig_key_pin_list new_key_pin_list pin )
        foreach(key list_keys
            remove_duplicates(key)
            orig_key_pin_list = parseString(get(tbSelectionForm key)->value)
            new_key_pin_list = orig_key_pin_list
            foreach(pin additional_list
                unless(member(pin orig_key_pin_list)
                    new_key_pin_list = append1(new_key_pin_list pin)
                )
            )
            get(tbSelectionForm key)->value = buildString(new_key_pin_list " ")
        )
    )
)

procedure(execlusive_removal(removal_list list_keys)
    let((key orig_key_pin_list new_key_pin_list pin )
        foreach(key list_keys
            remove_duplicates(key)
            orig_key_pin_list = parseString(get(tbSelectionForm key)->value)
            new_key_pin_list = list()
            foreach(pin orig_key_pin_list
                unless(member(pin removal_list)
                    new_key_pin_list = append1(new_key_pin_list pin)
                )
            )
            get(tbSelectionForm key)->value = buildString(new_key_pin_list " ")
        )
    )
)

procedure(sync_removal(removal_list list_keys)
    let((key orig_key_pin_list new_key_pin_list pin)
        foreach(key list_keys
            remove_duplicates(key)
            orig_key_pin_list = parseString(get(tbSelectionForm key)->value)
            new_key_pin_list = list()
            foreach(pin orig_key_pin_list
                unless(member(pin removal_list)
                    new_key_pin_list = append1(new_key_pin_list pin)
                )
            )
            get(tbSelectionForm key)->value = buildString(new_key_pin_list " ")
        )
    )
)


;find the items removed from list1 and additionals in list2
procedure(compare_list(list1 list2)
    let((removal_list additional_list item)
        removal_list = list()
        additional_list = list()
        foreach(item list1
            unless(member(item list2)
                if(not(member(item removal_list)) then
                    removal_list = append1(removal_list item)
                )
            )
        )
        foreach(item list2
            unless(member(item list1)
                if(not(member(item additional_list)) then
                    additional_list = append1(additional_list item)
                )
            )
        )
        list(removal_list additional_list)
    )
)

procedure(removeVAMSFile()
    let((instCellName instLibName instViewName vamsFile tempExts tempExt vamsFileSwp )
        instCellName = get(tbSelectionForm 'tgtCellName)->value
        instLibName = get(tbSelectionForm 'tgtLibName)->value
        instViewName = get(tbSelectionForm 'tgtViewName)->value
        vamsFile = sprintf(nil "%s_%s_%s.vams" instLibName, instCellName, instViewName)
        if(isFile(vamsFile) shell(strcat("rm " vamsFile)) printf("%s is not a file, please generate vams file first\n" vamsFile))
        tempExts = list(".swp" ".swo")
        foreach(tempExt tempExts
            vamsFileSwp = strcat("." vamsFile tempExt)
            if(isFile(vamsFileSwp) shell(strcat("rm " vamsFileSwp)))
        )
    )
)
/***************************************************************
*                                                              *
*                      oferSyncBrowser()                       *
*                                                              *
*                 Synchronise with the browser                 *
*                                                              *
***************************************************************/

procedure(oferSyncBrowser()
    ddsSyncWithForm(
        tbSelectionForm
        'browse
        'libName
        'cellName
        'viewName
        )
    )


procedure(tgtoferSyncBrowser()
    ddsSyncWithForm(
        tbSelectionForm
        'tgtbrowse
        'tgtLibName
        'tgtCellName
        )
    )
/****************************************************************
*                                                               *
*                    oferExampleFormCB(form)                    *
*                                                               *
* The form callback - doesn't do much except print out what has *
*                         been entered                          *
*                                                               *
****************************************************************/

procedure(oferExampleFormCB(form)
    hiRegTimer("tbSelectionForm = 'unbound" 10)
    printf("You entered cellView %s/%s/%s\n"
        form->libName->value
        form->cellName->value
        form->viewName->value
        )
    saveLast()
    ;saveSettings()
    )

procedure(saveLast()
    let((oport saveFile key keyValue keyValueList )
            unless(get(tbSelectionForm 'tgtCellName)->value == "" saveSettings(t))
            saveFile = ".tbLast"
            oport = outfile(saveFile)
            fprintf(oport "tbKeys='(nil\n")
            foreach(key '(cellName libName viewName tgtCellName tgtLibName tgtViewName inputPins outputPins inoutPins
            needSensitivity traditional top i2c group tgtinputPins tgtoutputPins tgtinoutPins overridetb override vdd vss testName genSymbol
            electrical vsource isource_vdd isource_vss corr digRegs)
                keyValue =  get(tbSelectionForm key)->value
                if(stringp(keyValue) then
                    keyValueList = parseString(keyValue)
                    keyValue = buildString(sort(keyValueList 'alphalessp) " ")
                )
                fprintf(oport " %s %L\n" key keyValue)
            )
            fprintf(oport ")\n")
            close(oport)
            ;printf("saved settings to %s.\n" saveFile)
        )
)

procedure(numSpace(inNum)
    let((spaces)
        spaces = ""
        if(inNum >= 1 then
            for(i 1 inNum spaces = strcat(spaces " "))
        )
        spaces
    )
)

procedure(loadLast()
    let((saveFile key loadFileList )
        saveFile = ".tbLast"
        if(isFile(saveFile) then
            load(saveFile)
            foreach(key '(cellName libName viewName tgtCellName tgtLibName tgtViewName inputPins outputPins inoutPins
            needSensitivity traditional top i2c group tgtinputPins tgtoutputPins tgtinoutPins overridetb override vdd vss testName genSymbol
            electrical vsource isource_vdd isource_vss corr digRegs)
                when(get(tbKeys key) get(tbSelectionForm key)->value = get(tbKeys key))
            )
        else 
            displayErrBox(sprintf(nil "You donot have a valid last save file(%s).\n", saveFile))
        )
    )
)

procedure(delete_all_delete_view(in_lib @optional (view_name "verilogams_delete"))
    let((lib_obj cell view)
        if(lib_obj = ddGetObj(in_lib) then
            foreach(cell lib_obj~>cells
                foreach(view cell~>views
                    if(view~>name == view_name then
                        printf("deleting %s-%s-%s\n", in_lib, cell~>name, view~>name)
                        ddDeleteObj(view)
                    )
                )
            )
        else
            printf("Invalid library specified %s.", in_lib)
        )
    )
)

;procedure(create_temp_verilogams_view_from_symbol(in_lib in_cell)
procedure(get_pin_order_info_from_symbol(in_lib in_cell)
    let((sym_view tempi vams_view_orig sym_obj vams_view vams_obj vams_file_dir vams_file module_info_array viewExt line)
        sym_view = "symbol"
        tempi = 1
        vams_view_orig = "verilogams_delete"
        module_info_array = list()
        if(sym_obj = ddGetObj(in_lib in_cell sym_view) then
            vams_view = sprintf(nil "%s%d", vams_view_orig, tempi)
            while(vams_obj = ddGetObj(in_lib in_cell vams_view)
                tempi += 1
                vams_view = sprintf(nil "%s%d", vams_view_orig, tempi)
            )
            printf("Creating %s-%s-%s\n", in_lib, in_cell, vams_view)
            schViewToView(in_lib in_cell in_lib in_cell sym_view vams_view "schSymbolToPinList" " _vmsPinListToVms")
            ahdlUpdateViewInfo(in_lib ?cell in_cell)
            if(vams_obj = ddGetObj(in_lib in_cell vams_view) then
                viewExt = getViewExt(vams_view)
                vams_file_dir = vams_obj~>readPath
                vams_file = strcat(vams_file_dir strcat("/verilog." viewExt))
                module_info_array = extract_module_pin_info(vams_file)
                printf("deleting %s-%s-%s\n", in_lib, in_cell, vams_view)
                ddDeleteObj(vams_obj)
            )
        else
            printf("%s-%s-%s doesnot exist. Please select a different cell to create veriogams view", in_lib, in_cell, sym_view)
        )
        module_info_array
    )
)

procedure(extract_module_pin_info(vams_file)
    let((in_h module_lines module_start line module_info_line all_pin_line module_name all_pin_array)
        all_pin_array = list()
        module_lines = ""
        module_start = 0
        module_info_line = ""
        module_name = ""
        if(isFile(vams_file) then
            in_h = infile(vams_file)
            while(gets(line in_h)
                ;printf("%s", line)
                rexCompile("//.*")
                line = rexReplace(line " " 0)
                if(rexMatchp(strcat("module.*(") line) then
                    module_start = 1
                )
                if(module_start == 1 then
                    module_lines = strcat(module_lines line)
                    if(rexMatchp(")" line) then
                        module_start = 0
                    )
                )
            )
            rexCompile("\n")
            module_info_line = rexReplace(module_lines " " 0)
            rexCompile("module *\\(.*\\) *(\\(.*\\))")
            if(rexExecute(module_info_line) then
                module_name = rexSubstitute("\\1")
                all_pin_line = rexSubstitute("\\2")
                all_pin_array = parseString(all_pin_line, ", ")
            else
                printf("No pin information is found")
            )
            close(in_h)
        else
            printf("%s isnot a valid file.\n", vams_file)
        )
        list(all_pin_array module_info_line module_name)
    )
)

procedure(lc(name)
	lowerCase(name)
)
procedure(uc(name)
	upperCase(name)
)


/***************************************************************
*                                                              *
*                        oferExample()                         *
*                                                              *
*                       Main entry point                       *
*                                                              *
***************************************************************/

procedure(displayForm()
    unless(boundp('tbSelectionForm)
        tbCreateForm()
        ;unless(css() loadLast())
    )
    hiDisplayForm(tbSelectionForm)
)
