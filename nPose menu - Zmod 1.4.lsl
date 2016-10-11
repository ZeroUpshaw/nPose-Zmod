

list Permissions = ["PUBLIC"]; 
string curmenuonsit = "on"; 
string cur2default = "on";  
string Facials = "on";
string menuReqSit = "off";  
string RLVenabled = "on";   


list victims;
list options = [];
string path;
list slots;
integer curseatednumber = 0;
list slotbuttons = [];
list dialogids;     
key toucherid;
list avs;
list menus;
list menus_SEND;
integer start;
integer end;
list menuPerm = [];
float currentOffsetDelta = 0.2;
string defaultname;                
string setname;
string btnname;
string defaultPoseSEND;

//#line 79 "E:\\Programme\\Firestorm-Release\\nPose menu - Zmod v1.4"
list offsetbuttons = ["forward", "left", "up", "backward", "right", "down", "0.2", "0.1", "0.05", "0.01", "reset"];




//#line 103 "E:\\Programme\\Firestorm-Release\\nPose menu - Zmod v1.4"
list adminbuttons = ["Adjust", "StopAdjust", "PosDump", "Unsit", "Options"];

list SeatedAvs(){ 
    avs=[];
    integer counter = llGetNumberOfPrims();
    while (llGetAgentSize(llGetLinkKey(counter)) != <0, 0, 0>){
        avs += llGetLinkKey(counter);
        --counter;
    }
    return avs;
}

DoMenu_AccessCtrl(key toucher, string path, string menuPrompt, integer page){
    integer authorized;
    if (toucher == llGetOwner() && !~llListFindList(victims, [(string)llGetOwner()])){
        authorized = TRUE;
    }else if ((llList2String(Permissions, 0) == "GROUP" && llSameGroup(toucher))
     | (llList2String(Permissions, 0) == "PUBLIC")){
        if (!~llListFindList(victims, [(string)toucher])){ 
            authorized = TRUE;
        }
    }
    if (authorized){
        DoMenu(toucher, path, menuPrompt, page);
    }
}

DoMenu(key toucher, string path, string menuPrompt, integer page){
    integer index = llListFindList(menus, [path]);
    if (~index){
        list buttons = llParseStringKeepNulls(llList2String(menus, index+1), ["|"], []);
        list tmp = [];
        if (path != "Main"){
            tmp += ["^"];
        }
        key id = Dialog(toucher, menuPrompt + "\n"+path+"\n", buttons, tmp, page);
        tmp = [id, toucher, path];
        index = llListFindList(dialogids, (list)toucher);
        if (~index){ 
            dialogids = llListReplaceList(dialogids, tmp, index+-1, index+1);        
        }else{ 
            dialogids += tmp;
        }       
    }
}

