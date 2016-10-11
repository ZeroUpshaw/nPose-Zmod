

key ownerinit;

integer slotMax;
//#line 16 "E:\\Programme\\Firestorm-Release\\nPose Core - Zmod v1.4"
list slots;
integer curPrimCount;
integer lastPrimCount;
integer lastStrideCount = 12;

integer rezadjusters;
integer listener;
integer line;
key clicker;
integer chatchannel;

key cardid;
string card;


integer x;
integer n;
integer start;
integer end;
integer stop;

//#line 43 "E:\\Programme\\Firestorm-Release\\nPose Core - Zmod v1.4"
key hudId;

//#line 51 "E:\\Programme\\Firestorm-Release\\nPose Core - Zmod v1.4"
integer explicitFlag;
list idList;
integer seatNum;

integer allow_SATMSG;

list SeatedAvs(){
    list avs = [];
    n = llGetNumberOfPrims();
    for (; n >= 0; --n){
        key id = llGetLinkKey(n);
        if (llGetAgentSize(id) != ZERO_VECTOR){
            avs = [id] + avs;
        }
    }
    return avs;
}


integer FindEmptySlot() {
    for (n=0; n < slotMax; ++n) {
        if (llList2String(slots, n*8+4) == ""){
            return n;
        }
    }
    return -1;
}

assignSlots(){
    list avqueue = SeatedAvs();
    stop = llGetListLength(avqueue);
    if (slotMax < lastStrideCount){
        
        for (x=slotMax; x<=lastStrideCount; ++x){
            if (llList2Key(slots, x*8+4) != ""){
                integer emptySlot = FindEmptySlot();
                if ((emptySlot >=0) && (emptySlot < slotMax)){
                    
                    slots = llListReplaceList(slots, [llList2Key(slots, x*8+4)], emptySlot*8+4, emptySlot*8+4);
                }
            }
        }
        
        slots = llDeleteSubList(slots, (slotMax)*8, -1);
        
        for (n=0; n<stop; ++n){
            if (!~llListFindList(slots, [llList2Key(avqueue, n)])){
                llMessageLinked(LINK_SET, -222, llList2String(avqueue, n), NULL_KEY);
            }
        }
    }
    
    if (curPrimCount > lastPrimCount){
        
        
        
        
        key thisKey=llList2Key(avqueue,stop-1);
        
        integer primcount = llGetObjectPrimCount(llGetKey());
        integer slotNum=-1;
        for (n= 1; n <= primcount; ++n){
            integer x = (integer)llGetSubString(llGetLinkName(n), 4, -1);
            if ((x>0) && (x<=slotMax)){
                if (llAvatarOnLinkSitTarget(n) == thisKey){
                    if (llList2String(slots, (x-1)*8+4) == ""){
                        slotNum = (integer)llGetLinkName(n);
                    }
                }
            }
        }
        integer nn;
        for (nn= 1; nn <= primcount; ++nn){
            if (~slotNum  && !~llListFindList(slots, [thisKey])){
                
                if (slotNum <= slotMax){
                    slots = llListReplaceList(slots, [thisKey], (slotNum-1)*8+4, (slotNum-1)*8+4);
                }else{
                    
                    integer y = FindEmptySlot();
                    if (~y){
                        
                        slots = llListReplaceList(slots, [thisKey], (y)*8+4, (y)*8+4);
                    }else if (~llListFindList(SeatedAvs(), [thisKey])){
                        
                        llMessageLinked(LINK_SET, -222, (string)thisKey, NULL_KEY);
                    }
                }
            }
            if (!~llListFindList(slots, [thisKey])){
                integer y = FindEmptySlot();
                if (~y){
                    
                    slots = llListReplaceList(slots, [thisKey], (y)*8+4, (y)*8+4);
                }else if (~llListFindList(SeatedAvs(), [thisKey])){
                    
                    llMessageLinked(LINK_SET, -222, (string)thisKey, NULL_KEY);
                }
            }
            
        }
    }else if (curPrimCount < lastPrimCount){
        
        for (x=0; x < slotMax; ++x) {
            
            if (!~llListFindList(avqueue, [llList2Key(slots, x*8+4)])) {
                
                slots = llListReplaceList(slots, [""], x*8+4, x*8+4);
            }
        }
    }
    lastPrimCount = curPrimCount;
    lastStrideCount = slotMax;
    llMessageLinked(LINK_SET, 35353, llDumpList2String(slots, "^"), NULL_KEY);
}

