
top_pins = list("CSINF", "COMPR", "ASGATE", "COMPF", "LGATE2", "VBAT", "VSSA", "PSYS", "VDDA", "PHASE2", "VSSD", "SCL_B", "CC1", "UGATE2", "PROCHOT#", "BGATE", "VDDA1P5", "MCU_LDO", "BOOT2", "SCL_C", "CSIP", "CSINS", "SDA_C", "DCIN", "PROG", "VDDP", "BOOT1", "UGATE1", "PHASE1", "OTGPG", "LGATE1", "VSSP", "CC2", "OTGEN", "VDDD", "SUB", "ACLIM", "VCONN_POWER", "AMON", "ASRC", "VBUS", "BATGONE", "CSOPF", "CSON", "CSOPS", "ALERT_C", "SDA_B", "VDDD1P5")
top_pins = list("CSINF", "COMPR", "ASGATE", "COMPF", "LGATE2", "VBAT", "PSYS", "PHASE2", "SCL_B", "CC1", "UGATE2", "PROCHOT#", "BGATE", "VDDA1P5", "MCU_LDO", "BOOT2", "SCL_C", "CSIP", "CSINS", "SDA_C", "DCIN", "PROG", "VDDP", "BOOT1", "UGATE1", "PHASE1", "OTGPG", "LGATE1", "VSSP", "CC2", "OTGEN", "ACLIM", "VCONN_POWER", "AMON", "ASRC", "VBUS", "BATGONE", "CSOPF", "CSON", "CSOPS", "ALERT_C", "SDA_B", "VDDD1P5")

proj_ver = "_9250_r1p0"
hash_pin_info = makeTable("pin info table")
PIN_LIST = list()
;procedure(
    ;let(()
    ;)
;)

procedure(copy_update_all_cells_on_cv(@optional (cv dgcv()))
    let((inst lib_name cell_name new_lib new_cell new_cell_symbol_inst)
        foreach(inst cv~>instances
            lib_name = inst~>libName
            cell_name = inst~>cellName
            if(lib_name == "isl9241_r1p2" then
                new_lib = "isl9250a_xzhang02"
                new_cell = new_cell_name(cell_name)
                if(not(ddGetObj(new_lib new_cell "symbol")) then
                    copy_symbol_view(lib_name cell_name new_lib new_cell)
                    update_symbol_pins(new_lib new_cell)
                )
                new_cell_symbol_inst = dbOpenCellViewByType(new_lib new_cell "symbol" "schematicSymbol" "r")
                inst~>master = new_cell_symbol_inst
                update_inst_name(inst cv)
            )
        )
    )
)

;update the symbol from the vams file
procedure(update_vamsfile_from_symbol(lib_name cell_name @optional (sym_view "symbol")(vams_view "verilogams"))
    let((sym_obj vams_obj vams_file sym_ports_info vams_ports_info vams_hash_pin_dir_info vams_pin_list vams_hash_pin_info dig_ss_list update_pin_list port port_name is_new_file port_prop vams_obj_cv vams_header remove_info modify_info vams_ports_info_full vams_pin_list_full new_lines)
        sym_obj = dbOpenCellViewByType(lib_name cell_name sym_view "" "r")
        sym_ports_info = gen_pin_list_hash_from_view(sym_obj)
        ;global variables that store the symbol pin information
        hash_pin_info = car(sym_ports_info)
        PIN_LIST = cadr(sym_ports_info)
        vams_obj = ddGetObj(lib_name cell_name vams_view)
        if(vams_obj then
            vams_obj = dbOpenCellViewByType(lib_name cell_name vams_view "" "r")
            update_pin_list = list()
            vams_file = strcat(ddGetObj(lib_name cell_name vams_view)~>readPath "/verilog.vams")

            vams_ports_info = gen_pin_list_hash_from_view(vams_obj, 1)
            vams_hash_pin_dir_info = car(vams_ports_info)
            vams_pin_list = cadr(vams_ports_info)

            vams_ports_info_full = gen_pin_list_hash_from_view(vams_obj)
            vams_pin_list_full = cadr(vams_ports_info_full)

            ;pin information list hash (inout, type)
            vams_hash_pin_info = extract_pin_info_from_vams_view(lib_name cell_name vams_view)
            dig_ss_list = extract_ss_from_hash(vams_hash_pin_info)
            ;printf("i am here, 57\n")

            update_pin_list = gen_update_pin_list(vams_hash_pin_info)
            is_new_file = 0
        else
            vams_obj = ddGetObj(lib_name cell_name vams_view "verilog.vams" nil "w")
            vams_obj_cv = dbOpenCellViewByType(lib_name cell_name vams_view "netlist" "ac")
            check_save_cv(vams_obj_cv)
            vams_file = strcat(ddGetObj(lib_name cell_name vams_view)~>readPath "/verilog.vams")
            update_pin_list = unique_pins(PIN_LIST)
            dig_ss_list = list("" "vddd,vssd")
            vams_pin_list = unique_pins(PIN_LIST)
            is_new_file = 1
        )
        vams_header = vamsHeaderGeneral_opt(lib_name cell_name vams_view is_new_file)
        if(is_new_file == 0 then
            remove_info = gen_remove_pin_info(vams_pin_list)
            vams_header = strcat(vams_header remove_info)
            ;printf("%s\n", vams_header)
            modify_info = gen_modify_pin_info(vams_pin_list_full)
            vams_header = strcat(vams_header modify_info)
            if(length(update_pin_list) >= 1 then
                vams_header = strcat(vams_header "//Added additional pin" if(length(update_pin_list) > 1 "s" "") ": " buildString(update_pin_list, ", ") ".\n")
            )
            vams_header = strcat(vams_header "\n")
            printf("%s\n", vams_header)
        )
        if(length(update_pin_list) >= 1 then
            create_pin_def_fields(update_pin_list dig_ss_list)
        )
        printf("ready to regenerate new code.\n")
        new_lines = re_gen_vams_code(vams_file cell_name vams_pin_list is_new_file vams_header)
        printf("ready to write new code to vams file.\n")
        write_to_file_list(new_lines, vams_file)
    )
)

