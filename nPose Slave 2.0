integer chatchannel;
string currentanim;
list lastanim;
list faceanims;
integer doingFaceAnim = 0;
integer gotFaceAnim = 0;
integer SYNC = 206;
integer doSync = 0;
integer ADJUSTOFFSET = 208;
integer SETOFFSET = 209;
integer primcount;
integer newprimcount;
string lastAnimRunning;
integer seatcount;
integer nextAvatarOffset;
integer avatarOffsetsLength = 20;
list avatarOffsets;
integer stride = 8;

integer SEAT_UPDATE = 35353;
integer MENU_USAGE = 34334;
list adjusters = [];
integer LAYER_POSE = -218;
list animsList; 
list faceTimes = [];
list slots;
key thisAV;
integer stop;
integer UNSIT = -222;
integer REQUEST_CHATCHANNEL = 999999;
integer SEND_CHATCHANNEL = 1;
integer REZ_ADJUSTERS = 2;
integer ADJUSTER_REPORT = 3;
integer ADJUST = 201;
integer DUMP = 204;
integer STOPADJUST = 205;
integer FACIALS_FLAG = -241;
string facialEnable = "on";


vector appliedOffsets(integer n) {
    string slot = llList2String(slots, n*stride + 4);
    integer avinoffsets = llListFindList(avatarOffsets, [(key)slot]);
    rotation rot = llList2Rot(slots, n*stride+2); 
    vector pos = (vector)llList2String(slots, n*stride+1); 
    if(avinoffsets != -1) {
        vector offset = llList2Vector(avatarOffsets, avinoffsets+1);
        pos += offset * rot; 
    }
    return pos; 
}

MoveLinkedAv(integer linknum, vector avpos, rotation avrot) {
    key user = llGetLinkKey(linknum);
    if(user) {  
        vector size = llGetAgentSize(user);
        if(size) {  
            
            rotation localrot = ZERO_ROTATION;
            vector localpos = ZERO_VECTOR;
            if(llGetLinkNumber() > 1) {  
                localrot = llGetLocalRot();
                localpos = llGetLocalPos();
            }
            avpos.z += 0.4;
            llSetLinkPrimitiveParamsFast(linknum, [PRIM_POSITION, ((avpos - (llRot2Up(avrot) * size.z * 0.02638)) * localrot) + localpos, PRIM_ROTATION, avrot * localrot / llGetRootRotation()]);
        }
    }    
}



doSeats(integer slotNum, key avKey) {
    llSetTimerEvent(0.0);
    if(doSync !=1) {
        vector vpos = appliedOffsets(slotNum);
        MoveLinkedAv(AvLinkNum(avKey), vpos, llList2Rot(slots, ((slotNum)*8)+2)); 
    }
    if(avKey != "") {
        doingFaceAnim = 0;
        stop = llGetListLength(slots)/8;
        llRequestPermissions(avKey, PERMISSION_TRIGGER_ANIMATION);
    }
}

SetAvatarOffset(key avatar, vector offset) { 
    integer avatarOffsetsIndex = llListFindList(avatarOffsets, [avatar]); 
    if(offset == ZERO_VECTOR && avatarOffsetsIndex >= 0) {
        avatarOffsets = llDeleteSubList(avatarOffsets, avatarOffsetsIndex, avatarOffsetsIndex+1);
        return;
    }
    if(avatarOffsetsIndex < 0) { 
        avatarOffsetsIndex = nextAvatarOffset; 
        nextAvatarOffset = (nextAvatarOffset + 2) % avatarOffsetsLength;
    }
    else { 
            offset = llList2Vector(avatarOffsets, avatarOffsetsIndex+1) + offset;
    }
    avatarOffsets = llListReplaceList(avatarOffsets, [avatar, offset], avatarOffsetsIndex, avatarOffsetsIndex+1);
}

list SeatedAvs() {
    list avs = [];
    integer n = llGetNumberOfPrims();
    for(; n >= llGetObjectPrimCount(llGetKey()); --n) {
        key id = llGetLinkKey(n);
        if(llGetAgentSize(id) != ZERO_VECTOR) {
            avs = [id] + avs;
        }
    }
    return avs;
}