SwapTwoSlots(integer currentseatnum, integer newseatnum) {
    if (newseatnum <= slotMax){
        integer slotNum;
        integer OldSlot;
        integer NewSlot;
        for (; slotNum < slotMax; ++slotNum){
            integer z = llSubStringIndex(llList2String(slots, slotNum*8+7), "§");
            string strideSeat = llGetSubString(llList2String(slots, slotNum * 8+7), z+1,-1);
            if (strideSeat == "seat" + (string)(currentseatnum)){
                OldSlot= slotNum;
            }
            if (strideSeat == "seat" + (string)(newseatnum)){
                NewSlot= slotNum;
            }
        }

        list curslot = llList2List(slots, NewSlot*8, NewSlot*8+3)
                + [llList2Key(slots, OldSlot*8+4)]
                + llList2List(slots, NewSlot*8+5, NewSlot*8+7);
        slots = llListReplaceList(slots, llList2List(slots, OldSlot*8, OldSlot*8+3)
                + [llList2Key(slots, NewSlot*8+4)]
                + llList2List(slots, OldSlot*8+5, OldSlot*8+7), OldSlot*8, (OldSlot+1)*8-1);

        slots = llListReplaceList(slots, curslot, NewSlot*8, (NewSlot+1)*8-1);
    }else{
        llRegionSayTo(llList2Key(slots, llListFindList(slots, ["seat"+(string)currentseatnum])-4),
             0, "Seat "+(string)newseatnum+" is not available for this pose set");
    }
    llMessageLinked(LINK_SET, 35353, llDumpList2String(slots, "^"), NULL_KEY);
}



SwapAvatarInto(key avatar, string newseat) { 

    integer slotIndex = llListFindList(slots, [avatar]);
    
    integer z = llSubStringIndex(llList2String(slots, slotIndex + 3), "§");
    
    string strideSeat = llGetSubString(llList2String(slots, slotIndex + 3), z+1,-1);
    integer oldseat = (integer)llGetSubString(strideSeat, 4,-1);
    if (oldseat <= 0) {
        llWhisper(0, "avatar is not assigned a slot: " + (string)avatar);
    }else{ 
            SwapTwoSlots(oldseat, (integer)newseat); 
    }
}