procedure(create_pin_def_fields(in_pin_list @optional (dig_refs list("" "vddd,vssd")))
    let((pin_fields x_loc y_loc x1_loc y1_loc pin_props all_dig_sel_fields all_pin_info pin pin_dig_sel pin_field dig_selection_field all_dig_sel_fields_par additional_dig_fields add_remove_fields gen_button pin_name pin_def_form )
        pin_fields = list()
        x_loc = 0
        y_loc = 0
        x1_loc = x_loc + 200
        y1_loc = y_loc
        ;pin domain properties
        pin_props = list("analog" "digital")
        all_dig_sel_fields = list()
        all_pin_info = "list("
        ;PIN_LIST = in_pin_list
        unique_pin_list = unique_pins(in_pin_list)
        ;printf("%s\n", buildString(unique_pin_list, " "))
        foreach(pin unique_pin_list
            ;printf("%s\n", pin)
            pin_dig_sel = strcat(pin "_dig_sel")
            pin_name = pin
            pin_field = hiCreateCyclicField(
                ?name stringToSymbol(pin)
                ?prompt pin_name
                ?value "analog"
                ?choices pin_props
                ;?valueByPosition t
                ;?CBOnReselect t
                ;?multipleSelect nil
                ?callback sprintf(nil "update_dig_ref_fields(pin_def_form->%s pin_def_form->%s)", pin, pin_dig_sel)
            )
            ;pin_fields = append1(pin_fields list(pin_field x_loc:y_loc 100:10 100))
            pin_fields = append1(pin_fields list(pin_field x_loc:y_loc 50:10 80))
            ;pin_fields = append1(pin_fields pin_field)
            dig_selection_field = hiCreateCyclicField(
                ?name stringToSymbol(pin_dig_sel)
                ?choices dig_refs
                ?value ""
                ?prompt strcat(pin_name "_ss")
                ;?valueByPosition t
                ;?CBOnReselect t
                ;?multipleSelect nil
                ?callback sprintf(nil "update_pin_pro(pin_def_form->%s pin_def_form->%s)", pin, pin_dig_sel)
            )
            all_pin_info = sprintf(nil "%slist(%L pin_def_form->%s pin_def_form->%s) " all_pin_info, pin, pin, pin_dig_sel)
            all_dig_sel_fields = append1(all_dig_sel_fields sprintf(nil "pin_def_form->%s" pin_dig_sel))
            ;pin_fields = append1(pin_fields list(dig_selection_field x1_loc:y1_loc 200:10 200))
            pin_fields = append1(pin_fields list(dig_selection_field x1_loc:y1_loc 50:10 100))
            x_loc = x_loc
            y_loc = y_loc + 30
            x1_loc = x_loc + 200
            y1_loc = y_loc

        )
        all_pin_info = sprintf(nil "%s)" all_pin_info)
        all_dig_sel_fields_par = strcat("list(" buildString(all_dig_sel_fields " ") ")")
        additional_dig_fields = hiCreateStringField(
                ?name 'additional_dig_fields
                ?prompt "Dig SS Fields: "
                ?callback "format_field(pin_def_form->additional_dig_fields)"
                ?defValue ""
        )
        pin_fields = append1(pin_fields list(additional_dig_fields x_loc:y_loc 300:30 80))
        add_remove_fields = hiCreateButton(
                ?name 'add_remove_fields
                ?buttonText "add/remove"
                ?callback sprintf(nil "add_remove_fields(pin_def_form->additional_dig_fields %s)" all_dig_sel_fields_par)
        )
        x_loc = x_loc + 300
        pin_fields = append1(pin_fields list(add_remove_fields x_loc:y_loc 100:30 100))
        gen_button = hiCreateButton(
                ?name 'gen_button
                ?buttonText "generate code"
                ?callback sprintf(nil "update_hash(%s)" all_pin_info)
        )
        x_loc = x_loc - 300
        y_loc = y_loc + 30
        pin_fields = append1(pin_fields list(gen_button x_loc:y_loc 100:30 100))
        pin_def_form = hiCreateAppForm(
            ?name 'pin_def_form
            ?formTitle "Pin Definition Selection Form"
            ?callback sprintf(nil "update_hash(%s)" all_pin_info)
            ?fields pin_fields
            ?unmapAfterCB t
            )
        hiDisplayForm(pin_def_form)
    )
)

;pin range modified info
procedure(gen_modify_pin_info(vams_pin_list_full)
    let((vams_pin_range_table sym_pin_range_table modify_pin_list port sym_port_range vams_port_range modify_info )
        ;printf("%s\n", buildString(vams_pin_list_full, " "))
        vams_pin_range_table = extract_pin_list(vams_pin_list_full)
        sym_pin_range_table = extract_pin_list(PIN_LIST)
        modify_pin_list = list()
        modify_info1 = "Modified the following pin"
        modify_info = ""
        foreach(port vams_pin_range_table->?
            if(member(port sym_pin_range_table->?) then
                sym_port_range = sym_pin_range_table[port]
                vams_port_range = vams_pin_range_table[port]
                if(sym_port_range != vams_port_range then
                    modify_pin_list = append1(modify_pin_list, port)
                    modify_info = sprintf(nil "%s%s from %s to %s, ", modify_info, port, vams_port_range, sym_port_range)
                )
            )
        )
        rexCompile(", $")
        modify_info = rexReplace(modify_info "" 0)
        modify_info = if(modify_info == "" "" strcat("//" modify_info1 if(length(modify_pin_list) > 1 "s" "") ": " modify_info ".\n"))
    )
)


;generate the removed pin info
procedure(gen_remove_pin_info(vams_pin_list)
    let((sym_pin_list remove_pin_list port remove_info)
        sym_pin_list = unique_pins(PIN_LIST)
        remove_pin_list = list()
        foreach(port vams_pin_list
            unless(member(port sym_pin_list)
                remove_pin_list = append1(remove_pin_list, port)
            )
        )
        if(length(remove_pin_list) >= 1 then
            remove_info = "Removed the following pin"
            if(length(remove_pin_list) > 1 then remove_info = strcat(remove_info "s"))
            remove_info = strcat(remove_info ": ")
            remove_info = strcat(remove_info buildString(remove_pin_list, ", "))
            remove_info = strcat("//" remove_info ".\n")
        else
            remove_info = ""
        )
        remove_info
    )
)

;generate the pins that needs update electrical/vdd,vss
procedure(gen_update_pin_list(vams_hash_pin_info)
    let((port port_name port_prop update_pin_list )
        update_pin_list = list()
        foreach(port PIN_LIST
            port_name = car(extract_pin_orig(port))
            if(member(port_name vams_hash_pin_info->?) then
                port_prop = cadr(vams_hash_pin_info[port_name])
                if(port_prop && port_prop != "" then
                    hash_pin_info[port] = append1(hash_pin_info[port] port_prop)
                else
                    if(not(member(port_name update_pin_list)) then
                        update_pin_list = append1(update_pin_list port_name)
                    )
                )
            else
                if(not(member(port_name update_pin_list)) then
                    update_pin_list = append1(update_pin_list port_name)
                )
            )
        )
        update_pin_list
    )
)

