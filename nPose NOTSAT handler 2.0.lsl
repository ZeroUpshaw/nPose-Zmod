


list slots;
integer chatchannel;
integer SEAT_UPDATE = 35353;
integer STRIDE = 8;
integer MEMORY_USAGE = 34334;
integer SEND_CHATCHANNEL = 1;
integer REQUEST_CHATCHANNEL = 999999;

string str_replace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

processMessages(list message, integer index) {
    integer ndx;
    string nsm = llList2String(message, index);
    nsm = str_replace(nsm, "%AVKEY%", (key)llList2String(message, 4));
    list smsgs=llParseString2List(nsm, ["§"], []);
    integer msgcnt = llGetListLength(smsgs);
    for(ndx = 0; ndx < msgcnt; ndx++) {
        list parts = llParseString2List(llList2String(smsgs,ndx), ["|"], []);
        llMessageLinked(LINK_SET, (integer)llList2String(parts, 0), llList2String(parts, 1),
            (key)llList2String(message, 4));
        if (chatchannel != 0) {
            llRegionSay(chatchannel,llDumpList2String(["LINKMSG",(string)llList2String(parts, 0),
                llList2String(parts, 1), llList2String(message, 4)], "|"));
        }
    }
}


integer ListCompare(list a, list b) {
    integer aL = a != [];
    if(aL != (b != [])) return 0;
    if((aL == 0) && (b == [])) return 1;
 
    return !llListFindList((a = []) + a, (b = []) + b);
}

default {
    state_entry() {
        llMessageLinked(LINK_SET, REQUEST_CHATCHANNEL, "", "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == SEND_CHATCHANNEL) {  
            chatchannel = (integer)str;
        }
        if(num == SEAT_UPDATE) {
            list oldSlots = slots;
            slots = llParseStringKeepNulls(str, ["^"], []);
            list oldstride;
            list currentstride;
        
            integer n;
            integer stop = llGetListLength(oldSlots)/STRIDE;
            for(n = 0; n < stop; ++n) {
                oldstride = llList2List(oldSlots, n*STRIDE, n*STRIDE+6);

                
                if((llList2String(oldstride, 6) != "" && llList2String(oldstride, 4) != "")) {
                    integer curStrideIndex = llListFindList(slots, [llList2String(oldstride, 4)])-4;
                    currentstride = llList2List(slots, curStrideIndex, curStrideIndex+6);
                    
                    
                    integer listsEqual = ListCompare(llList2List(oldstride, 0, 4), llList2List(currentstride, 0, 4));
                    if(listsEqual == FALSE) {
                        processMessages(oldstride, 6);
                    }
                }
            }
            stop = llGetListLength(slots)/STRIDE;
            for(n = 0; n < stop; ++n) {
                
                oldstride = llList2List(oldSlots, n*STRIDE, n*STRIDE+5);
                currentstride = llList2List(slots, n*STRIDE, n*STRIDE+5);
                
                
                integer listsEqual = ListCompare(llList2List(oldstride, 0, 4), llList2List(currentstride, 0, 4));
                
                if(llList2String(currentstride, 5) != "") {
                    
                    
                    
                    if((llList2String(currentstride, 4) == llList2String(oldstride, 4) && llList2String(currentstride, 4) != ""
                      && listsEqual == FALSE) || (llList2String(currentstride, 4) != llList2String(oldstride, 4) 
                      && llList2String(currentstride, 4) != "")) {
                    
            
                        
                        processMessages(currentstride, 5);
                    }
                }
            }
        }
        else if(num == MEMORY_USAGE) {
            llSay(0,"Memory Used by " + llGetScriptName() + ": " + (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit()
             + ", Leaving " + (string)llGetFreeMemory() + " memory free.");
        }
    }

    on_rez(integer params) {
        llResetScript();
    }
}