ProcessLine(string line, key av){
    line = llStringTrim(line, STRING_TRIM);
    list params = llParseStringKeepNulls(line, ["|"], []);
    string action = llList2String(params, 0);
    if (action == "ANIM"){
        if (slotMax<lastStrideCount){
            slots = llListReplaceList(slots, [llList2String(params, 1), (vector)llList2String(params, 2),
                llEuler2Rot((vector)llList2String(params, 3) * DEG_TO_RAD), llList2String(params, 4), llList2Key(slots, (slotMax)*8+4),
                 "", "",llGetSubString(llList2String(params, 5), 0, 12) + "§" + "seat"+(string)(slotMax+1)], (slotMax)*8, (slotMax)*8+7);
        }else{
            slots += [llList2String(params, 1), (vector)llList2String(params, 2),
                llEuler2Rot((vector)llList2String(params, 3) * DEG_TO_RAD), llList2String(params, 4), "", "", "",
                llGetSubString(llList2String(params, 5), 0, 12) + "§" + "seat"+(string)(slotMax+1)]; 
        }
        allow_SATMSG = TRUE;
        slotMax++;
        seatNum = slotMax-1;
    }else if (action == "XANIM"){
        

        allow_SATMSG = FALSE;
        integer changeMulti = llSubStringIndex(llList2String(params,6),"~");
        seatNum = (integer)llList2String(params,6)-1;
        if(changeMulti < 0){
            key findClicker =  llList2Key(slots, (seatNum)*8+4);
            if(findClicker == clicker){
                slots = llListReplaceList(slots, [llList2String(params, 1), (vector)llList2String(params, 2), llEuler2Rot((vector)llList2String(params, 3) * DEG_TO_RAD), llList2String(params, 4)], (seatNum*8), (seatNum*8)+3);
                slots = llListReplaceList(slots,["","",llGetSubString(llList2String(params, 5), 0, 12) + "§seat" + (string)(seatNum+1)], (seatNum*8)+5, (seatNum*8)+7);
                allow_SATMSG = TRUE;
            }
        }else{
            slots = llListReplaceList(slots, [llList2String(params, 1), (vector)llList2String(params, 2), llEuler2Rot((vector)llList2String(params, 3) * DEG_TO_RAD), llList2String(params, 4)], (seatNum*8), (seatNum*8)+3);
            slots = llListReplaceList(slots,["","",llGetSubString(llList2String(params, 5), 0, 12) + "§seat" + (string)(seatNum+1)], (seatNum*8)+5, (seatNum*8)+7);
            allow_SATMSG = TRUE;
        }
        slotMax = lastStrideCount;
    }else if (action == "PROP") {
        string obj = llList2String(params, 1);
        if(llGetInventoryType(obj) == INVENTORY_OBJECT) {
            list strParm2 = llParseString2List(llList2String(params, 2), ["="], []);
            if(llList2String(strParm2, 1) == "die") {
                llRegionSay(chatchannel,llList2String(strParm2,0)+"=die");
            }
            else {
                explicitFlag = 0;
                if(llList2String(params, 4) == "explicit") {
                    explicitFlag = 1;
                }
                
                if(llList2String(params, 5) == "quiet") {
                    explicitFlag += 2;
                }
                vector vDelta = (vector)llList2String(params, 2);
                vector pos = llGetPos() + (vDelta * llGetRot());
                rotation rot = llEuler2Rot((vector)llList2String(params, 3) * DEG_TO_RAD) * llGetRot();
                integer sendToPropChannel = (chatchannel << 8);
                sendToPropChannel = sendToPropChannel | explicitFlag;
                if(llVecMag(vDelta) > 9.9) {
                    
                    llRezAtRoot(obj, llGetPos(), ZERO_VECTOR, rot, sendToPropChannel);
                    llSleep(1.0);
                    llRegionSay(chatchannel, llDumpList2String(["MOVEPROP", obj, (string)pos], "|"));
                }
                else {
                    llRezAtRoot(obj, llGetPos() + ((vector)llList2String(params, 2) * llGetRot()),
                     ZERO_VECTOR, rot, sendToPropChannel);
                }
            }
        }
    }
    else if(action=="PAUSE") {
        llSleep((float)llList2String(params, 1));
    }else if (action == "LINKMSG"){
        integer num = (integer)llList2String(params, 1);
        string line1 = llDumpList2String(llParseStringKeepNulls(line, ["%AVKEY%"], []), av);
        list params1 = llParseString2List(line1, ["|"], []);
        key lmid;
        if ((key)llList2String(params1, 3) != ""){
            lmid = (key)llList2String(params1, 3);
        }else{
            lmid = (key)llList2String(slots, (slotMax-1)*8+4);
        }
        string str = llList2String(params1, 2);
        llMessageLinked(LINK_SET, num, str, lmid);
            llSleep(1.0);
            llRegionSay(chatchannel, llDumpList2String(["LINKMSG",num,str,lmid], "|"));
    }else if (action == "SATMSG"){
        if(allow_SATMSG){
            integer index = (seatNum) * 8 + 5;
            slots = llListReplaceList(slots, [llDumpList2String([llList2String(slots,index),
            llDumpList2String(llDeleteSubList(params, 0, 0), "|")], "§")], index, index);
        }
    }else if (action == "NOTSATMSG"){
        if(allow_SATMSG){
            integer index = (seatNum) * 8 + 6;
            slots = llListReplaceList(slots, [llDumpList2String([llList2String(slots,index),
            llDumpList2String(llDeleteSubList(params, 0, 0), "|")], "§")], index, index);
        }
    }
}