key Dialog(key rcpt, string prompt, list choices, list utilitybuttons, integer page){
    key id = "";
    
    integer stopc = llGetListLength(choices);
    integer nc;
    if (!~llListFindList(SeatedAvs(), [toucherid])){
        
        
        if (toucherid == llGetOwner() | (toucherid != llGetOwner() && menuReqSit == "off")){
            if (toucherid != llGetOwner()){
                for (; nc < stopc; ++nc){
                    
                    integer indexc = llListFindList(menuPerm, [llList2String(choices, nc)]);
                    
                    if (((indexc != -1)
                     && (!llSubStringIndex(llList2String(menuPerm, indexc + 1), "group") && !llSameGroup(toucherid)))
                      || (!llSubStringIndex(llList2String(menuPerm, indexc + 1), "owner"))){
                        choices = llDeleteSubList(choices, nc, nc);
                        --nc;
                        --stopc;
                    }
                }
            }
            id = llGenerateKey();
            llMessageLinked(LINK_SET, -900, (string)rcpt + "|" + prompt + "|" + (string)page
             + "|" + llDumpList2String(choices, "`") + "|" + llDumpList2String(utilitybuttons, "`"), id);
        }
    }else{
        
        
        integer slotIndex = llListFindList(slots, [toucherid]);
        integer z = llSubStringIndex(llList2String(slots, slotIndex + 1), "§");
        string seat# = llGetSubString(llList2String(slots, slotIndex + 1), z+5,-1);
        for (nc = 0; nc < stopc; ++nc){
            
            integer indexc = llListFindList(menuPerm, [llList2String(choices, nc)]);
            if (indexc != -1){
                
                list permsList = llParseString2List(llList2String(menuPerm, indexc + 1), ["~"],[]);

                if (llGetListLength(permsList) > 1){
                    
                    list seatPerms = llList2List(permsList, 1, -1);
                    
                    
                    
                    
                    if (((~llSubStringIndex(llDumpList2String(seatPerms, ""), "!")) && (~llListFindList(seatPerms,["!" + seat#])))
                     | ((!~llSubStringIndex(llDumpList2String(seatPerms, ""), "!")) && (!~llListFindList(seatPerms,[seat#])))){
                        choices = llDeleteSubList(choices, nc, nc);
                        --nc;
                        --stopc;
                    }
                }else{
                    
                    if ((llList2String(permsList, 0) == "owner" && toucherid != llGetOwner())
                     | (llList2String(permsList, 0) == "group" && !llSameGroup(toucherid))){
                        choices = llDeleteSubList(choices, nc, nc);
                        --nc;
                        --stopc;
                    }
                }
            }
        }
        id = llGenerateKey();
        llMessageLinked(LINK_SET, -900, (string)rcpt + "|" + prompt + "|" + (string)page +
         "|" + llDumpList2String(choices, "`") + "|" + llDumpList2String(utilitybuttons, "`"), id);
    }
    return id;
}    

AdminMenu(key toucher, string path, string prompt, list buttons){
    key id = Dialog(toucher, prompt+"\n"+path+"\n", buttons, ["^"], 0);
    integer index = llListFindList(dialogids, [toucher]);
    list addme = [id, toucher, path];
    if (~index){ 
        dialogids = llListReplaceList(dialogids, addme, index+-1, index+1);        
    }else{ 
        dialogids += addme;
    }
}

AdjustOffsetDirection(key id, vector direction) {
    vector delta = direction * currentOffsetDelta;
    llMessageLinked(LINK_SET, 208, (string)delta, id);
}

default{
    touch_start(integer total_number){
        toucherid = llDetectedKey(0);
        DoMenu_AccessCtrl(toucherid,"Main", "",0);
    }
    
    link_message(integer sender, integer num, string str, key id){
        integer index;
        integer n;
        integer stop;
        if (num == -901){ 
            index = llListFindList(dialogids, [id]); 
            if (~index){ 
                list params = llParseString2List(str, ["|"], []);  
                integer page = (integer)llList2String(params, 0);  
                string selection = llList2String(params, 1);  
                path = llList2String(dialogids, index + 2); 
                toucherid = llList2Key(dialogids, index + 1);
                if (selection == "^"){
                    
                    list pathparts = llParseString2List(path, [":"], []);
                    pathparts = llDeleteSubList(pathparts, -1, -1);
                    if (llList2String(pathparts, -1) == "admin"){
                       AdminMenu(toucherid, llDumpList2String(pathparts, ":"), "", adminbuttons);
                    }else if (llGetListLength(pathparts) <= 1){
                        DoMenu(toucherid, "Main", "", 0);
                    }else{
                        DoMenu(toucherid, llDumpList2String(pathparts, ":"), "", 0);
                    }
                }else if (selection == "admin"){
                    path += ":" + selection;
                    AdminMenu(toucherid, path, "", adminbuttons);
                }else if (selection == "ChangeSeat"){
                    
                    
                    
                    path = path + ":" + selection;
                    AdminMenu(toucherid, path,  "Where will you sit?", slotbuttons);
                }else if (selection == "offset"){
                    
                    path = path + ":" + selection;
                    AdminMenu(toucherid, path,   "Adjust by " + (string)currentOffsetDelta
                     + "m, or choose another distance.", offsetbuttons);
                }else if (selection == "Adjust"){
                    llMessageLinked(LINK_SET, 201, "", "");
                    AdminMenu(toucherid, path, "", adminbuttons);
                }else if (selection == "StopAdjust"){
                    llMessageLinked(LINK_SET, 205, "", "");
                    AdminMenu(toucherid, path, "", adminbuttons);
                }else if (selection == "PosDump"){
                    llMessageLinked(LINK_SET, 204, "", "");
                    AdminMenu(toucherid, path, "", adminbuttons);
                }else if (selection == "Unsit"){
                    
                    avs = SeatedAvs();
                    list buttons;
                    stop = llGetListLength(avs);
                    for (; n < stop; ++n){
                        buttons += [llGetSubString(llKey2Name((key)llList2String(avs, n)), 0, 20)];
                    }
                    if (buttons != []){
                        path += ":" + selection;
                        AdminMenu(toucherid, path, "Pick an avatar to unsit", buttons);
                    }else{
                        AdminMenu(toucherid, path, "", adminbuttons);
                    }
                }else if (selection == "Options"){
                    path += ":" + selection;
                    string optionsPrompt =  "Permit currently set to " + llList2String(Permissions, 0)
                     + "\nMenuOnSit currently set to "+ curmenuonsit + "\nsit2GetMenu currently set to " + menuReqSit 
                     + "\n2default currently set to "+ cur2default + "\nFacialEnable currently set to "+ Facials
                    + "\nUseRLVBaseRestrict currently set to "+ RLVenabled;
                    AdminMenu(toucherid, path, optionsPrompt, options);
                }else if (~llListFindList(menus, [path + ":" + selection])){
                    path = path + ":" + selection;
                    DoMenu(toucherid, path, "", 0);
                }else if (llList2String(llParseString2List(path, [":"], []), -1) == "ChangeSeat"){
                    if (llGetSubString(selection, 0,3)=="seat"){ 
                        n = (integer)llGetSubString(selection, 4,-1);
                        if (n >= 0) {
                            llMessageLinked(LINK_SET, 210, (string)n, toucherid);
                        }
                    }else{ 
                        n = llListFindList(slotbuttons, [selection])+1;
                        if (n >= 0) {
                            llMessageLinked(LINK_SET, 210, (string)n, toucherid);
                        }
                    }
                    list pathparts = llParseString2List(path, [":"], []);
                    pathparts = llDeleteSubList(pathparts, -1, -1);
                    path = llDumpList2String(pathparts, ":");
                    DoMenu(toucherid, path,  "", 0);
                }else if (llList2String(llParseString2List(path, [":"], []), -1) == "Unsit"){
                    stop = llGetListLength(avs);
                    for (; n < stop; n++){
                        key av = llList2Key(avs, n);
                        if (llGetSubString(llKey2Name(av), 0, 20) == selection){
                            if (~llListFindList(SeatedAvs(), [av])){ 
                                
                                llMessageLinked(LINK_SET, -222, (string)av, NULL_KEY);
                                integer avIndex = llListFindList(avs, [av]);
                                avs = llDeleteSubList(avs, index, index);
                                n = stop;
                            }
                        }
                    }
                    list buttons = [];
                    stop = llGetListLength(avs);
                    for (n = 0; n < stop; n++){
                        buttons += [llGetSubString(llKey2Name((key)llList2String(avs, n)), 0, 20)];
                    }
                    if (buttons != []){
                        AdminMenu(toucherid, path, "Pick an avatar to unsit", buttons);
                    }else{
                        list pathParts = llParseString2List(path, [":"], []);
                        pathParts = llDeleteSubList(pathParts, -1, -1);
                        AdminMenu(toucherid, llDumpList2String(pathParts, ":"), "", adminbuttons);
                    }
                }else if (llList2String(llParseString2List(path, [":"], []), -1) == "offset"){
                         if (selection ==   "forward") AdjustOffsetDirection(toucherid,  (vector)<1, 0, 0>);
                    else if (selection ==  "backward") AdjustOffsetDirection(toucherid,  (vector)<-1, 0, 0>);
                    else if (selection ==  "left") AdjustOffsetDirection(toucherid,  (vector)<0, 1, 0>);
                    else if (selection == "right") AdjustOffsetDirection(toucherid,  (vector)<0, -1, 0>);
                    else if (selection ==    "up") AdjustOffsetDirection(toucherid,  (vector)<0, 0, 1>);
                    else if (selection ==  "down") AdjustOffsetDirection(toucherid,  (vector)<0, 0, -1>);
                    else if (selection ==  "reset") llMessageLinked(LINK_SET, 209, (string)ZERO_VECTOR, toucherid);
                    else currentOffsetDelta = (float)selection;
                    AdminMenu(toucherid, path,  "Adjust by " + (string)currentOffsetDelta
                     + "m, or choose another distance.", offsetbuttons);
                }else if (selection == "sync"){
                    llMessageLinked(LINK_SET, 206, "", "");
                    DoMenu(toucherid, path, "", page);                    
                }else{
                    list pathlist = llDeleteSubList(llParseStringKeepNulls(path, [":"], []), 0, 0);
                    integer permission = llListFindList(menuPerm, [selection]);
                    defaultname = llDumpList2String(["DEFAULT"] + pathlist + [selection], ":");             
                    setname = llDumpList2String(["SET"] + pathlist + [selection], ":");
                    btnname = llDumpList2String(["BTN"] + pathlist + [selection], ":");
                    
                    
                    if (~permission){
                        string thisPerm;
                        if (llSubStringIndex(llList2String(menuPerm, permission+1), "public") == 0){
                             thisPerm = llGetSubString(llList2String(menuPerm, permission+1), 7, -1);
                             
                        }else{
                            thisPerm = llList2String(menuPerm, permission+1);
                        }
                        if (thisPerm != "public"){
                            defaultname += "{"+thisPerm+"}";
                            setname += "{"+thisPerm+"}";
                            btnname += "{"+thisPerm+"}";
                        }
                    }
                    string prefixFind = llList2String(menus_SEND, permission);
                    string menus_RANGE = llList2String(menus_SEND, permission+1);
                    start = llList2Integer(llCSV2List(menus_RANGE),0);
                    end =  llList2Integer(llCSV2List(menus_RANGE),1);


                    if(prefixFind == "DEFAULT"){
                        string defaultSEND = llList2CSV([".CONFIG",defaultname,start,end]);
                        llMessageLinked(LINK_SET, 200, defaultSEND, toucherid);
                    }else if(prefixFind == "SET"){
                        string setSEND = llList2CSV([".CONFIG",setname,start,end]);
                        llMessageLinked(LINK_SET, 200, setSEND, toucherid);
                    }else if (prefixFind == "BTN"){
                        string btnSEND = llList2CSV([".CONFIG",btnname,start,end]);
                        llMessageLinked(LINK_SET, 207, btnSEND, toucherid);
                    }
                    
                    if (llGetSubString(selection,-1,-1) == "-"){
                        llMessageLinked(LINK_SET, -802, path, toucherid);
                    }else{
                        DoMenu(toucherid, path, "", page);
                    }
                }
            }
        }else if (num == -902){
            index = llListFindList(dialogids, [id]);
            if (~index){
                dialogids = llDeleteSubList(dialogids, index, index + 2);
            }
            if (cur2default == "on" && llGetListLength(SeatedAvs()) < 1){
                llMessageLinked(LINK_SET, 200, defaultPoseSEND, NULL_KEY);
            }
        }else if (num==-240){
            list optionsToSet = llParseStringKeepNulls(str, ["~"], []);
            stop = llGetListLength(optionsToSet);
            for (; n<stop; ++n){
                list optionsItems = llParseString2List(llList2String(optionsToSet, n), ["="], []);
                string optionItem = llList2String(optionsItems, 0);
                string optionSetting = llList2String(optionsItems, 1);
                if (optionItem == "menuonsit") {curmenuonsit = optionSetting;}
                else if (optionItem == "permit") {Permissions = [llToUpper(optionSetting)];}
                else if (optionItem == "2default") {cur2default = optionSetting;}
                else if (optionItem == "sit2getmenu") {menuReqSit = optionSetting;}
                else if (optionItem == "facialExp"){
                    Facials = optionSetting;
                    llMessageLinked(LINK_SET, -241, Facials, NULL_KEY);
                }else if (optionItem == "rlvbaser"){
                    RLVenabled = optionSetting;
                    llMessageLinked(LINK_SET, -1812221819, "RLV=" + RLVenabled, NULL_KEY);
                }
            }
        }else if (num == -888){
            if (str == "admin"){
                path += ":" + str;
                AdminMenu(toucherid, path, "", adminbuttons);
            }else if (str == "ChangeSeat"){
                
                
                
                path = path + ":" + str;
                AdminMenu(toucherid, path,  "Where will you sit?", slotbuttons);
            }else if (str == "offset"){
                
                path = path + ":" + str;
                AdminMenu(toucherid, path,   "Adjust by " + (string)currentOffsetDelta
                 + "m, or choose another distance.", offsetbuttons);
            }else if (str == "sync"){
                llMessageLinked(LINK_SET, 206, "", "");
                DoMenu(toucherid, path, "", 0);
            }
        }else if (num == -800){
            toucherid = id;
            DoMenu(toucherid, str, "", 0);
        }else if (num == -801){
            toucherid = id;
            DoMenu_AccessCtrl(toucherid, "Main", "", 0);
        }else if(num == -238){

        }else if (num==35353){
            list slotsList = llParseStringKeepNulls(str, ["^"], []);
            slots = [];
            for (n=0; n<(llGetListLength(slotsList)/8); ++n){
                slots += [(key)llList2String(slotsList, n*8+4), llList2String(slotsList, n*8+7)];
            }
        }else if (num==35354){
            slotbuttons = llParseString2List(str, [","], []);
            string strideSeat;
            for (n = 0; n < llGetListLength(slotbuttons); ++n){ 
                index = llSubStringIndex(llList2String(slotbuttons, n), "§");
                if (!index){
                    strideSeat = llGetSubString(llList2String(slotbuttons, n), 1,-1);
                }else{
                    strideSeat = llGetSubString(llList2String(slotbuttons, n), 0, index+-1);
                }
                slotbuttons = llListReplaceList(slotbuttons, [strideSeat], n, n);
            }
        }else if (num == 34334){
            llSay(0,"Memory Used by " + llGetScriptName() + ": " + (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit()
                 + ",Leaving " + (string)llGetFreeMemory() + " memory free.");
        }else if(num == -135142119){
            menus = [];
            menus = llParseString2List(str,["##"],[]);
        }else if(num == -145142119){
            menus_SEND = [];
            menus_SEND = llParseString2List(str,["##"],[]);
        }else if(num == -155142119){
            menuPerm = [];
            menuPerm = llParseString2List(str,["##"],[]);
        }else if(num == -165142119){
            defaultPoseSEND = str;
        }
    }

    changed(integer change){
        if (change & CHANGED_INVENTORY){
            llResetScript();        
        }
        if (change & CHANGED_OWNER){
            llResetScript();
        }
        
        avs = SeatedAvs();
        if ((change & CHANGED_LINK) && (llGetListLength(avs)>0)){ 
            if (curmenuonsit == "on"){
                integer lastSeatedAV = llGetListLength(avs);  
                if (lastSeatedAV > curseatednumber){  
                
                    key id = llList2Key(avs,lastSeatedAV+-curseatednumber+-1);  
                    curseatednumber = lastSeatedAV;  
                    DoMenu_AccessCtrl(id, "Main", "", 0);  
                }
            }
        } 
        if ((change & CHANGED_LINK) && (cur2default == "on") && (!llGetListLength(avs))){ 
            llMessageLinked(LINK_SET, 200, defaultPoseSEND, NULL_KEY);
            curseatednumber=0;
        }
        curseatednumber=llGetListLength(avs);
    }
    on_rez(integer params){
        llResetScript();
    }
}