procedure(unique_pins(in_list)
    let((new_list pin pin_info)
        new_list = list()
        foreach(pin in_list
            pin_info = extract_pin_orig(pin)
            if(not(member(car(pin_info) new_list)) then
                new_list = append1(new_list car(pin_info))
            )
        )
        new_list
    )
)

;update the hash table from the pin list setup form
procedure(update_hash(in_list)
    let((new_pin_hash new_list pin_name pin_domain pin_ss pin_range pin_info)
        new_pin_hash = makeTable("new pin table")
        foreach(item in_list
            pin_name = car(item)
            pin_domain = cadr(item)->value
            pin_ss = caddr(item)->value
            if(valid_value_pair(pin_ss) then
                new_pin_hash[pin_name] = pin_ss
            else
                new_pin_hash[pin_name] = pin_domain
            )
        )
        foreach(item hash_pin_info->?
            pin_info = extract_pin_orig(item)
            pin_name = car(pin_info)
            pin_range = cadr(pin_info)
            ;printf("%s %s\n", pin_name, pin_range)
            if(member(pin_name new_pin_hash->?) then
                hash_pin_info[item] = append1(hash_pin_info[item] new_pin_hash[pin_name])
            )
        )
        ;gen_code_from_hash()
    )
)

;re generate the vams code from the predefined hash
procedure(re_gen_vams_code(vams_file module_name @optional (in_list list())(is_new_file 0)(vams_header ""))
    let((def_array def_range_list first_1_line_num last_1_line_num in_fh line_num new_lines in_line module_info module_def pin_def new_line)
        module_info = gen_code_from_hash()
        module_def = break_string(sprintf(nil "module %s(%s);\n" module_name, car(module_info)))
        pin_def = cadr(module_info)
        new_lines = list(vams_header)
        if(isFile(vams_file) then
            if(is_new_file == 0 then
                def_array = find_pin_module_def_lines(vams_file in_list)
                def_range_list = find_first_1_last_1(def_array)
                first_1_line_num = car(def_range_list)
                last_1_line_num = cadr(def_range_list)
                in_fh = infile(vams_file)
                line_num = 0
                while(gets(in_line in_fh)
                    line_num += 1
                    if(line_num < first_1_line_num || line_num > last_1_line_num then
                        new_lines = append1(new_lines in_line)
                    else
                        if(line_num == first_1_line_num then
                            new_lines = append1(new_lines module_def)
                            new_lines = append1(new_lines pin_def)
                            new_lines = append1(new_lines "//end of pin definition\n")
                        )
                    )
                )
                close(in_fh)
            else
                new_lines = append1(new_lines module_def)
                new_lines = append1(new_lines pin_def)
                new_lines = append1(new_lines "//end of pin definition\n")
                new_lines = append1(new_lines "endmodule\n")
            )
            foreach(new_line new_lines
                ;printf("test: new_line\n")
                printf("%s", new_line)
            )
            new_lines
        )
    )
)

;generate module pin defs, port declaration
procedure(gen_code_from_hash()
    let((all_pins pin_info pin_name pin_range duplicate_pins pin_decs pin_dir pin_domain port_decs)
        all_pins = list()
        foreach(pin PIN_LIST
            pin_info = extract_pin_orig(pin)
            pin_name = car(pin_info)
            pin_range = cadr(pin_info)
            all_pins = append1(all_pins pin_name)
        )
        printf("%s\n", buildString(all_pins " "))
        duplicate_pins = duplicate_in_array(all_pins)
        all_pins = list()
        pin_decs = ""
        foreach(pin PIN_LIST
            pin_info = extract_pin_orig(pin)
            pin_name = car(pin_info)
            pin_range = cadr(pin_info)
            pin_dir = car(hash_pin_info[pin])
            pin_domain = cadr(hash_pin_info[pin])
            pin_decs = strcat(pin_decs gen_pin_dec(pin_name pin_range pin_dir pin_domain))
            if(member(pin_name duplicate_pins) pin_name = replace_lt_gt_sq(pin))
            all_pins = append1(all_pins pin_name)
        )
        ;port listing in module declaration
        port_decs = buildString(all_pins ", ")
        ;printf("%s\n", port_decs)
        ;printf(pin_decs)
        list(port_decs, pin_decs)
    )
)

;generate a pin_list and pin direction hash table from the cell view
procedure(gen_pin_list_hash_from_view(@optional (cv dgcv())(no_sq_brkt 0))
    let((pin cv_hash_pin_info cv_pin_list)
        cv_hash_pin_info = makeTable("Pin info")
        cv_pin_list = list()
        if(cv~>terminals then
            cv_hash_pin_info = makeTable("Pin info")
            foreach(pin cv~>terminals
                pin_name = pin~>name
                if(no_sq_brkt == 1 then
                    pin_name = car(extract_pin_orig(pin_name))
                )
                if(not(member(pin_name cv_pin_list)) then
                    cv_pin_list = append1(cv_pin_list pin_name)
                )
                cv_hash_pin_info[pin_name] = list(pin~>direction)
            )
        )
        list(cv_hash_pin_info cv_pin_list)
    )
)

;from vams cellview
procedure(extract_pin_info_from_vams_view(lib_name cell_name view_name @optional (print_info 0))
    let((cv_vams_pin_hash cv_vams_pin_list file_vams_pin_hash file_vams_pin_list vams_obj vams_cv vams_cv_info vams_file )
        cv_vams_pin_hash = makeTable("verilogams pin hash")
        file_vams_pin_hash = makeTable("verilogams pin hash")
        cv_vams_pin_list = list()
        file_vams_pin_list = list()
        vams_obj = ddGetObj(lib_name cell_name view_name)
        vams_cv = dbOpenCellViewByType(lib_name cell_name view_name "netlist" "r")
        if(vams_cv then
            ;donot include square bracket
            vams_cv_info = gen_pin_list_hash_from_view(vams_cv 1)
            cv_vams_pin_hash = car(vams_cv_info)
            cv_vams_pin_list = cadr(vams_cv_info)
        )
        if(vams_obj then
            vams_file = strcat(vams_obj~>readPath "/verilog.vams")
            ;printf("%s\n", vams_file)
            vams_file_pin_info = gen_pin_info_hash_from_file(vams_file)
            file_pin_hash = car(vams_file_pin_info)
        )
        if(cv_vams_pin_hash->? && file_pin_hash->? then
            foreach(pin_name cv_vams_pin_hash->?
                if(member(pin_name file_pin_hash->?) then
                    cv_vams_pin_hash[pin_name] = append1(cv_vams_pin_hash[pin_name] file_pin_hash[pin_name])
                else
                    printf("%s is not defined in vams file.\n", pin_name)
                )
            )
        else
            printf("Vams view doesnot have good stuff.\n")
        )
        foreach(pin_name cv_vams_pin_hash->?
            if(print_info == 1 then
                printf("%s-", pin_name)
                pin_info_list = cv_vams_pin_hash[pin_name]
                foreach(pin_info pin_info_list
                    printf("%s-", pin_info)
                )
                printf("\n")
            )
        )
        cv_vams_pin_hash
    )
)

