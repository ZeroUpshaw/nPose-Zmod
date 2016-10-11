

key configNC;
integer line;
string defaultPose;
string defaultPoseSEND;
integer defaultSet;
integer defend;
list menus;
list menus_SEND;
integer menus_START;
integer start;
integer end;
list menuPerm = [];

integer loaded;
key NC_length_key;
integer NC_length;

string load_bar;
integer total_progress;



//#line 44 "E:\\Programme\\Firestorm-Release\\nPose menu read - Zmod v1.4.1"
default
{
    state_entry()
    {
        menus = [];
        load_bar = "";
        start = end = 0;
        menuPerm = [];
        defend = FALSE;
        defaultSet = FALSE;
        loaded = FALSE;
        line = -1;
        NC_length_key = llGetNumberOfNotecardLines(".CONFIG");
        
        llOwnerSay("Loading configurations...please wait...");
    }

    dataserver(key id, string data)
    {
        if(id == NC_length_key){
            NC_length = (integer)data;
            NC_length_key = NULL_KEY;
            
        }

        else if (data == EOF){
            if(!loaded){
                loaded = TRUE;
                string menus_RANGE = llList2CSV([menus_START,line]);
                menus_SEND += [menus_RANGE];
                llSetText("100%   [████████████████████]",<1,1,1>,100);
                llOwnerSay("Configurations loaded...");
                if(defaultSet ){

                    llMessageLinked(LINK_SET,200,defaultPoseSEND,NULL_KEY);
                    llMessageLinked(LINK_SET,-165142119,defaultPoseSEND,NULL_KEY);
                }
                llMessageLinked(LINK_SET,-135142119,llDumpList2String(menus,"##"),NULL_KEY);
                llMessageLinked(LINK_SET,-145142119,llDumpList2String(menus_SEND,"##"),NULL_KEY);
                llMessageLinked(LINK_SET,-155142119,llDumpList2String(menuPerm,"##"),NULL_KEY);
                menus = menus_SEND = menuPerm = [];
                defaultPoseSEND = "";
                state standby;
            }
        }else if(NC_length_key == NULL_KEY){
            
            string prefixFind = llList2String(llParseString2List(data, [":"], []), 0);
            if (~llListFindList(["DEFAULT", "SET", "BTN"], [prefixFind])){
                if(llGetListLength(menus) > 0){
                    
                    string menus_RANGE = llList2CSV([menus_START,line]);
                    menus_SEND += [menus_RANGE];
                    if(defaultSet && !defend){
                        defend = line;
                        defaultPoseSEND = llList2CSV([defaultPoseSEND,defend]);
                    }
                }
                integer permsIndex1 = llSubStringIndex(data,"{");
                integer permsIndex2 = llSubStringIndex(data,"}");
                string menuPerms = "";
                if (~permsIndex1){ 
                    menuPerms = llToLower(llGetSubString(data, permsIndex1+1, permsIndex2+-1));
                    data = llDeleteSubString(data, permsIndex1, permsIndex2);

                    
                    if (!~llSubStringIndex(menuPerms, "owner") && !~llSubStringIndex(menuPerms, "group")){
                        if (llSubStringIndex(menuPerms, "~") != 0){
                            menuPerms = "public~" + menuPerms;
                        }else{
                            menuPerms = "public" + menuPerms;
                        }
                    }
                }else{
                    
                    menuPerms = "public";
                }
                
                
                list pathParts = llParseStringKeepNulls(data, [":"], []);
                menuPerm += [llList2String(pathParts, -1), menuPerms];
                
                menus_SEND += prefixFind;
                
                menus_START = line+1;
                string prefix = llList2String(pathParts, 0);
                if (!defaultSet && ((prefix == "SET") | (prefix == "DEFAULT"))){
                    defaultPose = data;
                    integer defstart = line+1;
                    defaultPoseSEND = llList2CSV([".CONFIG",defaultPose,defstart]);
                    defaultSet = TRUE;
                }
                if (~llListFindList(["SET", "DEFAULT", "BTN"], [prefix])){ 
                    pathParts = llDeleteSubList(pathParts, 0, 0);            
                    while(llGetListLength(pathParts)){
                        string last = llList2String(pathParts, -1);
                        string parentpath = llDumpList2String(["Main"] + llDeleteSubList(pathParts, -1, -1), ":");
                        integer index = llListFindList(menus, [parentpath]);
                        if (~index && !(index & 1)){
                            list children = llParseStringKeepNulls(llList2String(menus, index + 1), ["|"], []);
                            if (!~llListFindList(children, [last])){
                                children += [last];
                                menus = llListReplaceList((menus = []) + menus, [llDumpList2String(children, "|")], index + 1, index + 1);
                            }
                        }else{
                            menus += [parentpath, last];
                        }
                        pathParts = llDeleteSubList(pathParts, -1, -1);
                    }
                }
            }
        }
        if(data != EOF)
        {
            integer progress = llRound(line * 100 / NC_length);
            if( progress > total_progress){
                total_progress += 1;
                if( progress % 5 == 0 ){
                    load_bar += "█";
                }
                llSetText((string)progress + "%   [" + llGetSubString(load_bar + "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░",0,19) + "]",<1,1,1>,100);
            }
            ++line;
            configNC = llGetNotecardLine(".CONFIG", line);
        }
    }
    changed(integer change){
        if (change & CHANGED_INVENTORY){
            llResetScript();        
        }
        if (change & CHANGED_OWNER){
            llResetScript();
        }
    }
    on_rez(integer params){
        llResetScript();
    }
}

state standby{
    state_entry(){
        llSleep(3);
        llSetText("",<1,1,1>,100);
    }
    link_message(integer sender, integer num, string str, key id){
        if (num == 34334){
            llSay(0,"Memory Used by " + llGetScriptName() + ": " + (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit()
                 + ",Leaving " + (string)llGetFreeMemory() + " memory free.");
        }
    }
    changed(integer change){
        if (change & CHANGED_INVENTORY){
            llResetScript();        
        }
        if (change & CHANGED_OWNER){
            llResetScript();
        }
    }
    on_rez(integer params){
        llResetScript();
    }
}
    