RezNextAdjuster(integer slotnum) {
    if(llGetInventoryType("Adjuster") == INVENTORY_OBJECT) {
        integer index = slotnum * stride;
        vector pos = llGetPos() + llList2Vector(slots, index + 1) * llGetRot();
        rotation rot = llList2Rot(slots, index + 2) * llGetRot();
        llRezObject("Adjuster", pos, ZERO_VECTOR, rot, chatchannel);
    }
    else {
        llSay(chatchannel, "adjuster_die");
        adjusters = [];
        llRegionSayTo(llGetOwner(), 0, "Seat Adjustment disabled.  No Adjuster object found in " + llGetObjectName()+ ".");
    }
}

integer AvLinkNum(key av) {
    integer linkcount = llGetNumberOfPrims();
    while(av != llGetLinkKey(linkcount)) {
        if(llGetAgentSize(llGetLinkKey(linkcount)) == ZERO_VECTOR) {
            return -1;
        }
        linkcount--;
    }
    return linkcount;
}

default {
    state_entry() {
        llMessageLinked(LINK_SET, REQUEST_CHATCHANNEL, "", "");
        primcount = llGetNumberOfPrims();
        newprimcount = primcount;
    }
 
    link_message(integer sender, integer num, string str, key id) {
        if(num == SEND_CHATCHANNEL) {  
            chatchannel = (integer)str;
        }
        if(num == LAYER_POSE) {
            key av;
            list tempList = llParseString2List(str, ["/"], []);
            if(llListFindList(SeatedAvs(), [(key)llList2String(tempList, 0)]) != -1) {
                av = (key)llList2String(tempList, 0);
            }
            if(av) {
                llRequestPermissions(av, PERMISSION_TRIGGER_ANIMATION);
                av = llGetPermissionsKey();
                list tempList1 = llParseString2List(llList2String(tempList, 1), ["~"], []);
                integer instruction;
                integer layerStop = llGetListLength(tempList1);
                for(instruction = 0; instruction < layerStop; ++instruction) {
                    tempList = llParseString2List(llList2String(tempList1, instruction), [","],[]);
                    if(llList2String(tempList,0)=="stopAll") {
                        animsList = [av, llList2String(tempList, 0), llList2String(tempList, 1)] + animsList;
                    }
                    else {
                        integer index = llListFindList(animsList, [llList2String(tempList, 1)]);
                        if(index>=1 & (key)llList2String(animsList, index - 2) == av) {
                            animsList = llDeleteSubList(animsList, index-2, index);
                        }
                        animsList += [av, llList2String(tempList, 0), llList2String(tempList, 1)];
                    }
                }
                integer n;
                layerStop = llGetListLength(animsList)/3;
                for(n=0; n<layerStop; ++n) {
                    if((key)llList2String(animsList, n*3) == av) {
                       if(llList2String(animsList, n*3+1) == "stopAll") {
                           animsList = llDeleteSubList(animsList, n*3, n*3+2);
                           n-=1;
                           layerStop-=1;
                            integer x;
                            integer animsStop = llGetListLength(animsList)/3;
                            if(animsStop > 0) {
                                for(x = 0; x<animsStop; ++x) {
                                    if ((key)llList2String(animsList, x*3) == av && llList2String(animsList, x*3+2) != ""){
                                        llStopAnimation(llList2String(animsList, x*3+2));
                                        animsList = llDeleteSubList(animsList, x*3, x*3+2);
                                        x-=1;
                                        animsStop-=1;
                                    }
                                }
                            }
                        }
                        else if(llList2String(animsList, n*3+1) == "start" && llList2String(animsList, n*3) == av
                         && llList2String(animsList, n*3+2) != "") {
                            if(llGetPermissions() & PERMISSION_TRIGGER_ANIMATION) {
                                llStartAnimation(llList2String(animsList, n*3+2));
                            }
                        }
                        else if(llList2String(animsList, n*3+1) == "stop") {
                            if (llGetPermissions() & PERMISSION_TRIGGER_ANIMATION){
                                llStopAnimation(llList2String(animsList, n*3+2));
                                animsList = llDeleteSubList(animsList, n*3, n*3+2);
                                n-=1;
                                layerStop-=1;
                            }
                        }
                    }
                }
            }

        }
        else if(num == ADJUSTOFFSET) {
            SetAvatarOffset(id, (vector)str);
            llMessageLinked(LINK_SET, SEAT_UPDATE, llDumpList2String(slots, "^"), NULL_KEY);
        }
        else if(num == SETOFFSET) {
            SetAvatarOffset(id, (vector)str);
            llMessageLinked(LINK_SET, SEAT_UPDATE, llDumpList2String(slots, "^"), NULL_KEY);
        }
        else if(num == FACIALS_FLAG) {
            facialEnable = str;
        }
        else if(num == SEAT_UPDATE){
            list seatsavailable = llParseStringKeepNulls(str, ["^"], []);
            integer stop = llGetListLength(seatsavailable)/8;
            slots = [];
            faceTimes = [];
            gotFaceAnim = 0;
            string buttonStr = "";

            for(seatcount = 1; seatcount <= stop; ++seatcount) {
                integer seatNum = (integer)llGetSubString(llList2String(seatsavailable, (seatcount-1)*8+7), 4,-1);
                slots = slots + [llList2String(seatsavailable, (seatcount-1)*8), (vector)llList2String(seatsavailable, (seatcount-1)*8+1), 
                        (rotation)llList2String(seatsavailable, (seatcount-1)*8+2), llList2String(seatsavailable, (seatcount-1)*8+3), 
                        (key)llList2String(seatsavailable, (seatcount-1)*8+4), llList2String(seatsavailable, (seatcount-1)*8+5),
                        llList2String(seatsavailable, (seatcount-1)*8+6), llList2String(seatsavailable, (seatcount-1)*8+7)];
                
                if(llList2String(slots, (seatcount-1)*8+4)!="") {
                    buttonStr += llGetSubString(llKey2Name((key)llList2String(seatsavailable, (seatcount-1)*8+4)), 0, 20)+",";
                }
                else {
                    buttonStr += llList2String(seatsavailable, (seatcount-1)*8+7)+",";
                }
                if(llList2String(seatsavailable, (seatcount-1)*8+3) != "") {
                    
                    
                    list faceanimsTemp = llParseString2List(llList2String(seatsavailable, (seatcount-1)*8+3), ["~"], []); 
                    integer facecount = llGetListLength(faceanimsTemp);   
                    list faces = []; 
                    integer nFace;
                    integer hasNewFaceTime = 0;
                    for(nFace=0; nFace<facecount; ++nFace) {
                        
                        list temp = llParseString2List(llList2String(faceanimsTemp, nFace), ["="], []);
                        
                        
                        if(llList2String(temp, 1)) {
                            
                            faces += [llList2String(temp, 0), (integer)llList2String(temp, 1)];
                            hasNewFaceTime = 1;
                        }
                        else {
                            faces += [llList2String(temp, 0), -1];
                        }
                    }
                    gotFaceAnim=1;
                    
                    faceTimes += [(key)llList2String(seatsavailable, (seatcount-1)*8+4), hasNewFaceTime, facecount] + faces;
                }
            }
            llMessageLinked(LINK_SET, SEAT_UPDATE+1, buttonStr, NULL_KEY);
            buttonStr = "";
            
            for(seatcount = 0; seatcount < stop; ++seatcount) {
                if(llList2Key(slots, seatcount*8+4) != "") {
                    if(llListFindList(SeatedAvs(), [llList2Key(slots, seatcount*8+4)]) != -1) {
                        doSync = 0;
                        doSeats(seatcount, llList2String(slots, (seatcount)*8+4));
                        return;
                    }
                }
            }
        }
        else if(num == UNSIT) {
            key avatarUuid=(key)str;
            if(avatarUuid) {
                if(~llListFindList(SeatedAvs(), [avatarUuid])) {
                    llUnSit(avatarUuid);
                }
            }
        }
        else if(num == SYNC) {
            doSync = 1;
            integer stop = llGetListLength(slots)/8;
            for(seatcount = 0; seatcount < stop; ++seatcount) {
                doSeats(seatcount, llList2String(slots, (seatcount)*8+4));
                return;
            }
        }
        else if((num == ADJUST) || (num == REZ_ADJUSTERS && str == "RezAdjuster")) { 
            llSay(chatchannel, "adjuster_die");
            adjusters = [];
            RezNextAdjuster(0);
        }
        else if(num == STOPADJUST) { 
            llMessageLinked(LINK_SET, DUMP, "", "");
            llSay(chatchannel, "adjuster_die"); 
            adjusters = [];
        }
        else if(num == ADJUSTER_REPORT) {    
            integer index = llListFindList(adjusters, [id]);
            if(index != -1) {
                string primName = llGetObjectName();
                llSetObjectName(llGetLinkName(1));
                list params = llParseString2List(str, ["|"], []);
                vector newpos = (vector)llList2String(params, 0) - llGetPos();
                newpos = newpos / llGetRot();
                integer slotsindex = index * stride;
                rotation newrot = (rotation)llList2String(params, 1) / llGetRot();
                slots = llListReplaceList(slots, [newpos, newrot], slotsindex + 1, slotsindex + 2);
                llRegionSayTo(llGetOwner(), 0, "\nANIM|" + llList2String(slots, slotsindex) + "|" + (string)newpos + "|" +
                    (string)(llRot2Euler(newrot) * RAD_TO_DEG) + "|" + llList2String(slots, slotsindex + 3));
                llSetObjectName(primName);
                llMessageLinked(LINK_SET, SEAT_UPDATE, llDumpList2String(slots, "^"), NULL_KEY);
                
                llMessageLinked(LINK_SET, (SEAT_UPDATE + 2000000), llDumpList2String(slots, "^"), NULL_KEY);                
            }
        }
        else if(num == DUMP) {
            integer n;
            string primName = llGetObjectName();
            llSetObjectName(llGetLinkName(1));
            for(n = 0; n < llGetListLength(slots)/8; ++n) {
                list slice = llList2List(slots, n*stride, n*stride + 3);
                slice = llListReplaceList(slice, [RAD_TO_DEG * llRot2Euler(llList2Rot(slice, 2))], 2, 2);
                string sendSTR = "ANIM|" + llDumpList2String(slice, "|");
                llRegionSayTo(llGetOwner(), 0, "\n"+sendSTR);
            }
            llRegionSay(chatchannel, "posdump");
            llSetObjectName(primName);
        }
        else if(num == MENU_USAGE) {
            llSay(0,"Memory Used by " + llGetScriptName() + ": " + (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit()
                 + ",Leaving " + (string)llGetFreeMemory() + " memory free.");
        }
    }
 

    run_time_permissions(integer perm) {
        thisAV = llGetPermissionsKey();
        if(doingFaceAnim != 1) {
            
            integer avIndex = llListFindList(slots, [thisAV]);
            currentanim = llList2String(slots, avIndex - 4);
            
            list animsRunning = llGetAnimationList(thisAV);
            integer indexx = llListFindList(animsRunning, [(key)"1a5fe8ac-a804-8a5d-7cbd-56bd83184568"]);
            
            
            
            integer thisAvIndex = llListFindList(lastanim, [(string)thisAV]);
            if(doSync !=1) {
                if(indexx != -1) {
                    lastAnimRunning = "Sit";
                    lastanim += [(string)thisAV, "Sit"];
                }
                if(thisAvIndex != -1) {
                    lastAnimRunning = llList2String(lastanim, thisAvIndex+1);
                }
                
                if(lastAnimRunning != "") {
                    llStopAnimation(lastAnimRunning);
                }
                thisAvIndex = llListFindList(lastanim, [(string)thisAV]);
                
                lastanim = llListReplaceList(lastanim, [(string)thisAV, currentanim], thisAvIndex, thisAvIndex+1);
                if(avIndex != -1) {
                    if(llListFindList(SeatedAvs(), [thisAV]) != -1) {
                        llStartAnimation(currentanim);
                    }
                }
            }
            else if(llListFindList(SeatedAvs(), [thisAV]) != -1) {
                llStopAnimation(currentanim);
                llStartAnimation("sit");
                llSleep(0.05);
                llStopAnimation("sit");
                llStartAnimation(currentanim);
            }
        }
        
        for(; seatcount < stop-1; ) {
            seatcount += 1;
            if(llList2Key(slots, seatcount*8+4) != "") {
                doSeats(seatcount, llList2String(slots, (seatcount)*8+4));
                return;
            }
        }
        
        if(gotFaceAnim==1) {
            llSetTimerEvent(1.0);
            doingFaceAnim=1;
        }
        else {
            llSetTimerEvent(0.0);
            doingFaceAnim=0;
        }
    }

    timer() {        
        integer n;
        integer stop = llGetListLength(slots)/8;
        key av;
        integer facecount;
        integer faceindex;
        if(facialEnable == "on") {
            for(n=0; n<stop; ++n) {
                
                av = (key)llList2String(slots, n*8+4);
                faceindex = 0;
                
                integer keyHasFacial = llListFindList(faceTimes, [av]);
                
                integer newFaceTimeFlag = llList2Integer(faceTimes, keyHasFacial+1);
                
                if(newFaceTimeFlag == 0) {
                
                    if(av != "") {
                        faceanims = llParseString2List(llList2String(slots, n*8+3), ["~"], []);     
                        facecount = llGetListLength(faceanims);                
                        if(facecount > 0 && (llListFindList(SeatedAvs(), [thisAV]) != -1)) {
                            doingFaceAnim=1;
                            thisAV = llGetPermissionsKey();
                            llRequestPermissions(av, PERMISSION_TRIGGER_ANIMATION);
                        }
                    }
                    integer x;
                    for(x=0; x<facecount; ++x){
                        if (facecount>0) {
                            if(faceindex < facecount) {
                                if(AvLinkNum(av) != -1) {
                                    llStartAnimation(llList2String(faceanims, faceindex));
                                }
                            }            
                            faceindex++;
                        }
                    }
                }
                else if(av != ""){
                
                
                    facecount = llList2Integer(faceTimes, keyHasFacial+2);                
                    
                    if((facecount > 0) && (llListFindList(SeatedAvs(), [thisAV]) != -1)) {  
                        doingFaceAnim=1;
                        thisAV = llGetPermissionsKey();
                        llRequestPermissions(av, PERMISSION_TRIGGER_ANIMATION);
                    }
                        integer x;
                    for(x=1; x<=facecount; ++x) {
                        
                        if(faceindex < facecount) {
                            integer faceStride = keyHasFacial+1+(x*2);
                            string animName = llList2String(faceTimes, faceStride);
                            if(llList2Integer(faceTimes, faceStride+1) > 0) {
                                faceTimes = llListReplaceList(faceTimes, [llList2Integer(faceTimes, faceStride+1)-1],
                                 faceStride+1, faceStride+1);
                            }
                            if(facecount>0) {
                                if(AvLinkNum(av) != -1 && llList2Integer(faceTimes, faceStride+1) > 0) {
                                    llStartAnimation(animName);
                                }
                                else if(AvLinkNum(av) != -1 && llList2Integer(faceTimes, faceStride+1) == -1) {
                                    llStartAnimation(animName);
                                }
                                faceindex++;
                            }
                        }
                    }
                
                }
            }
            if(llGetListLength(SeatedAvs())<1) {
                llSetTimerEvent(0.0);
                doingFaceAnim=0;
            }
        }
    }


    object_rez(key id) {
        if(llKey2Name(id) == "Adjuster") {
            adjusters += [id];
            integer adjLen = llGetListLength(adjusters);
            if(adjLen < (llGetListLength(slots)/8)) { 
                RezNextAdjuster(adjLen);
            }
        }
    }

    changed(integer change) {
        if(change & CHANGED_LINK) {

            integer newPrimCount1 = llGetNumberOfPrims();
            if(newprimcount>newPrimCount1) {
                
                integer n;
                integer stop = llGetListLength(lastanim)/2;
                for(; n<stop; ++n) {
                    if(AvLinkNum((key)llList2String(lastanim, n*2)) == -1) {
                        integer index = llListFindList(animsList, [(key)llList2String(lastanim, n*2)]);
                        if(index != -1) {
                            animsList = llDeleteSubList(animsList, index, index + 2);
                        }
                        lastanim = llDeleteSubList(lastanim, n*2, n*2+1);
                    }
                }
            }
            newprimcount = newPrimCount1;
            if(newprimcount == primcount) {
                

                lastanim = [];
                currentanim = "";
                lastAnimRunning = "";
            }
        }
        else if(change & CHANGED_OWNER) {
            llResetScript();
        }
    }
}