procedure(extract_ss_from_hash(in_hash)
    let((out_list item item_value)
        out_list = list("")
        foreach(item in_hash->?
            item_value = cadr(in_hash[item])
            if(item_value then
                if(rexMatchp("," item_value) && not(member(item_value, out_list)) then
                    out_list = append1(out_list item_value)
                )
            else
                printf("value for %s is not valid 428.\n", item)
            )
        )
        out_list
    )
)

;extract the pin information from the vams file
procedure(gen_pin_info_hash_from_file(vams_file)
    let((file_vams_pin_hash file_vams_pin_list in_fh comment_line_start whole_line vams_line in_line file_pin_info file_module_names file_module_name line_pin_info file_module_info)
        ;this hash is the pin's dig ss table or analog property
        file_pin_hash = makeTable("this line's pin hash table")
        ;this hash is the pin's direction table
        file_pin_dir_hash = makeTable("this line's pin direction hash table")
        ;this hash is the digital pin's table
        file_dig_pin_hash = makeTable("digital pin hash table")
        file_module_names = list()
        file_pin_info = list(file_pin_hash file_pin_dir_hash file_dig_pin_hash)
        if(isFile(vams_file) then
            in_fh = infile(vams_file)
            comment_line_start = 0
            whole_line = ""
            while(gets(vams_line in_fh)
                rexCompile("\n")
                in_line = rexReplace(vams_line, "", 0)
                rexCompile("[ \t][ \t]*")
                in_line = rexReplace(in_line, " ", 0)
                in_line = remove_trailing_following_spaces(in_line)
                rexCompile("//.*")
                in_line = rexReplace(in_line, "", 0)
                rexCompile("/\\*.*")
                if(comment_line_start == 0 && rexExecute(in_line) then
                    rexCompile(".*\\*/")
                    unless(rexExecute(in_line)
                        comment_line_start = 1
                    )
                    rexCompile("/\\*.*")
                    in_line = rexReplace(in_line, "", 0)
                else
                    if(comment_line_start == 1 then
                        rexCompile(".*\\*/")
                        if(rexExecute(in_line) then
                            comment_line_start = 0
                            in_line = rexReplace(in_line, "", 0)
                        else
                            in_line = ""
                        )
                    )
                )
                whole_line = strcat(whole_line in_line if(in_line == "" "" " "))
                if(rexMatchp(";$", in_line) || rexMatchp("end[a-z]*$", in_line) || rexMatchp("^`[a-z]*", in_line) then
                    ;printf("%s\n", whole_line)
                    whole_line = remove_trailing_following_spaces(whole_line)
                    if(rexMatchp("^module\\>.*", whole_line) then
                        file_module_info = extract_module_line_info(whole_line)
                        file_module_name = car(file_module_info)
                        file_vams_pin_list = cadr(file_module_info)
                        ;printf("495 %s\n" file_module_name)
                        unless(member(file_module_name file_module_names)
                            file_module_names = append1(file_module_names file_module_name)
                        )
                    )
                    line_pin_info = analyze_pin_info_from_line(whole_line)
                    for(ii 1 3 update_hash_w_hash(nthelem(ii file_pin_info) nthelem(ii line_pin_info)))
                    whole_line = ""
                )
            )
        )
        close(in_fh)
        ;foreach(hash1 file_pin_info
            ;foreach(item hash1->?
                ;printf("%s,%s\n", item, hash1[item])
            ;)
        ;)
        ;printf(" 512 %s\n", buildString(file_module_names " "))
        file_pin_info = append1(file_pin_info file_module_names)
    )
)


;find first/last line of pin definition, assume that after module definition it is just all pin definitions, all pin definitions reside on one line, pin definitions include input/output/inout/electrical/wire, all digital wire should be defined in wire with proper pin definitions
procedure(find_pin_module_def_lines(in_file @optional (in_list list()))
    let((def_array pin_def_keywords in_fh pin_def_ends this_pin_list is_def is_key_def is_assign_def is_pin_def)
        def_array = list()
        if(isFile(in_file) then
            pin_def_keywords = parseString("input output inout wire reg electrical")
            in_fh = infile(in_file)
            pin_def_ends = 0
            this_pin_list = if(in_list in_list car(gen_pin_info_hash_from_file(in_file))->?)
            while(gets(in_line in_fh)
                is_def = 0
                is_key_def = 0
                is_pin_def = 0
                is_assign_def = 0
                if(rexMatchp("^[ \t]*module\\>" in_line) then
                    if(pin_def_ends == 0 is_def = 1)
                )
                if(rexMatchp("//end of pin definition" in_line) then
                    is_def = 1
                    pin_def_ends = 1
                )
                if(pin_def_ends == 0 then
                    all_line_items = parseString(in_line, " \t[]();")
                    foreach(item all_line_items
                        if(member(item pin_def_keywords) then
                            is_key_def = 1
                        )
                        if(item == "=" is_assign_def = 1)
                        if(member(item this_pin_list) && (is_assign_def == 0) then
                            is_pin_def = 1
                        )
                    )
                    if(is_key_def == 1 && is_pin_def == 1 then
                        is_def = 1
                    )
                )
                def_array = append1(def_array is_def)
            )
            close(in_fh)
        )
        def_array
    )
)


procedure(find_first_1_last_1(in_list)
    let((item first_one_index last_one_index)
        first_one_index = find_first_1(in_list)
        last_one_index = find_last_1(in_list)
        list(first_one_index last_one_index)
    )
)


procedure(find_first_1(in_list)
    let((item found_index found_1 item_index)
        item_index = 0
        found_1 = 0
        found_index = -1
        foreach(item in_list
            item_index += 1
            if(item == 1 then
                if(found_1 == 0 then
                    found_1 = 1
                    found_index = item_index
                )
            )
        )
        found_index
    )
)

procedure(find_last_1(in_list)
    let((reversed_list first_1_index last_1_index )
        reversed_list = reverse(in_list)
        first_1_index = find_first_1(reversed_list)
        last_1_index = if(first_1_index != -1 length(in_list) - first_1_index + 1 -1)
        last_1_index
    )
)