default{
    state_entry(){
        curPrimCount = llGetNumberOfPrims();
        for (n=0; n<=curPrimCount; ++n){
           llLinkSitTarget(n,<0.0,0.0,0.5>,ZERO_ROTATION);
        }
        chatchannel = (integer)("0x7F" + llGetSubString((string)llGetKey(), 0, 5));
        llMessageLinked(LINK_SET, 1, (string)chatchannel, NULL_KEY);  
        ownerinit = llGetOwner();
        curPrimCount = llGetNumberOfPrims();
        lastPrimCount = curPrimCount;
        listener = llListen(chatchannel, "", "", "");
    }
    link_message(integer sender, integer num, string str, key id){
        if (num == 999999){
            llMessageLinked(LINK_SET, 1, (string)chatchannel, NULL_KEY); 

        }
        if (num == 200){
            lastStrideCount = slotMax;
            slotMax = 0;
            llRegionSay(chatchannel, "die");
            llRegionSay(chatchannel, "adjuster_die");
            
            list read_this = llCSV2List(str);
            card = llList2String(read_this,0);
            start = llList2Integer(read_this,2);
            end = llList2Integer(read_this,3);
            line = start;
            cardid = llGetInventoryKey(card);
            idList += ["dataid", llGetNotecardLine(card, start)];
            clicker = id;
        }else if(num == 207){
            list read_this = llCSV2List(str);
            card = llList2String(read_this,0);
            start = llList2Integer(read_this,2);
            end = llList2Integer(read_this,3);
            line = start;
            cardid = llGetInventoryKey(card);
            idList += ["btnid", llGetNotecardLine(card, start)];
            clicker = id;
        }else if (num == 201){ 

            rezadjusters = TRUE;
        }else if (num == 205){ 

            rezadjusters = FALSE;
        }else if(num == 300){
            list msg = llParseString2List(str, ["|"], []);
            if(id != NULL_KEY) msg = llListReplaceList((msg = []) + msg, [id], 2, 2);
            llRegionSay(chatchannel,llDumpList2String(["LINKMSG",(string)llList2String(msg, 0),
                llList2String(msg, 1), (string)llList2String(msg,2)], "|"));
        }else if (num == 202){
            if (llGetListLength(slots)/8 >= 2){
                list seats2Swap = llParseString2List(str, [","],[]);
                SwapTwoSlots((integer)llList2String(seats2Swap, 0), (integer)llList2String(seats2Swap, 1));
            }
        }else if (num == 210) {
            SwapAvatarInto(id, str);
        }else if (num == (35353 + 2000000)){
            
            list tempList = llParseStringKeepNulls(str, ["^"], []);
            integer listStop = llGetListLength(tempList)/8;
            integer slotNum;
            for (; slotNum < listStop; ++slotNum){
                slots = llListReplaceList(slots, [llList2String(tempList, slotNum*8), (vector)llList2String(tempList, slotNum*8+1),
                 (rotation)llList2String(tempList, slotNum*8+2), llList2String(tempList, slotNum*8+3),
                 (key)llList2String(tempList, slotNum*8+4), llList2String(tempList, slotNum*8+5), 
                 llList2String(tempList, slotNum*8+6), llList2String(tempList, slotNum*8+7)], slotNum*8, slotNum*8 + 7);
            }
        }else if (num == -999){
            if (llGetInventoryType("npose admin hud")!=INVENTORY_NONE && str == "RezHud"){
                llRezObject("npose admin hud", llGetPos() + <0,0,1>, ZERO_VECTOR, llGetRot(), chatchannel);
            }else if (num == -999 && str == "RemoveHud"){
                llRegionSayTo(hudId, chatchannel, "/die");
            }
        }else if (num == 34334){
            llSay(0,"Memory Used by " + llGetScriptName() + ": " + (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit() + ", Leaving " + (string)llGetFreeMemory() + " memory free.");

        llSay(0, "running script time for all scripts in this nPose object are consuming " 
         + (string)(llList2Float(llGetObjectDetails(llGetKey(), ([OBJECT_SCRIPT_TIME])), 0)*1000.0) + " ms of cpu time");
        }
    }

    object_rez(key id){
        if(llKey2Name(id) == "npose admin hud"){
            hudId = id;
            llSleep(2.0);
            llRegionSayTo(hudId, chatchannel, "parent|"+(string)llGetKey());
        }
    }

    listen(integer channel, string name, key id, string message){
        list temp = llParseString2List(message, ["|"], []);
        if (name == "Adjuster"){
                llMessageLinked(LINK_SET, 3, message, id);
        }else if (llGetListLength(temp) >= 2 || llGetSubString(message,0,4) == "ping" || llGetSubString(message,0,8) == "PROPRELAY"){
            if (llGetOwnerKey(id) == ownerinit){
                if (message == "ping"){
                    llRegionSay(chatchannel, "pong|"+(string)explicitFlag + "|" + (string)llGetPos());
                }else if (llGetSubString(message,0,8) == "PROPRELAY"){
                    list msg = llParseString2List(message, ["|"], []);
                    llMessageLinked(LINK_SET,llList2Integer(msg,1),llList2String(msg,2),llList2Key(msg,3));
                }else if (name == "pos_adjuster_hud"){
                }else{
                    list params = llParseString2List(message, ["|"], []);
                    vector newpos = (vector)llList2String(params, 0) - llGetPos();
                    newpos = newpos / llGetRot();
                    rotation newrot = (rotation)llList2String(params, 1) / llGetRot();
                    llRegionSayTo(ownerinit, 0, "\nPROP|" + name + "|" + (string)newpos + "|" + (string)(llRot2Euler(newrot) * RAD_TO_DEG)
                     + "|" + llList2String(params, 2));
                    llMessageLinked(LINK_SET, 34333, "PROP|" + name + "|" + (string)newpos + "|" +
                        (string)(llRot2Euler(newrot) * RAD_TO_DEG), NULL_KEY); 

                }
            }
        }else if(name == llKey2Name(hudId)){
            
            if (message == "adjust"){
                llMessageLinked(LINK_SET, 201, "", "");
            }else if (message == "stopadjust"){
                llMessageLinked(LINK_SET, 205, "", "");
            }else if (message == "posdump"){
                llMessageLinked(LINK_SET, 204, "", "");
            }else if (message == "hudsync"){
                llMessageLinked(LINK_SET, 206, "", "");
            }
        }
    }

    dataserver(key id, string data){
        integer index = llListFindList(idList, [id]);
        if (~index && llList2String(idList, index-1) == "dataid"){
            if (line == end){
                assignSlots();
                if (rezadjusters){

                    llMessageLinked(LINK_SET, 2, "RezAdjuster", "");    
                }
                idList = llDeleteSubList(idList, (index-1), index);
            }else{
                ProcessLine(data, clicker);
                line++;
                idList = llDeleteSubList(idList, (index-1), index);
                idList += ["dataid", llGetNotecardLine(card, line)];
            }
        }else if (~index && llList2String(idList, index-1) == "btnid"){
            if (line != end){
                if ((llSubStringIndex(data, "ANIM") != 0) && (llSubStringIndex(data, "XANIM") !=0) && (llSubStringIndex(data, "SATMSG") != 0)
                 && (llSubStringIndex(data, "NOTSATMSG") != 0)){
                    ProcessLine(data, clicker);
                }
                line++;
                cardid = llGetInventoryKey(card);
                idList = llDeleteSubList(idList, (index-1), index);
                idList += ["btnid", llGetNotecardLine(card, line)];
            }else{
                idList = llDeleteSubList(idList, (index-1), index);
            }
        }
    }

    changed(integer change){
        if (change & CHANGED_LINK){
            llMessageLinked(LINK_SET, 1, (string)chatchannel, NULL_KEY); 
            lastPrimCount = curPrimCount;
            curPrimCount = llGetNumberOfPrims();
            assignSlots();
        }
        
        if (change & CHANGED_REGION){
            llMessageLinked(LINK_SET, 35353, llDumpList2String(slots, "^"), NULL_KEY);
        }
        if (change & CHANGED_OWNER ){
            ownerinit = llGetOwner();
        }
    }
    
    on_rez(integer param){
        llResetScript();
    }
}