;extract pin declaration
procedure(extract_pin_dec_names(in_str)
    let((pin_dec pin_range pin_names pin_info pins_after_dec)
        rexCompile("[ \t]*\\([a-z][a-z]*\\)\\(.*\\);")
        if(rexExecute(in_str) then
            pin_dec = rexSubstitute("\\1")
            pins_after_dec = rexSubstitute("\\2")
            ;printf("%s\n", rexSubstitute("\\2"))
            ;pin_full_ss = extract_ss(remove_trailing_following_spaces(rexSubstitute("\\3")))
            pin_info = extract_pins_after_dec(pins_after_dec)
            pin_dec = remove_trailing_following_spaces(pin_dec)
            pin_range = car(pin_info)
            pin_names = cadr(pin_info)
            list(pin_dec pin_range pin_names)
        else
            nil
        )
    )
)

;extract the pin list from declaration after electrical/wire/reg/in,out etc
procedure(extract_pins_after_dec(in_str)
    let((str1 pin_range pin_after_dec pin_list_after_dec)
        str1 = remove_trailing_following_spaces(in_str)
        rexCompile(";$")
        str1 = rexReplace(str1, "", 0)
        rexCompile("^\\(\\[.*\\]\\)\\(.*\\)")
        if(rexExecute(str1) then
            pin_range = rexSubstitute("\\1")
            pin_after_dec = rexSubstitute("\\2")
        else
            pin_range = ""
            pin_after_dec = str1
        )
        rexCompile(",")
        if(rexExecute(pin_after_dec) then
            pin_list_after_dec = remove_tr_fol_spaces_list(parseString(pin_after_dec, ","))
        else
            pin_list_after_dec = remove_tr_fol_spaces_list(list(pin_after_dec))
        )
        list(pin_range pin_list_after_dec)
    )
)

;extract the supplySensitivity for the pin
procedure(extract_ss(in_str)
    let((supply ground orig_supply orig_ground)
        rexCompile("supplySensitivity.*\"\\(.*\\)\".*groundSensitivity.*\"\\(.*\\)\"")
        if(rexExecute(in_str) then
            orig_supply = rexSubstitute("\\1")
            orig_ground = rexSubstitute("\\2")
        else
            rexCompile("groundSensitivity.*\"\\(.*\\)\".*supplySensitivity.*\"\\(.*\\)\"")
            if(rexExecute(in_str) then
                orig_supply = rexSubstitute("\\2")
                orig_ground = rexSubstitute("\\1")
            else
                orig_supply = ""
                orig_ground = ""
            )
        )
        supply = remove_trailing_following_spaces(orig_supply)
        ground = remove_trailing_following_spaces(orig_ground)
        if(supply == "" && ground == "" "" strcat(supply "," ground))
    )
)

;remove trailing following spaces for each item in the list
procedure(remove_tr_fol_spaces_list(in_list)
    let((out_list str)
        out_list = list()
        foreach(str in_list
            out_list = append1(out_list, remove_trailing_following_spaces(str))
        )
        out_list
    )
)

;remove trailing following spaces for in_str
procedure(remove_trailing_following_spaces(in_str)
    let((out_str)
        rexCompile("^ *")
        out_str = rexReplace(in_str, "", 0)
        rexCompile(" *$")
        out_str = rexReplace(out_str, "", 0)
        out_str
    )
)

;analyze the pin information from the line
procedure(analyze_pin_info_from_line(in_str)
    let((str this_pin_hash this_pin_dir_hash dig_pin_hash str_list has_ss pin_ss str pin_info pin_dec pin_range pin_names_list pin_name pin_ss_whole hash_list hash1)
        ;this hash is the pin's dig ss table or analog property
        this_pin_hash = makeTable("this line's pin hash table")
        ;this hash is the pin's direction table
        this_pin_dir_hash = makeTable("this line's pin direction hash table")
        ;this hash is the digital pin's table
        dig_pin_hash = makeTable("digital pin hash table")
        str_list = split_string_in_par(in_str)
        foreach(str str_list
            rexCompile("(\\(.*supplySensitivity.*groundSensitivity.*\\))")
            has_ss = 0
            if(rexExecute(str) then
                pin_ss_whole = rexSubstitute("\\1")
                ;printf("%s, %s\n", pin_ss_whole, str)
                pin_ss = extract_ss(pin_ss_whole)
                ;printf("%s, %s\n", pin_ss, str)
                rexCompile("(\\(.*supplySensitivity.*groundSensitivity.*\\))")
                ;printf("%s\n", str)
                str = rexReplace(str, "", 0)
                has_ss = 1
            else
                pin_ss = ""
            )
            if(rexMatchp("^input", str) || rexMatchp("^output", str) || rexMatchp("^inout", str) || rexMatchp("^electrical", str) || rexMatchp("^wire", str) || rexMatchp("^reg", str) then
                pin_info = extract_pin_dec_names(str)
                pin_dec = car(pin_info)
                ;printf("%s\n", pin_dec)
                pin_range = cadr(pin_info)
                pin_names_list = caddr(pin_info)
                foreach(pin_name pin_names_list
                    if(has_ss == 1 then
                        this_pin_hash[pin_name] = pin_ss
                    )
                    if(pin_dec == "electrical" then
                        this_pin_hash[pin_name] = "analog"
                    )
                    if(member(pin_dec list("input", "output", "inout")) then
                        this_pin_dir_hash[pin_name] = pin_dec
                    )
                    if(member(pin_dec list("wire", "reg")) then
                        dig_pin_hash[pin_name] = pin_dec
                    )
                )
            )
        )
        hash_list = list(this_pin_hash, this_pin_dir_hash, dig_pin_hash)
        hash_list
    )
)

;extract model pins list from vams module line
procedure(extract_module_line_info(in_str)
    let((module_name all_pin_names all_pin_list)
        rexCompile("^[ \t]*module[ \t][ \t]*\\(.*\\)(\\(.*\\));")
        if(rexExecute(in_str) then
            module_name = rexSubstitute("\\1")
            all_pin_names = rexSubstitute("\\2")
            all_pin_list = cadr(extract_pins_after_dec(all_pin_names))
        else
            module_name = ""
            all_pin_list = list()
        )
        list(module_name all_pin_list)
    )
)

;update hash1 with newly generated hash2 table
procedure(update_hash_w_hash(hash1, hash2)
    let((item)
        foreach(item hash2->?
            if(member(item hash1->?) then
                if(hash1[item] != hash2[item] then
                    printf("%s exists in hash1 with value of %s and will be updated to %s.", item, hash1[item], hash2[item])
                )
            )
            hash1[item] = hash2[item]
        )
    )
)

;split the string with ; but include the string with () as single string
;i.e. split abc;d(ef;g)h; as strings of abc; d(ef;g)h;
procedure(split_string_in_par(in_str)
    let((end_semicolon in_str1 in_list out_list new_line half_complete item_index item )
        if(rexMatchp(";[ \t\n]*$", in_str) then
            end_semicolon = 1
        else
            end_semicolon = 0
        )
        rexCompile(";;*[ \t\n]*$")
        in_str1 = remove_trailing_following_spaces(rexReplace(in_str, "", 0))
        in_list = parseString(in_str1, ";")
        out_list = list()
        new_line = ""
        half_complete = 0
        item_index = 0
        foreach(item in_list
            item = remove_trailing_following_spaces(item)
            item_index += 1
            unless(item_index == length(in_list) && end_semicolon == 0 item = strcat(item ";"))
            new_line = strcat(new_line item)
            if(rexMatchp("(" item) then
                half_complete = 1
            )
            if(rexMatchp(")" item) then
                half_complete = 0
            )
            if(half_complete == 0 then
                out_list = append1(out_list new_line)
                new_line = ""
            )
        )
        ;;foreach(new_line out_list
                ;printf("%s\n", new_line)
        ;)
        if(new_line != "" out_list = append1(out_list new_line))
        out_list
    )
)

;generate the pin declaration
procedure(gen_pin_dec(pin_name pin_range pin_dir pin_domain)
    let((pin_range_sq pin_dir_st supply ground sense_str pin_prop pin_dec_sep pin_dec)
        pin_range_sq = replace_lt_gt_sq(pin_range)
        pin_range_sq = if(pin_range_sq == "" " " strcat(" " pin_range_sq " "))
        ;standardized pin direction
        pin_dir_st = if(pin_dir == "inputOutput" "inout" pin_dir)
        if(rexMatchp(",", pin_domain) then
            rexCompile("\\(.*\\),\\(.*\\)")
            rexExecute(pin_domain)
            supply = rexSubstitute("\\1")
            ground = rexSubstitute("\\2")
            sense_str = sprintf(nil "(* integer supplySensitivity = %L;integer groundSensitivity = %L;*) ", supply, ground)
            pin_prop = "wire"
            pin_dec_sep = "\n    "
        else
            sense_str = ""
            pin_prop = "electrical"
            pin_dec_sep = num_spaces(30 - strlen(strcat(pin_dir_st pin_range_sq pin_name)))
        )
        pin_dec = sprintf(nil "    %s%s%s%s;%s", pin_dir_st, pin_range_sq, sense_str, pin_name, pin_dec_sep)
        pin_dec = sprintf(nil "%s%s%s%s;\n", pin_dec, pin_prop, pin_range_sq, pin_name)
    )
)

;find the duplicates in a array
procedure(duplicate_in_array(in_list)
    let((out_list item_hash item_name)
        out_list = list()
        item_hash = makeTable("")
        foreach(item_name in_list
            if(member(item_name item_hash->?) then
                item_hash[item_name] = item_hash[item_name] + 1
                unless(member(item_name out_list)
                    out_list = append1(out_list item_name)
                )
            else
                item_hash[item_name] = 1
            )
        )
        out_list
    )
)

procedure(replace_lt_gt_sq(in_str)
    let((out_str)
        out_str = in_str
        rexCompile("<")
        out_str = rexReplace(out_str "[" 0)
        rexCompile(">")
        out_str = rexReplace(out_str "]" 0)
        out_str
    )
)

procedure(break_string(in_str @optional (break_by ",") (max_len 60))
    let((str_list curr_len new_list char new_str)
        str_list = parseString(in_str "")
        curr_len = 0
        new_list = list()
        foreach(char str_list
            curr_len += 1
            new_list = append1(new_list char)
            if(char == break_by && curr_len >= max_len then
                new_list = append1(new_list "\n ")
                curr_len = 0
            )
        )
        new_str = buildString(new_list, "")
        ;printf(new_str)
        new_str
    )
)

procedure(format_field(field)
    let((orig_value new_value)
        orig_value = field->value
        new_value = remove_spaces(orig_value)
        if(not(valid_value_pair(new_value)) then
            printf("Please enter a correct value pair.\n")
        else
            field->value = new_value
        )
    )
)

procedure(remove_spaces(in_value)
    let((new_value)
        rexCompile(" ")
        new_value = rexReplace(in_value, "", 0)
        rexCompile("\\t")
        new_value = rexReplace(new_value, "", 0)
    )
)

procedure(valid_value_pair(in_value)
    let((new_value valid_value)
        new_value = remove_spaces(in_value)
        valid_value = rexMatchp(",", new_value) && rexMatchp("..*,..*", new_value)
    )
)

procedure(add_remove_fields(field1 all_fields)
    let((field_value fld)
        format_field(field1)
        field_value = field1->value
        if(field_value != "" && valid_value_pair(field_value) then
            foreach(fld all_fields
                if(not(member(field_value fld->choices)) then
                    fld->choices = append1(fld->choices field_value)
                else
                    fld->choices = remove(field_value fld->choices)
                )
            )
        )
    )
)
procedure(update_dig_ref_fields(pin pin_dig_sel)
    let((dig_ref_choices)
        dig_ref_choices = pin_dig_sel->choices
        pin_dig_sel->value = if(pin->value == "analog" car(dig_ref_choices) cadr(dig_ref_choices))
    )
)

procedure(update_pin_pro(pin pin_dig_sel)
    let(()
        pin->value = if(pin_dig_sel->value == "" "analog" "digital")
    )
)

procedure(update_vamsfile_from_dict(vams_file, pin_dict)
    let((out_lines in_f in_line out_line pin new_pin old_pin_sep )
        if(isFile(vams_file) then
            out_lines = list()
            in_f = infile(vams_file)
            while(gets(in_line in_f)
                out_line = in_line
                foreach(pin pin_dict->?
                    new_pin = pin_dict[pin]
                    old_pin_sep = strcat("\\<" pin "\\>")
                    rexCompile(old_pin_sep)
                    out_line = rexReplace(out_line new_pin 0)
                )
                out_lines = append1(out_lines out_line)
            )
            close(in_f)
            foreach(out_line out_lines
                printf(out_line)
            )
        )
    )
)

procedure(replace_inst_by_cellname(old_inst_cellName new_inst @optional (cv dgcv()))
    let((inst)
        foreach(inst cv~>instances
            if(inst~>cellName  == old_inst_cellName then
                inst~>master = new_inst
            )
        )
        check_save_cv(cv)
    )
)

procedure(check_save_cv(@optional (cv dgcv()))
    let(()
        dbCheck(cv)
        dbSave(cv)
    )
)
procedure(copy_cells(lib_name cell_name new_lib)
    let(()
    )
)

procedure(copy_symbol_view(lib_name cell_name new_lib new_cell @optional (copied_views list("symbol" "verilogams")))
    let((old_view view new_view copied copied_list)
        ;old_view = dbOpenCellViewByType(lib_name cell_name "symbol" "schematicSymbol" "r")
        ;new_view = dbOpenCellViewByType(new_lib new_cell "symbol" "schematicSymbol" "r")
        copied_list = list()
        foreach(view copied_views
            old_view = ddGetObj(lib_name cell_name view)
            new_view = ddGetObj(new_lib new_cell view)
            if(not(old_view) then
                printnf("%s-%s-%s doesnot exist.\n", lib_name cell_name view)
                copied = 0
            else
                if(not(new_view) then
                    CCScopyViewCV(lib_name cell_name view new_lib new_cell view)
                    copied = 1
                else
                    copied = 0
                )
            )
            copied_list = append1(copied_list copied)
            ;new_view = dbOpenCellViewByType(new_lib new_cell "symbol" "schematicSymbol" "r")
        )
    )
)

procedure(update_symbol_pins(lib_name cell_name @optional (update_symbol 1)(view_name "symbol"))
    let((pin_name new_pin_name new_top_pins cv term_dict)
        term_dict = makeTable("Table for terrminals")
        if(view_name == "symbol" view_type = "schematicSymbol" view_type = view_name)
        cv = dbOpenCellViewByType(lib_name cell_name view_name view_type "a")
        new_top_pins = list()
        foreach(pin top_pins
            new_top_pins = append1(new_top_pins pin)
            new_top_pins = append1(new_top_pins strcat(pin "k"))
            new_top_pins = append1(new_top_pins strcat(pin "s"))
            new_top_pins = append1(new_top_pins strcat(pin "1"))
            new_top_pins = append1(new_top_pins strcat(pin "2"))
        )
        foreach(pin_name cv~>terminals~>name
            new_pin_name = if(member(pin_name new_top_pins) pin_name change_to_lc_whole(pin_name))
            printf("%s %s\n", pin_name, new_pin_name)
            term_dict[pin_name] = new_pin_name
            if(new_pin_name != pin_name then
                CCSchangePinAndLabel(pin_name new_pin_name cv)
            )
        )
        term_dict
    )
)

;string with ","
procedure(change_to_lc_whole(in_str  @optional (to_uc 0)(str_dict makeTable("")))
    let((all_pins new_pins pin out_str)
        if(rexMatchp(",", in_str) then
            all_pins = parseString(in_str, ", ")
            new_pins = list()
            foreach(pin all_pins
                new_pins = append1(new_pins, change_to_lc_full(pin, to_uc, str_dict))
            )
            out_str = buildString(new_pins, ",")
        else
            out_str = change_to_lc_full(in_str, to_uc, str_dict)
        )
        out_str
    )
)


;string with <> but without ","
procedure(change_to_lc_full(in_str @optional (to_uc 0)(str_dict makeTable("")))
    let((pin_info out_str)
        if(rexMatchp("<.*>" in_str) then
            pin_info = extract_pin_orig(in_str)
            new_pin_name = change_to_lc_us(car(pin_info) to_uc)
            out_str = strcat(new_pin_name cadr(pin_info))
        else
            new_pin_name = change_to_lc_us(in_str to_uc)
            out_str = new_pin_name
        )
        if(not(member(in_str str_dict~>?)) then
            str_dict[in_str] = new_pin_name
        else
            if(str_dict[in_str] != new_pin_name then
                printf("%s old name %s and new name %s donot match.\n", in_str, str_dict[in_str], new_pin_name)
            )
        )
        out_str
    )
)

;string with underscores without <>
procedure(change_to_lc_us(in_str @optional (to_uc 0))
    let((strs new_strs out_str)
        if(rexMatchp("_", in_str) then
            strs = parseString(in_str, "_")
            new_strs = list()
            foreach(str strs
                new_str = change_to_lc(str to_uc)
                new_strs = append1(new_strs new_str)
            )
            out_str = buildString(new_strs "_")
        else
            out_str = change_to_lc(in_str to_uc)
        )
        out_str
    )
)

;only change the main portion without _
procedure(change_to_lc(in_str @optional (to_uc 0))
    let((out_str all_chars new_chars char_index pre_char char case_switch_time)
        if(or(is_upper_case_str(in_str) is_lower_case_str(in_str)) then
            out_str = if(to_uc == 0 lc(in_str) uc(in_str))
        else
            all_chars = parseString(in_str, "")
            new_chars = list()
            char_index = 0
            pre_char = ""
            case_switch_time = 0
            first_char = car(all_chars)
            foreach(char all_chars
                char_index += 1
                if(char_index >= 2 then
                    if(case_switched(pre_char char) then
                        if(not(char_index == 2 && is_upper_case_char(first_char)) then
                            if(remainder(case_switch_time, 2) == 0 then
                                new_chars = append1(new_chars "_")
                            )
                            case_switch_time += 1
                        )
                    )
                )
                new_chars = append1(new_chars if(to_uc == 0 lc(char) uc(char)))
                pre_char = char
            )
            out_str = buildString(new_chars, "")
        )
        out_str
    )
)

procedure(is_number(in_char)
    let((is_number)
        is_number = rexMatchp("^[0-9]$", in_char)
    )
)

procedure(is_lower_case_char(in_char)
    let((is_lower)
        is_lower = rexMatchp("^[a-z0-9]$", in_char)
    )
)

procedure(is_lower_case_str(in_str)
    let((is_lower all_chars char)
        all_chars = parseString(in_str, "")
        is_lower = t
        foreach(char all_chars
            is_lower = and(is_lower is_lower_case_char(char))
        )
        is_lower
    )
)

procedure(is_upper_case_char(in_char)
    let((is_upper)
        is_upper = rexMatchp("^[A-Z0-9]$", in_char)
    )
)

procedure(is_upper_case_str(in_str)
    let((is_upper all_chars char)
        all_chars = parseString(in_str, "")
        is_upper = t
        foreach(char all_chars
            is_upper = and(is_upper is_upper_case_char(char))
        )
        is_upper
    )
)

procedure(case_switched(char1 char2)
    let((csw)
        csw = t
        if(or(is_number(char1) is_number(char2)) then
            csw = nil
        else
            if(or(and(is_upper_case_char(char1) is_upper_case_char(char2)) and(is_lower_case_char(char1) is_lower_case_char(char2))) then
                csw = nil
            )
        )
        csw
    )
)

procedure(extract_pin_orig(in_pin)
    let((term_name term_range)
        term_name = in_pin
        rexCompile("\\(.*\\)\\(<.*>\\)")
        if(rexExecute(term_name) then
            term_name = rexSubstitute("\\1")
            term_range = rexSubstitute("\\2")
            unless(rexMatchp(":" term_range)
                rexCompile("<\\(.*\\)>")
                rexExecute(term_range)
                single_term = evalstring(rexSubstitute("\\1"))
                term_range = rexReplace(term_range sprintf(nil "<%d:%d>" single_term single_term) 0)
            )
        else
            term_range = ""
        )
        list(term_name term_range)
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


procedure(CCSchangePinAndLabel(oldName newName @optional (cv geGetEditCellView() ) )
 let((oldTerm labelList portOrderProp newValForPortOrder)

  unless(cv~>cellViewType == "schematicSymbol" || "schematic"
    error("\nPlease pass a symbol or schematic cellview to this procedure")
  )

  oldTerm = dbFindTermByName(cv oldName)

  foreach(pin oldTerm~>pins
     if(dbFindNetByName(cv newName)
      then
      dbCreatePin( dbFindNetByName(cv newName) pin~>fig)
      dbFindTermByName(cv newName)~>direction = oldTerm~>direction
      dbDeleteObject(pin)

     else
      dbCreatePin(dbMakeNet(cv newName) pin~>fig)
      dbFindTermByName(cv newName)~>direction = oldTerm~>direction
      dbDeleteObject(pin)
    )
  );foreach

  unless(oldTerm~>pins dbDeleteObject(oldTerm) )
 
  ;; Update the pin label
  labelList = setof(shp cv~>shapes shp~>objType == "label")

  foreach(label labelList
   when(label~>theLabel == oldName label~>theLabel = newName)
     )


  ;; Update the portOrder property  as appropriate
   when(member("portOrder" cv~>prop~>name)
    portOrderProp = car(setof(prop cv~>prop prop~>name == "portOrder"))
    newValForPortOrder = CCSSearchAndReplaceElemInList(oldName newName portOrderProp~>value)
    portOrderProp~>value = newValForPortOrder
     )
    
  printf("\nDone\n")
 
  ;; dbSave(cv)

 );let
) ;procedure


procedure(CCSSearchAndReplaceElemInList(toBeSearchElem toBeReplaceElem mylist)
   foreach(mapcar elem mylist
     if(elem==toBeSearchElem toBeReplaceElem elem)
   ) ;foreach
 ) ;procedure

procedure(new_cell_name(old_cell_name)
    let((new_name new_vals)
        removed_endings = list("9*2*[34][18]_r[0-9]p[0-9]$" "9*2*41$" "9*2*38$" "_r[0-9]p[0-9]$")
        new_name = old_cell_name
        foreach(ending removed_endings
            rexCompile(ending)
            if(rexExecute(new_name) then
                ;new_name = rexReplace(old_cell_name, "_9250_r1p0", 0)
                new_name = rexReplace(new_name, "", 0)
            )
        )
        rexCompile("38")
        if(rexExecute(new_name) then
            new_name = rexReplace(new_name, "50", 0)
        )
        rexCompile("41")
        if(rexExecute(new_name) then
            new_name = rexReplace(new_name, "50", 0)
        )
        new_name = change_to_lc_full(new_name, 1)
        new_name = strcat(new_name, proj_ver)
        new_vals = parseString(new_name, "_")
        new_name = buildString(new_vals, "_")
        new_name
    )
)

procedure(update_all_inst_name(@optional (cv dgcv()))
    let((inst new_base_name new_name inst_index)
        foreach(inst cv~>instances
            update_inst_name(inst cv)
        )
        check_save_cv(cv)
    )
)

procedure(update_inst_name(inst @optional (cv dgcv()))
    let((new_base_name new_name)
        if(rexMatchp("^I[0-9]*$", inst~>name) then
            new_base_name = gen_new_base_name(inst~>cellName)
            new_name = gen_new_inst_name(new_base_name, cv~>instances~>name)
            inst~>name = new_name
        )
    )
)

procedure(gen_new_base_name(cell_name)
    let((new_base_name)
        rexCompile(proj_ver)
        new_base_name = rexReplace(cell_name, "", 0)
    )
)

procedure(gen_new_inst_name(base_name all_names)
    let((new_name inst_index)
        new_name = base_name
        inst_index = 0
        while(member(new_name all_names)
            inst_index += 1
            new_name = sprintf(nil "%s_%d", base_name, inst_index)
        )
        new_name
    )
)

procedure(get_term_table(this_obj)
    let((thisTable term terms_array term_dir)
        thisTable = makeTable("instance pin table")
        terms_array = list()
        if(this_obj~>terminals then
            foreach(term this_obj~>terminals
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

procedure(num_spaces(inNum)
    let((spaces)
        spaces = ""
        if(inNum >= 1 then
            for(i 1 inNum spaces = strcat(spaces " "))
        )
        spaces
    )
)

procedure(vamsHeaderGeneral_opt(instLibName instCellName instViewName @optional (is_new 1))
    let((vamsHeaderStr)
        if(is_new == 1 then
            create_info = "created "
        else
            create_info = "modified "
        )
        vamsHeaderStr = sprintf(nil "//Verilog-AMS HDL for <%L, %L, %L> %sby %s\n", instLibName, instCellName, instViewName, create_info, getShellEnvVar("USER"))
        vamsHeaderStr = sprintf(nil "%s//on %s\n", vamsHeaderStr getCurrentTime())
        if(is_new == 1 then
            vamsHeaderStr = sprintf(nil "%s\n`include %L\n", vamsHeaderStr "constants.vams")
            vamsHeaderStr = sprintf(nil "%s`include %L\n", vamsHeaderStr "disciplines.vams")
            vamsHeaderStr = sprintf(nil "%s`timescale 1ns/1ps\n\n", vamsHeaderStr)
        )
        vamsHeaderStr
    )
)

procedure(extract_pin_list(in_list)
    let((pinRangeTable pin termName termRange term_list)
        ;printf("extracting pin info from %s\n", buildString(in_list, " "))
        pinRangeTable = makeTable("Table for instance pins range")
        foreach(pin in_list
            term_list = extract_pin_orig(pin)
            termName = car(term_list)
            termRange = cadr(term_list)
            ;pin_list = 
            ;if(listp(pin_list) printf("this is a list\n") printf("this is not a list\n"))
            ;printf("%s\n", buildString(pin_list, " "))
            if(member(termName pinRangeTable->?) then
                pinRangeTable[termName] = strcat(termRange pinRangeTable[termName])
            else
                pinRangeTable[termName] = termRange
            )
        )
        ;printf("finishing extracting pin info from %s\n", buildString(in_list, " "))
        pinRangeTable
    )
)

procedure(write_to_file_list(in_list inFile)
    let((ofileH)
        ofileH = outfile(inFile "w")
        ;fprintf(ofileH "%s" buildString(in_list ""))
        foreach(line in_list
            fprintf(ofileH "%s" line)
        )
        close(ofileH)
        inFile
    )
)
