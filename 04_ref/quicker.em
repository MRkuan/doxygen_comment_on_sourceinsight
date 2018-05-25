/*****************************************************************************
 �� �� ��  : AutoExpand
 ��������  : ��չ������ں���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �޸�

*****************************************************************************/
macro AutoExpand()
{
    //������Ϣ
    // get window, sel, and buffer handles
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.lnFirst != sel.lnLast) 
    {
        /*�������*/
        BlockCommandProc()
    }
    if (sel.ichFirst == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    nVer = 0
    nVer = GetVersion()
    /*ȡ���û���*/
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    // get line the selection (insertion point) is on
    szLine = GetBufLine(hbuf, sel.lnFirst);
    // parse word just to the left of the insertion point
    wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
    ln = sel.lnFirst;
    chTab = CharFromAscii(9)
        
    // prepare a new indented blank line to be inserted.
    // keep white space on left and add a tab to indent.
    // this preserves the indentation level.
    chSpace = CharFromAscii(32);
    ich = 0
    while (szLine[ich] == chSpace || szLine[ich] == chTab)
    {
        ich = ich + 1
    }
    szLine1 = strmid(szLine,0,ich)
    szLine = strmid(szLine, 0, ich) # "    "
    
    sel.lnFirst = sel.lnLast
    sel.ichFirst = wordinfo.ich
    sel.ichLim = wordinfo.ich

    /*�Զ���ɼ������ƥ����ʾ*/
    wordinfo.szWord = RestoreCommand(hbuf,wordinfo.szWord)
    sel = GetWndSel(hwnd)
    if (wordinfo.szWord == "pn") /*���ⵥ�ŵĴ���*/
    {
        DelBufLine(hbuf, ln)
        AddPromblemNo()
        return
    }
    /*��������ִ��*/
    else if (wordinfo.szWord == "config" || wordinfo.szWord == "co")
    {
        DelBufLine(hbuf, ln)
        ConfigureSystem()
        return
    }
    /*�޸���ʷ��¼����*/
    else if (wordinfo.szWord == "hi")
    {
        InsertHistory(hbuf,ln+1,language)
        DelBufLine(hbuf, ln)
        return
    }
    else if (wordinfo.szWord == "abg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseAdd()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "dbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseDel()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "mbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseMod()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    if(language == 1)
    {
        ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
    else
    {
        ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
}

/*****************************************************************************
 �� �� ��  : ExpandProcEN
 ��������  : Ӣ��˵������չ�����
 �������  : szMyName  �û���
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

  2.��    ��   : 2011��2��16��
    ��    ��   : ���
    �޸�����   : �޸����ⵥ��Ϊmantis�ţ��޸�ʱ���ʽΪxxxxxxxx���ꡢ�¡��գ���
               �м�û�зָ��������ӵ���ע�ͣ��Զ���չ��Ϊ"an"

  3.��    ��   : 2011��2��22��
    ��    ��   : ���
    �޸�����   : �޸ĵ���ע��ͷΪadd by��delete by��modify by���Զ���չ��ֱ�Ϊ"as"��"ds"��"ms"
    			 �޸ĵ���ע��Ϊ��������е���󣬲�ɾ�����������
    			 ɾ��ԭ�Զ���չ��Ϊ"an"�ĵ���ע��

*****************************************************************************/
macro ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
  
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    /*Ӣ��ע��*/
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        while(wordinfo.ichLim + kk < lineLen)
        {
            if((szCurLine[wordinfo.ichLim + kk] != " ")||(szCurLine[wordinfo.ichLim + kk] != "\t")
            {
                msg("you must insert /* at the end of a line");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("Please input comment")
        DelBufLine(hbuf, ln)
        szLeft = cat( szLeft, " ")
        CommentContent(hbuf,ln,szLeft,szContent,1)            
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "while" )
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if( szCmd == "else" )
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfdef()
        return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifndef
    {
        DelBufLine(hbuf, ln)
        InsIfndef()
        return
    }
    else if (szCmd == "#if")
    {
        DelBufLine(hbuf, ln)
        InsertPredefIf()
        return
    }
    else if (szCmd == "cpp")
    {
        DelBufLine(hbuf, ln)
        InsertCPP(hbuf,ln)
        return
    }    
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ( # )");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
    else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " (#; #; #)")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("Please input loop variable")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " (@szVar@ = #; @szVar@ #; @szVar@++)")
    }
    else if (szCmd == "fo")
    {
        SetBufSelText(hbuf, "r (ulI = 0; ulI < #; ulI++)")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
        if(strlen(symbol) > 0)
        {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = strstr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
             }
             InsBufLine(hbuf, nIdx + 1, "    VOS_UINT32 ulI = 0;");        
         }
    }
    else if (szCmd == "switch" )
    {
        nSwitch = ask("Please input the number of case")
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
    else if (szCmd == "do")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ( # );")
    }
    else if (szCmd == "case" )
    {
        SetBufSelText(hbuf, " # :")
        InsBufLine(hbuf, ln + 1, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    }
    else if (szCmd == "struct" || szCmd == "st")
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("Please input struct name"))
        InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_STRU")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("Please input enum name"))
        InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_ENUM")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi")
    {
        DelBufLine(hbuf, ln)
        InsertFileHeaderEN( hbuf,0, szMyName,".C file function description" )
        return
    }
    else if (szCmd == "func" || szCmd == "fu")
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("Please input function name")
        FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab")
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
        return
    }
    else if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* Promblem Number: @szQuestion@     Author:@szMyName@,   Date:@sz@-@szMonth@-@szDay@ ");
        szContent = Ask("Description")
        szLeft = cat(szLine1,"   Description    : ");
        if(strlen(szLeft) > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        CreateFunctionDef(hbuf,szMyName,1)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)

        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@*/");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* add end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@  */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln + 0)
        InsBufLine(hbuf, ln, "@szLine1@/* delete end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* modify end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "as")
    {
    	SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

 		szLine1 = strmid (GetBufLine(hbuf, ln), 0, GetBufLineLength (hbuf, ln)-2)
        DelBufLine(hbuf, ln)
        
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        { 
        	InsBufLine(hbuf, ln, "@szLine1@/* add by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add by @szMyName@, @sz@-@szMonth@-@szDay@ */");        
        }
        return
    }
    else if (szCmd == "cs")/*���һ������cs ��������ע��comment by xxx . ��������������2014-5-4*/
    {
    	SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

 		szLine1 = strmid (GetBufLine(hbuf, ln), 0, GetBufLineLength (hbuf, ln)-2)
        DelBufLine(hbuf, ln)
        
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        { 
        	InsBufLine(hbuf, ln, "@szLine1@/* comment by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* comment by @szMyName@, @sz@-@szMonth@-@szDay@ */");        
        }
        return
    }
    else if (szCmd == "ds")
    {
    	SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

 		szLine1 = strmid (GetBufLine(hbuf, ln), 0, GetBufLineLength (hbuf, ln)-2)
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete by @szMyName@, @sz@-@szMonth@-@szDay@ */");        
        }
        return
    }
    else if (szCmd == "ms")
    {
    	SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
       	
 		szLine1 = strmid (GetBufLine(hbuf, ln), 0, GetBufLineLength (hbuf, ln)-2)
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify by @szMyName@, @sz@-@szMonth@-@szDay@ */");        
        }
        return
    }
    else
    {
        SearchForward()
//            ExpandBraceLarge()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}


/*****************************************************************************
 �� �� ��  : ExpandProcCN
 ��������  : ����˵������չ����
 �������  : szMyName  
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

  2.��    ��   : 2011��2��16��
    ��    ��   : ���
    �޸�����   : �޸����ⵥ��Ϊmantis�ţ��޸�ʱ���ʽΪxxxxxxxx���ꡢ�¡��գ���
               �м�û�зָ��������ӵ���ע�ͣ��Զ���չ��Ϊ"an"

  3.��    ��   : 2011��2��22��
    ��    ��   : ���
    �޸�����   : �޸ĵ���ע��ͷΪadd by��delete by��modify by���Զ���չ��ֱ�Ϊ"as"��"ds"��"ms"
    			 �޸ĵ���ע��Ϊ��������е���󣬲�ɾ�����������
    			 ɾ��ԭ�Զ���չ��Ϊ"an"�ĵ���ע��
    
  4.��    ��   : 2011��3��18��
    ��    ��   : ���
    �޸�����   : �޸��ļ���ע�Ͳ���������(�������������ļ�ͷע�ͺ������Զ���ʾ�û�����)

*****************************************************************************/
macro ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)

    //����ע��
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("�ұ߿ռ�̫С,�����µ���")
            stop 
        }        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        /*ע��ֻ������β������ע�͵����ô���*/
        while(wordinfo.ichLim + kk < lineLen)
        {
            if(szCurLine[wordinfo.ichLim + kk] != " ")
            {
                msg("ֻ������β����");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("������ע�͵�����")
        DelBufLine(hbuf, ln)
        szLeft = cat( szLeft, " ")	//��/*���һ���ո��������ĸ�ʽ��/* Ҫע�͵����� */
        CommentContent(hbuf,ln,szLeft,szContent,1)            
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "while" || szCmd == "wh")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if( szCmd == "else" || szCmd == "el")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfdef()
        return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifndef
    {
        DelBufLine(hbuf, ln)
        InsIfndef()
        return
    }
    else if (szCmd == "#if")
    {
        DelBufLine(hbuf, ln)
        InsertPredefIf()
        return
    }
    else if (szCmd == "cpp")
    {
        DelBufLine(hbuf, ln)
        InsertCPP(hbuf,ln)
        return
    }    
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ( # )");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
    else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " (#; #; #)")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("������ѭ������")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " (@szVar@ = #; @szVar@ #; @szVar@++)")
    }
    else if (szCmd == "fo")
    {
        SetBufSelText(hbuf, "r (ulI = 0; ulI < #; ulI++)")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
        if(strlen(symbol) > 0)
        {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = strstr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
            }
            InsBufLine(hbuf, nIdx + 1, "    VOS_UINT32 ulI = 0;");        
        }
    }
    else if (szCmd == "switch" || szCmd == "sw")
    {
        nSwitch = ask("������case�ĸ���")
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
    else if (szCmd == "do")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ( # );")
    }
    else if (szCmd == "case" || szCmd == "ca" )
    {
        SetBufSelText(hbuf, " # :")
        InsBufLine(hbuf, ln + 1, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    }
    else if (szCmd == "struct" || szCmd == "st" )
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("������ṹ��:"))
        InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@      ");
        szStructName = cat(szStructName,"_STRU")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        //��ʾ����ö������ת��Ϊ��д
        szStructName = toupper(Ask("������ö����:"))
        InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        szStructName = cat(szStructName,"_ENUM")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi" )
    {
        DelBufLine(hbuf, ln)
        /*�����ļ�ͷ˵��*/
        InsertFileHeaderCN( hbuf,0, szMyName,"" )
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        /*����C���Ե�ͷ�ļ�*/
        CreateFunctionDef(hbuf,szMyName,0)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)
        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "func" || szCmd == "fu")
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        //���һ�п϶����º���
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            /*����2.1���si����ǷǷ�symbol�ͻ��ж�ִ�У��ʸ�Ϊ�Ժ�һ��
              �Ƿ��С��������ж��Ƿ����º���*/
            if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                /*���Ѿ����ڵĺ���*/
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("�����뺯������:")
        /*���º���*/
        FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab") /*��tab��չΪ�ո�*/
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
    }
    else if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}	
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@-@szMonth@-@szDay@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        if(strlen(szLeft) > 70)
        {
            Msg("�ұ߿ռ�̫С,�����µ���")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ ԭ��: */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@, ԭ��: */");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* add end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ ԭ��: */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@, ԭ��: */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln + 0)
        InsBufLine(hbuf, ln, "@szLine1@/* delete end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ ԭ��: */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@, ԭ��: */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* modify end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "as")
    {
    	SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

 		szLine1 = strmid (GetBufLine(hbuf, ln), 0, GetBufLineLength (hbuf, ln)-2)
        DelBufLine(hbuf, ln)
        
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        { 
        	InsBufLine(hbuf, ln, "@szLine1@/* add by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@, ԭ��: */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add by @szMyName@, @sz@-@szMonth@-@szDay@, ԭ��: */");        
        }
        return
    }
    else if (szCmd == "ds")
    {
    	SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

 		szLine1 = strmid (GetBufLine(hbuf, ln), 0, GetBufLineLength (hbuf, ln)-2)
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@, ԭ��: */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete by @szMyName@, @sz@-@szMonth@-@szDay@, ԭ��: */");        
        }
        return
    }
    else if (szCmd == "ms")
    {
    	SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
       	
 		szLine1 = strmid (GetBufLine(hbuf, ln), 0, GetBufLineLength (hbuf, ln)-2)
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@, ԭ��: */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify by @szMyName@, @sz@-@szMonth@-@szDay@, ԭ��: */");        
        }
        return
    }
    else
    {
        SearchForward()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : BlockCommandProc
 ��������  : ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro BlockCommandProc()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(sel.lnFirst > 0)
    {
        ln = sel.lnFirst - 1
    }
    else
    {
        stop
    }
    szLine = GetBufLine(hbuf,ln)
    szLine = TrimString(szLine)
    if(szLine == "while" || szLine == "wh")
    {
        InsertWhile()   /*����while*/
    }
    else if(szLine == "do")
    {
        InsertDo()   //����do while���
    }
    else if(szLine == "for")
    {
        InsertFor()  //����for���
    }
    else if(szLine == "if")
    {
        InsertIf()   //����if���
    }
    else if(szLine == "el" || szLine == "else")
    {
        InsertElse()  //����else���
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifd") || (szLine == "#ifdef"))
    {
        InsIfdef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifn") || (szLine == "#ifndef"))
    {
        InsIfndef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }    
    else if (szLine == "abg")
    {
        InsertReviseAdd()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "dbg")
    {
        InsertReviseDel()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "mbg")
    {
        InsertReviseMod()
        DelBufLine(hbuf, ln)
        stop
    }
    else if(szLine == "#if")
    {
        InsertPredefIf()
        DelBufLine(hbuf,ln)
        stop
    }
    DelBufLine(hbuf,ln)
    SearchForward()
    stop
}

/*****************************************************************************
 �� �� ��  : RestoreCommand
 ��������  : ��������ָ�����
 �������  : hbuf   
             szCmd  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RestoreCommand(hbuf,szCmd)
{
    if(szCmd == "ca")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "case"
    }
    else if(szCmd == "sw") 
    {
        SetBufSelText(hbuf, "itch")
        szCmd = "switch"
    }
    else if(szCmd == "el")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "else"
    }
    else if(szCmd == "wh")
    {
        SetBufSelText(hbuf, "ile")
        szCmd = "while"
    }
    return szCmd
}

/*****************************************************************************
 �� �� ��  : SearchForward
 ��������  : ��ǰ����#
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchForward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Forward
}

/*****************************************************************************
 �� �� ��  : SearchBackward
 ��������  : �������#
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchBackward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Backward
}

/*****************************************************************************
 �� �� ��  : InsertFuncName
 ��������  : �ڵ�ǰλ�ò��뵫ǰ������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFuncName()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    symbolname = GetCurSymbol()
    SetBufSelText (hbuf, symbolname)
}

/*****************************************************************************
 �� �� ��  : strstr
 ��������  : �ַ���ƥ���ѯ����
 �������  : str1  Դ��
             str2  ��ƥ���Ӵ�
 �������  : ��
 �� �� ֵ  : 0xffffffffΪû���ҵ�ƥ���ַ�����V2.1��֧��-1�ʲ��ø�ֵ
             ����Ϊƥ���ַ�������ʼλ��
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro strstr(str1,str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if((len1 == 0) || (len2 == 0))
    {
        return 0xffffffff
    }
    while( i < len1)
    {
        if(str1[i] == str2[j])
        {
            while(j < len2)
            {
                j = j + 1
                if(str1[i+j] != str2[j]) 
                {
                    break
                }
            }     
            if(j == len2)
            {
                return i
            }
            j = 0
        }
        i = i + 1      
    }  
    return 0xffffffff
}

/*****************************************************************************
 �� �� ��  : InsertTraceInfo
 ��������  : �ں�������ںͳ��ڲ����ӡ,��֧��һ���ж����������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    symbol = GetSymbolLocationFromLn(hbuf, sel.lnFirst)
    InsertTraceInCurFunction(hbuf,symbol)
}

/*****************************************************************************
 �� �� ��  : InsertTraceInCurFunction
 ��������  : �ں�������ںͳ��ڲ����ӡ,��֧��һ���ж����������
 �������  : hbuf
             symbol
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTraceInCurFunction(hbuf,symbol)
{
    ln = GetBufLnCur (hbuf)
    symbolname = symbol.Symbol
    nLineEnd = symbol.lnLim
    nExitCount = 1;
    InsBufLine(hbuf, ln, "    VOS_Debug_Trace(\"\\r\\n |@symbolname@() entry--- \");")
    ln = ln + 1
    fIsEnd = 1
    fIsNeedPrt = 1
    fIsSatementEnd = 1
    szLeftOld = ""
    while(ln < nLineEnd)
    {
        szLine = GetBufLine(hbuf, ln)
        iCurLineLen = strlen(szLine)
        
        /*�޳����е�ע�����*/
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //�����Ƿ���return���
/*        ret =strstr(szLine,"return")
        if(ret != 0xffffffff)
        {
            if( (szLine[ret+6] == " " ) || (szLine[ret+6] == "\t" )
                || (szLine[ret+6] == ";" ) || (szLine[ret+6] == "(" ))
            {
                szPre = strmid(szLine,0,ret)
            }
            SetBufIns(hbuf,ln,ret)
            Paren_Right
            sel = GetWndSel(hwnd)
            if( sel.lnLast != ln )
            {
                GetbufLine(hbuf,sel.lnLast)
                RetVal = SkipCommentFromString(szLine,1)
                szLine = RetVal.szContent
                fIsEnd = RetVal.fIsEnd
            }
        }*/
        //�����߿հ״�С
        nLeft = GetLeftBlank(szLine)
        if(nLeft == 0)
        {
            szLeft = "    "
        }
        else
        {
            szLeft = strmid(szLine,0,nLeft)
        }
        szLine = TrimString(szLine)
        iLen = strlen(szLine)
        if(iLen == 0)
        {
            ln = ln + 1
            continue
        }
        szRet = GetFirstWord(szLine)
//        if( (szRet == "if") || (szRet == "else")
        //�����Ƿ���return���
//        ret =strstr(szLine,"return")
        
        if( szRet == "return")
        {
            if( fIsSatementEnd == 0)
            {
                fIsNeedPrt = 1
                InsBufLine(hbuf,ln+1,"@szLeftOld@}")
                szEnd = cat(szLeft,"VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")
                InsBufLine(hbuf, ln, szEnd )
                InsBufLine(hbuf,ln,"@szLeftOld@{")
                nExitCount = nExitCount + 1
                nLineEnd = nLineEnd + 3
                ln = ln + 3
            }
            else
            {
                fIsNeedPrt = 0
                szEnd = cat(szLeft,"VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")
                InsBufLine(hbuf, ln, szEnd )
                nExitCount = nExitCount + 1
                nLineEnd = nLineEnd + 1
                ln = ln + 1
            }
        }
        else
        {
	        ret =strstr(szLine,"}")
	        if( ret != 0xffffffff )
	        {
	            fIsNeedPrt = 1
	        }
        }
        
        szLeftOld = szLeft
        ch = szLine[iLen-1] 
        if( ( ch  == ";" ) || ( ch  == "{" ) 
             || ( ch  == ":" )|| ( ch  == "}" ) || ( szLine[0] == "#" ))
        {
            fIsSatementEnd = 1
        }
        else
        {
            fIsSatementEnd = 0
        }
        ln = ln + 1
    }
    
    //ֻҪǰ���return����һ��}��˵�������Ľ�βû�з��أ���Ҫ�ټ�һ�����ڴ�ӡ
    if(fIsNeedPrt == 1)
    {
        InsBufLine(hbuf, ln,  "    VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")        
        InsBufLine(hbuf, ln,  "")        
    }
}

/*****************************************************************************
 �� �� ��  : GetFirstWord
 ��������  : ȡ���ַ����ĵ�һ������
 �������  : szLine
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFirstWord(szLine)
{
    szLine = TrimLeft(szLine)
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ") || (szLine[nIdx] == "\t") 
          || (szLine[nIdx] == ";") || (szLine[nIdx] == "(")
          || (szLine[nIdx] == ".") || (szLine[nIdx] == "{")
          || (szLine[nIdx] == ",") || (szLine[nIdx] == ":") )
        {
            return strmid(szLine,0,nIdx)
        }
        nIdx = nIdx + 1
    }
    return ""
    
}

/*****************************************************************************
 �� �� ��  : AutoInsertTraceInfoInBuf
 ��������  : �Զ���ǰ�ļ���ȫ����������ڼ����ӡ��ֻ��֧��C++
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AutoInsertTraceInfoInBuf()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)

    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        isCodeBegin = 0
        fIsEnd = 1
        isBlandLine = 0
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
		    	while (ichild < cchild)
				{
                    symbol = GetBufSymLocation(hbuf, isym)
    		        hsyml = SymbolChildren(symbol)
					childsym = SymListItem(hsyml, ichild)
                    ln = childsym.lnName 
                    isCodeBegin = 0
                    fIsEnd = 1
                    isBlandLine = 0
                    while( ln < childsym.lnLim )
                    {   
                        szLine = GetBufLine (hbuf, ln)
                        
                        //ȥ��ע�͵ĸ���
                        RetVal = SkipCommentFromString(szLine,fIsEnd)
        		        szNew = RetVal.szContent
        		        fIsEnd = RetVal.fIsEnd
                        if(isCodeBegin == 1)
                        {
                            szNew = TrimLeft(szNew)
                            //����Ƿ��ǿ�ִ�д��뿪ʼ
                            iRet = CheckIsCodeBegin(szNew)
                            if(iRet == 1)
                            {
                                if( isBlandLine != 0 )
                                {
                                    ln = isBlandLine
                                }
                                InsBufLine(hbuf,ln,"")
                                childsym.lnLim = childsym.lnLim + 1
                                SetBufIns(hbuf, ln+1 , 0)
                                InsertTraceInCurFunction(hbuf,childsym)
                                break
                            }
                            if(strlen(szNew) == 0) 
                            {
                                if( isBlandLine == 0 ) 
                                {
                                    isBlandLine = ln;
                                }
                            }
                            else
                            {
                                isBlandLine = 0
                            }
                        }
        		        //���ҵ������Ŀ�ʼ
        		        if(isCodeBegin == 0)
        		        {
            		        iRet = strstr(szNew,"{")
                            if(iRet != 0xffffffff)
                            {
                                isCodeBegin = 1
                            }
                        }
                        ln = ln + 1
                    }
                    ichild = ichild + 1
				}
		        SymListFree(hsyml)
	        }
            else if( ( symbol.Type == "Function") ||  (symbol.Type == "Method") )
            {
                ln = symbol.lnName     
                while( ln < symbol.lnLim )
                {   
                    szLine = GetBufLine (hbuf, ln)
                    
                    //ȥ��ע�͵ĸ���
                    RetVal = SkipCommentFromString(szLine,fIsEnd)
    		        szNew = RetVal.szContent
    		        fIsEnd = RetVal.fIsEnd
                    if(isCodeBegin == 1)
                    {
                        szNew = TrimLeft(szNew)
                        //����Ƿ��ǿ�ִ�д��뿪ʼ
                        iRet = CheckIsCodeBegin(szNew)
                        if(iRet == 1)
                        {
                            if( isBlandLine != 0 )
                            {
                                ln = isBlandLine
                            }
                            SetBufIns(hbuf, ln , 0)
                            InsertTraceInCurFunction(hbuf,symbol)
                            InsBufLine(hbuf,ln,"")
                            break
                        }
                        if(strlen(szNew) == 0) 
                        {
                            if( isBlandLine == 0 ) 
                            {
                                isBlandLine = ln;
                            }
                        }
                        else
                        {
                            isBlandLine = 0
                        }
                    }
    		        //���ҵ������Ŀ�ʼ
    		        if(isCodeBegin == 0)
    		        {
        		        iRet = strstr(szNew,"{")
                        if(iRet != 0xffffffff)
                        {
                            isCodeBegin = 1
                        }
                    }
                    ln = ln + 1
                }
            }
        }
        isym = isym + 1
    }
    
}

/*****************************************************************************
 �� �� ��  : CheckIsCodeBegin
 ��������  : �Ƿ�Ϊ�����ĵ�һ����ִ�д���
 �������  : szLine ���û�пո��ע�͵��ַ���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckIsCodeBegin(szLine)
{
    iLen = strlen(szLine)
    if(iLen == 0)
    {
        return 0
    }
    nIdx = 0
    nWord = 0
    if( (szLine[nIdx] == "(") || (szLine[nIdx] == "-") 
           || (szLine[nIdx] == "*") || (szLine[nIdx] == "+"))
    {
        return 1
    }
    if( szLine[nIdx] == "#" )
    {
        return 0
    }
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ")||(szLine[nIdx] == "\t") 
             || (szLine[nIdx] == "(")||(szLine[nIdx] == "{")
             || (szLine[nIdx] == ";") )
        {
            if(nWord == 0)
            {
                if( (szLine[nIdx] == "(")||(szLine[nIdx] == "{")
                         || (szLine[nIdx] == ";")  )
                {
                    return 1
                }
                szFirstWord = StrMid(szLine,0,nIdx)
                if(szFirstWord == "return")
                {
                    return 1
                }
            }
            while(nIdx < iLen)
            {
                if( (szLine[nIdx] == " ")||(szLine[nIdx] == "\t") )
                {
                    nIdx = nIdx + 1
                }
                else
                {
                    break
                }
            }
            nWord = nWord + 1
            if(nIdx == iLen)
            {
                return 1
            }
        }
        if(nWord == 1)
        {
            asciiA = AsciiFromChar("A")
            asciiZ = AsciiFromChar("Z")
            ch = toupper(szLine[nIdx])
            asciiCh = AsciiFromChar(ch)
            if( ( szLine[nIdx] == "_" ) || ( szLine[nIdx] == "*" )
                 || ( ( asciiCh >= asciiA ) && ( asciiCh <= asciiZ ) ) )
            {
                return 0
            }
            else
            {
                return 1
            }
        }
        nIdx = nIdx + 1
    }
    return 1
}

/*****************************************************************************
 �� �� ��  : AutoInsertTraceInfoInPrj
 ��������  : �Զ���ǰ����ȫ���ļ���ȫ����������ڼ����ӡ��ֻ��֧��C++
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AutoInsertTraceInfoInPrj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        szExt = toupper(GetFileNameExt(filename))
        if( (szExt == "C") || (szExt == "CPP") )
        {
            hbuf = OpenBuf (filename)
            if(hbuf != 0)
            {
                SetCurrentBuf(hbuf)
                AutoInsertTraceInfoInBuf()
            }
        }
        //�Զ�������ļ����ɸ�����Ҫ��
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemoveTraceInfo
 ��������  : ɾ���ú����ĳ���ڴ�ӡ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemoveTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(hbuf == hNil)
       stop
    symbolname = GetCurSymbol()
    symbol = GetSymbolLocationFromLn(hbuf, sel.lnFirst)
//    symbol = GetSymbolLocation (symbolname)
    nLineEnd = symbol.lnLim
    szEntry = "VOS_Debug_Trace(\"\\r\\n |@symbolname@() entry--- \");"
    szExit = "VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---:" 
    ln = symbol.lnName
    fIsEntry = 0
    while(ln < nLineEnd)
    {
        szLine = GetBufLine(hbuf, ln)
        
        /*�޳����е�ע�����*/
        RetVal = TrimString(szLine)
        if(fIsEntry == 0)
        {
            ret = strstr(szLine,szEntry)
            if(ret != 0xffffffff)
            {
                DelBufLine(hbuf,ln)
                nLineEnd = nLineEnd - 1
                fIsEntry = 1
                ln = ln + 1
                continue
            }
        }
        ret = strstr(szLine,szExit)
        if(ret != 0xffffffff)
        {
            DelBufLine(hbuf,ln)
            nLineEnd = nLineEnd - 1
        }
        ln = ln + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemoveCurBufTraceInfo
 ��������  : �ӵ�ǰ��buf��ɾ����ӵĳ���ڴ�ӡ��Ϣ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemoveCurBufTraceInfo()
{
    hbuf = GetCurrentBuf()
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
		    	while (ichild < cchild)
				{
    		        hsyml = SymbolChildren(symbol)
					childsym = SymListItem(hsyml, ichild)
                    SetBufIns(hbuf,childsym.lnName,0)
                    RemoveTraceInfo()
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
	        }
            else if( ( symbol.Type == "Function") ||  (symbol.Type == "Method") )
            {
                SetBufIns(hbuf,symbol.lnName,0)
                RemoveTraceInfo()
            }
        }
        isym = isym + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemovePrjTraceInfo
 ��������  : ɾ�������е�ȫ������ĺ����ĳ���ڴ�ӡ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemovePrjTraceInfo()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            SetCurrentBuf(hbuf)
            RemoveCurBufTraceInfo()
        }
        //�Զ�������ļ����ɸ�����Ҫ��
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : InsertFileHeaderEN
 ��������  : ����Ӣ���ļ�ͷ����
 �������  : hbuf       
             ln         �к�
             szName     ������
             szContent  ������������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

  2.��    ��   : 2011��2��22��
    ��    ��   : ���
    �޸�����   : �޸��ļ�ͷ������Ϊ����

*****************************************************************************/
macro InsertFileHeaderEN(hbuf, ln,szName,szContent)
{
    
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    SysTime = GetSysTime(1)
    szYear=SysTime.Year
    GetFunctionList(hbuf,hnewbuf)
    InsBufLine(hbuf, ln + 0,  "/********************************************************************************")
    InsBufLine(hbuf, ln + 1,  "")
    InsBufLine(hbuf, ln + 2,  " **** Copyright (C), @szYear@, xx xx xx xx info&tech Co., Ltd.                ****")
    InsBufLine(hbuf, ln + 3,  "")
    InsBufLine(hbuf, ln + 4,  " ********************************************************************************")
    sz = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 5,  " * File Name     : @sz@")
    InsBufLine(hbuf, ln + 6,  " * Author        : @szName@")
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
    InsBufLine(hbuf, ln + 7,  " * Date          : @sz@-@szMonth@-@szDay@")
  
    /*InsBufLine(hbuf, ln + 8,  "  Created       : @sz@-@szMonth@-@szDay@")
    InsBufLine(hbuf, ln + 9,  "  Last Modified :")*/
    szTmp = " * Description   : "
    nlnDesc = ln
    iLen = strlen (szContent)
    InsBufLine(hbuf, ln + 8, " * Description   : @szContent@")
    InsBufLine(hbuf, ln + 9, " * Version       : 1.0")
    InsBufLine(hbuf, ln + 10," * Function List :")
    InsBufLine(hbuf, ln + 11," * ")
    //���뺯���б�
    /*ln = InsertFileList(hbuf,hnewbuf,ln + 12) - 12
    closebuf(hnewbuf)
    */
    InsBufLine(hbuf, ln + 12, " * Record        :")
    InsBufLine(hbuf, ln + 13, " * 1.Date        : @sz@-@szMonth@-@szDay@")
    InsBufLine(hbuf, ln + 14, " *   Author      : @szName@")
    InsBufLine(hbuf, ln + 15, " *   Modification: Created file")
    InsBufLine(hbuf, ln + 16, "")
    InsBufLine(hbuf, ln + 17, "*************************************************************************************************************/")
    InsBufLine(hbuf, ln + 18, "")
  
    //InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 20, " * external variables                           *")
    //InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 22, "")
    //InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 24, " * external routine prototypes                  *")
    //InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 26, "")
    //InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 28, " * internal routine prototypes                  *")
    //InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 30, "")
    //InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 32, " * project-wide global variables                *")
    //InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 34, "")
    //InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 36, " * module-wide global variables                 *")
    //InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 38, "")
    //InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 40, " * constants                                    *")
    //InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 42, "")
    //InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 44, " * macros                                       *")
    //InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 46, "")
    //InsBufLine(hbuf, ln + 47, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 48, " * routines' implementations                    *")
    //InsBufLine(hbuf, ln + 49, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 50, "")
    if(iLen != 0)
    {
        return
    }
    
    //���û�й���������������ʾ����
    szContent = Ask("Description")
    SetBufIns(hbuf,nlnDesc + 14,0)
    DelBufLine(hbuf,nlnDesc +10)
    
    //ע���������,�Զ�����
    CommentContent(hbuf,nlnDesc + 10,"  Description   : ",szContent,0)
}


/*****************************************************************************
 �� �� ��  : InsertFileHeaderCN
 ��������  : �������������ļ�ͷ˵��
 �������  : hbuf       
             ln         
             szName     
             szContent  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

  2.��    ��   : 2011��2��22��
    ��    ��   : ���
    �޸�����   : �޸��ļ�ͷ������Ϊ����

*****************************************************************************/
macro InsertFileHeaderCN(hbuf, ln,szName,szContent)
{
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    SysTime = GetSysTime(1)
    szYear=SysTime.Year
    szMonth=SysTime.month
    szDay=SysTime.day
    GetFunctionList(hbuf,hnewbuf)
    InsBufLine(hbuf, ln + 0,  "/***********************************************************************************")
    sz = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 1,  " * �� �� ��   : @sz@")
    /*InsBufLine(hbuf, ln + 6,  "  �� �� ��   : ����")*/
    InsBufLine(hbuf, ln + 2,  " * �� �� ��   : @szName@")
    InsBufLine(hbuf, ln + 3,  " * ��������   : @szYear@��@szMonth@��@szDay@��")
	/*InsBufLine(hbuf, ln + 9,  "  ����޸�	:")*/
    iLen = strlen (szContent)
    nlnDesc = ln
    szTmp = " * �ļ�����   : "
    InsBufLine(hbuf, ln + 4, " * �ļ�����   : @szContent@")
    InsBufLine(hbuf, ln + 5, " * ��Ȩ˵��   : Copyright (c) 2008-@szYear@   xx xx xx xx �������޹�˾")
    InsBufLine(hbuf, ln + 6, " * ��    ��   : ")
    InsBufLine(hbuf, ln + 7, " * �޸���־   : ")
    InsBufLine(hbuf, ln + 8, "***********************************************************************************/")
    InsBufLine(hbuf, ln + 9, "")

//    InsBufLine(hbuf, ln + 9, " * �� �� ��   : 1.0")
//    InsBufLine(hbuf, ln + 10," * �����б�   :")
//    InsBufLine(hbuf, ln + 11," * ")
//    //���뺯���б�
//    /*ln = InsertFileList(hbuf,hnewbuf,ln + 12) - 12
//    closebuf(hnewbuf)
//    */
//    InsBufLine(hbuf, ln + 12, " * ��ʷ��¼   :")
//    InsBufLine(hbuf, ln + 13, " * 1.��    �� : @sz@-@szMonth@-@szDay@")
//
//    if( strlen(szMyName)>0 )
//    {
//       InsBufLine(hbuf, ln + 14, " *   ��    �� : @szName@")
//    }
//    else
//    {
//       InsBufLine(hbuf, ln + 14, " *   ��    �� : #")
//    }
//    InsBufLine(hbuf, ln + 15, " *   �޸����� : �����ļ�")    
//    InsBufLine(hbuf, ln + 16, "")
//    InsBufLine(hbuf, ln + 17, "***********************************************************************************/")
//    InsBufLine(hbuf, ln + 18, "")
    //InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 20, " * �ⲿ����˵��                                 *")
    //InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 22, "")
    //InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 24, " * �ⲿ����ԭ��˵��                             *")
    //InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 26, "")
    //InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 28, " * �ڲ�����ԭ��˵��                             *")
    //InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 30, "")
    //InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 32, " * ȫ�ֱ���                                     *")
    //InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 34, "")
    //InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 36, " * ģ�鼶����                                   *")
    //InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 38, "")
    //InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 40, " * ��������                                     *")
    //InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 42, "")
    //InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
    //InsBufLine(hbuf, ln + 44, " * �궨��                                       *")
    //InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
    //InsBufLine(hbuf, ln + 46, "")
    if(strlen(szContent) != 0)
    {
        return
    }
    
    //���û�����빦�������Ļ���ʾ����
    szContent = Ask("�������ļ���������������")

    //���ù��λ��Ϊע�͵����һ��
    SetBufIns(hbuf,nlnDesc + 9,0)
    
    //��ԭ"�ļ�����"��ɾ��
    DelBufLine(hbuf,nlnDesc +4)
    
    //�Զ�������ʾ��������
    CommentContent(hbuf,nlnDesc+4," * �ļ�����   : ",szContent,0)
}

/*****************************************************************************
 �� �� ��  : GetFunctionList
 ��������  : ��ú����б�
 �������  : hbuf  
             hnewbuf    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFunctionList(hbuf,hnewbuf)
{
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    //����ȡ��ȫ���ĵ�ǰbuf���ű��е�ȫ������
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        if(symbol.Type == "Class Placeholder")
        {
	        hsyml = SymbolChildren(symbol)
			cchild = SymListCount(hsyml)
			ichild = 0
	    	while (ichild < cchild)
			{
				childsym = SymListItem(hsyml, ichild)
                AppendBufLine(hnewbuf,childsym.symbol)
				ichild = ichild + 1
			}
	        SymListFree(hsyml)
        }
        if(strlen(symbol) > 0)
        {
            if( (symbol.Type == "Method") || 
                (symbol.Type == "Function") || ("Editor Macro" == symbol.Type) )
            {
                //ȡ�������Ǻ����ͺ�ķ���
                symname = symbol.Symbol
                //�����Ų��뵽��buf����������Ϊ�˼���V2.1
                AppendBufLine(hnewbuf,symname)
               }
           }
        isym = isym + 1
    }
}
/*****************************************************************************
 �� �� ��  : InsertFileList
 ��������  : �����б����
 �������  : hbuf  
             ln    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileList(hbuf,hnewbuf,ln)
{
    if(hnewbuf == hNil)
    {
        return ln
    }
    isymMax = GetBufLineCount (hnewbuf)
    isym = 0
    while (isym < isymMax) 
    {
        szLine = GetBufLine(hnewbuf, isym)
        InsBufLine(hbuf,ln,"              @szLine@")
        ln = ln + 1
        isym = isym + 1
    }
    return ln 
}


/*****************************************************************************
 �� �� ��  : CommentContent1
 ��������  : �Զ�������ʾ�ı�,��Ϊmsg�Ի����ܴ�����е���������Ҳ��ܳ���255
             ���ַ�����Ϊ���У������˴Ӽ�����ȡ���ݵİ취���������������Ǽ�
             ���������ݵ�ǰ���ֵĻ�����Ϊ�û��ǿ��������ݣ���������Ȼ�п�����
             �󣬵����ָ��ʷǳ��͡���CommentContent��ͬ���������������е�����
             �ϲ���һ�����������Ը�����Ҫѡ�������ַ�ʽ
 �������  : hbuf       
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����'*'��'/'
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentContent1 (hbuf,ln,szPreStr,szContent,isEnd)
{
    //���������еĶ���ı��ϲ�
    szClip = MergeString()
    //ȥ������Ŀո�
    szTmp = TrimString(szContent)
    //������봰���е������Ǽ������е�����˵���Ǽ���������
    ret = strstr(szClip,szTmp)
    if(ret == 0)
    {
        szContent = szClip
    }
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }
    iLen = strlen (szContent)
    szTmp = cat(szPreStr,"#");
    if( iLen == 0)
    {
        InsBufLine(hbuf, ln, "@szTmp@")
    }
    else
    {
        i = 0
        while  (iLen - i > 75 - k )
        {
            j = 0
            while(j < 75 - k)
            {
                iNum = szContent[i + j]
                //��������ı���ɶԴ���
                if( AsciiFromChar (iNum)  > 160 )
                {
                   j = j + 2
                }
                else
                {
                   j = j + 1
                }
                if( (j > 70 - k) && (szContent[i + j] == " ") )
                {
                    break
                }
            }
            if( (szContent[i + j] != " " ) )
            {
                n = 0;
                iNum = szContent[i + j + n]
                while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                {
                    n = n + 1
                    if((n >= 3) ||(i + j + n >= iLen))
                         break;
                    iNum = szContent[i + j + n]
                   }
                if(n < 3)
                {
                    j = j + n 
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)                
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                    if(sz1[strlen(sz1)-1] != "-")
                    {
                        sz1 = cat(sz1,"-")                
                    }
                }
            }
            else
            {
                sz1 = strmid(szContent,i,i+j)
                sz1 = cat(szPreStr,sz1)
            }
            InsBufLine(hbuf, ln, "@sz1@")
            ln = ln + 1
            szPreStr = szLeftBlank
            i = i + j
            while(szContent[i] == " ")
            {
                i = i + 1
            }
        }
        sz1 = strmid(szContent,i,iLen)
        sz1 = cat(szPreStr,sz1)
        if(isEnd)
        {
            sz1 = cat(sz1,"*/")
        }
        InsBufLine(hbuf, ln, "@sz1@")
    }
    return ln
}



/*****************************************************************************
 �� �� ��  : CommentContent
 ��������  : �Զ�������ʾ�ı�,��Ϊmsg�Ի����ܴ�����е���������Ҳ��ܳ���255
             ���ַ�����Ϊ���У������˴Ӽ�����ȡ���ݵİ취���������������Ǽ�
             ���������ݵ�ǰ���ֵĻ�����Ϊ�û��ǿ��������ݣ���������Ȼ�п�����
             �󣬵����ָ��ʷǳ���
 �������  : hbuf       
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����' '��'*'��'/'
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentContent (hbuf,ln,szPreStr,szContent,isEnd)
{
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }

    hNewBuf = newbuf("clip")
    if(hNewBuf == hNil)
        return       
    SetCurrentBuf(hNewBuf)
    PasteBufLine (hNewBuf, 0)
    lnMax = GetBufLineCount( hNewBuf )
    szTmp = TrimString(szContent)

    //�ж������������0��ʱ������Щ�汾�������⣬Ҫ�ų���
    if(lnMax != 0)
    {
        szLine = GetBufLine(hNewBuf , 0)
	    ret = strstr(szLine,szTmp)
	    if(ret == 0)
	    {
	        /*������봰����������Ǽ������һ����˵���Ǽ���������ȡ�������е���
	          ��*/
	        szContent = TrimString(szLine)
	    }
	    else
	    {
	        lnMax = 1
	    }	    
    }
    else
    {
        lnMax = 1
    }    
    szRet = ""
    nIdx = 0
    while ( nIdx < lnMax) 
    {
        if(nIdx != 0)
        {
            szLine = GetBufLine(hNewBuf , nIdx)
            szContent = TrimLeft(szLine)
               szPreStr = szLeftBlank
        }
        iLen = strlen (szContent)
        szTmp = cat(szPreStr,"#");
        if( (iLen == 0) && (nIdx == (lnMax - 1))
        {
            InsBufLine(hbuf, ln, "@szTmp@")
        }
        else
        {
            i = 0
            //��ÿ��75���ַ�����
            while  (iLen - i > 75 - k )
            {
                j = 0
                while(j < 75 - k)
                {
                    iNum = szContent[i + j]
                    if( AsciiFromChar (iNum)  > 160 )
                    {
                       j = j + 2
                    }
                    else
                    {
                       j = j + 1
                    }
                    if( (j > 70 - k) && (szContent[i + j] == " ") )
                    {
                        break
                    }
                }
                if( (szContent[i + j] != " " ) )
                {
                    n = 0;
                    iNum = szContent[i + j + n]
                    //����������ַ�ֻ�ܳɶԴ���
                    while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                    {
                        n = n + 1
                        if((n >= 3) ||(i + j + n >= iLen))
                             break;
                        iNum = szContent[i + j + n]
                    }
                    if(n < 3)
                    {
                        //�ֶκ�ֻ��С��3�����ַ������¶���������ȥ
                        j = j + n 
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)                
                    }
                    else
                    {
                        //����3���ַ��ļ����ַ��ֶ�
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)
                        if(sz1[strlen(sz1)-1] != "-")
                        {
                            sz1 = cat(sz1,"-")                
                        }
                    }
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                }
                InsBufLine(hbuf, ln, "@sz1@")
                ln = ln + 1
                szPreStr = szLeftBlank
                i = i + j
                while(szContent[i] == " ")
                {
                    i = i + 1
                }
            }
            sz1 = strmid(szContent,i,iLen)
            sz1 = cat(szPreStr,sz1)
            if((isEnd == 1) && (nIdx == (lnMax - 1))
            {
                sz1 = cat(sz1," */")
            }
            InsBufLine(hbuf, ln, "@sz1@")
        }
        ln = ln + 1
        nIdx = nIdx + 1
    }
    closebuf(hNewBuf)
    return ln - 1
}

/*****************************************************************************
 �� �� ��  : FormatLine
 ��������  : ��һ�г��ı������Զ�����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FormatLine()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.ichFirst > 70)
    {
        Msg("ѡ��̫������")
        stop 
    }
    hbuf = GetWndBuf(hwnd)
    // get line the selection (insertion point) is on
    szCurLine = GetBufLine(hbuf, sel.lnFirst);
    lineLen = strlen(szCurLine)
    szLeft = strmid(szCurLine,0,sel.ichFirst)
    szContent = strmid(szCurLine,sel.ichFirst,lineLen)
    DelBufLine(hbuf, sel.lnFirst)
    CommentContent(hbuf,sel.lnFirst,szLeft,szContent,0)            

}

/*****************************************************************************
 �� �� ��  : CreateBlankString
 ��������  : ���������ո���ַ���
 �������  : nBlankCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateBlankString(nBlankCount)
{
    szBlank=""
    nIdx = 0
    while(nIdx < nBlankCount)
    {
        szBlank = cat(szBlank," ")
        nIdx = nIdx + 1
    }
    return szBlank
}

/*****************************************************************************
 �� �� ��  : TrimLeft
 ��������  : ȥ���ַ�����ߵĿո�
 �������  : szLine  
 �������  : ȥ����ո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimLeft(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = 0
    while( nIdx < nLen )
    {
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
        nIdx = nIdx + 1
    }
    return strmid(szLine,nIdx,nLen)
}

/*****************************************************************************
 �� �� ��  : TrimRight
 ��������  : ȥ���ַ����ұߵĿո�
 �������  : szLine  
 �������  : ȥ���ҿո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimRight(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = nLen
    while( nIdx > 0 )
    {
        nIdx = nIdx - 1
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
    }
    return strmid(szLine,0,nIdx+1)
}

/*****************************************************************************
 �� �� ��  : TrimString
 ��������  : ȥ���ַ������ҿո�
 �������  : szLine  
 �������  : ȥ�����ҿո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}


/*****************************************************************************
 �� �� ��  : GetFunctionDef
 ��������  : ���ֳɶ��еĺ�������ͷ�ϲ���һ��
 �������  : hbuf    
             symbol  ��������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFunctionDef(hbuf,symbol)
{
    ln = symbol.lnName
    szFunc = ""
    if(strlen(symbol) == 0)
    {
       return szFunc
    }
    fIsEnd = 1
//    msg(symbol)
    while(ln < symbol.lnLim)
    {
        szLine = GetBufLine (hbuf, ln)
        //ȥ����ע�͵�������
        RetVal = SkipCommentFromString(szLine,fIsEnd)
		szLine = RetVal.szContent
		szLine = TrimString(szLine)
		fIsEnd = RetVal.fIsEnd
        //�����{��ʾ��������ͷ������
        ret = strstr(szLine,"{")        
        if(ret != 0xffffffff)
        {
            szLine = strmid(szLine,0,ret)
            szFunc = cat(szFunc,szLine)
            break
        }
        szFunc = cat(szFunc,szLine)        
        ln = ln + 1
    }
    return szFunc
}

/*****************************************************************************
 �� �� ��  : GetWordFromString
 ��������  : ���ַ�����ȡ����ĳ�ַ�ʽ�ָ���ַ�����
 �������  : hbuf         ���ɷָ���ַ�����buf
             szLine       �ַ���
             nBeg         ��ʼ����λ��
             nEnd         ��������λ��
             chBeg        ��ʼ���ַ���־
             chSeparator  �ָ��ַ�
             chEnd        �����ַ���־
 �������  : ����ַ�����
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetWordFromString(hbuf,szLine,nBeg,nEnd,chBeg,chSeparator,chEnd)
{
    if((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }
    nMaxLen = 0
    nIdx = nBeg
    //�ȶ�λ����ʼ�ַ���Ǵ�
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chBeg)
        {
        	//nIdx����1���ڷָ���Ϊ��ǵ������е�һ�ξͻ��ѵ���ʼ��
            break
        }
        nIdx = nIdx + 1
    }
    nBegWord = nIdx + 1
    
    //���ڼ��chBeg��chEnd������������λ����ʼ����nIdxû�м�1������iCount=0
    iCount = 0
    
    nEndWord = 0
    //�Էָ���Ϊ��ǽ�������
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chSeparator)
        {
           szWord = strmid(szLine,nBegWord,nIdx)
           szWord = TrimString(szWord)
           nLen = strlen(szWord)
           if(nMaxLen < nLen)
           {
               nMaxLen = nLen
           }
           AppendBufLine(hbuf,szWord)
           nBegWord = nIdx + 1
        }
        if(szLine[nIdx] == chBeg)
        {
            iCount = iCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            iCount = iCount - 1
            nEndWord = nIdx
            if( iCount == 0 )
            {
                break
            }
        }
        nIdx = nIdx + 1
    }
    //��ȡ�ָ����������֮����ַ�����
    if(nEndWord > nBegWord)
    {
        szWord = strmid(szLine,nBegWord,nEndWord)
        szWord = TrimString(szWord)
        nLen = strlen(szWord)
        if(nMaxLen < nLen)
        {
            nMaxLen = nLen
        }
        AppendBufLine(hbuf,szWord)
    }
    return nMaxLen
}


/*****************************************************************************
 �� �� ��  : FuncHeadCommentCN
 ��������  : �������ĵĺ���ͷע��
 �������  : hbuf      
             ln        �к�
             szFunc    ������
             szMyName  ������
             newFunc   �Ƿ��º���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FuncHeadCommentCN(hbuf, ln, szFunc, szMyName,newFunc)
{
    iIns = 0
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
            if(hTmpBuf == hNil)
            {
                stop
            }
            //���ֳɶ��еĺ�������ͷ�ϲ���һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)
            iBegin = symbol.ichName 
            //ȡ������ֵ����
            szTemp = strmid(szLine,0,iBegin)
            szTemp = TrimString(szTemp)
            szRet =  GetFirstWord(szTemp)
            if(symbol.Type == "Method")
            {
                szTemp = strmid(szTemp,strlen(szRet),strlen(szTemp))
                szTemp = TrimString(szTemp)
                if(szTemp == "::")
                {
                    szRet = ""
                }   
            }
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }
            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szLine = ""
        szRet = ""
    }
    InsBufLine(hbuf, ln, "/*****************************************************************************")
    if( strlen(szFunc)>0 )
    {
        InsBufLine(hbuf, ln+1, " * �� �� ��  : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln+1, " * �� �� ��  : #")
    }
    oldln = ln
    InsBufLine(hbuf, ln+2, " * �� �� ��  : @szMyName@")
    SysTime = GetSysTime(1);
    /*szTime = SysTime.Date*/
	SysTime = GetSysTime(1);
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day
    InsBufLine(hbuf, ln+3, " * ��������  : @sz1@��@sz2@��@sz3@��")
    InsBufLine(hbuf, ln+4, " * ��������  : ")
    szIns = " * �������  : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ������뺯������
        i = 0
        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)

            //�����������
            szParamAsk = cat("�������������: ",szTmp)
            szParamDescribe = Ask(szParamAsk)
            szTmp = cat(szTmp,szParamDescribe)
            
            ln = ln + 1		//����ǹؼ���ÿ�ҵ�һ��������ln��1����֤�����ln+?�ж��������в���������ӵ�
            szTmp = cat(szIns,szTmp)
            InsBufLine(hbuf, ln+4, "@szTmp@")	//�ڵ�ln+4�в�������Ϊǰ��ÿ��������ln=ln+1����ʵ�Ǵ�ln5�п�ʼÿ����������һ��
            iIns = 1	//�����Ƿ���ڲ������
            szIns = "               "		//�ڶ�������ǰ�����ո����
            i = i + 1
        }    
        closebuf(hTmpBuf)
    }
    if(iIns == 0)
    {       
            ln = ln + 1		//Ϊ�˱������в�����һ��
            InsBufLine(hbuf, ln+4, " * �������  : ��")	//�ڵ�ln+4�в�������Ϊǰ��ÿ��������ln=ln+1����ʵ�Ǵ�ln5�п�ʼÿ����������һ��
    }
    InsBufLine(hbuf, ln+5, " * �������  : ��")
    InsBufLine(hbuf, ln+6, " * �� �� ֵ  : @szRet@")
    InsBufLine(hbuf, ln+7, " * ���ù�ϵ  : ")
    InsBufLine(hbuf, ln+8, " * ��    ��  : ")
    /*InsBufLine(hbuf, ln+6, " �� �� ��  : @szMyName@")
    InsbufLIne(hbuf, ln+7, " ����ʱ��  : @szTime@")*/
//    InsBufLine(hbuf, ln+6, " * ��    ¼")
//    SysTime = GetSysTime(1);
//    /*szTime = SysTime.Date*/
//	SysTime = GetSysTime(1);
//    sz1=SysTime.Year
//    sz2=SysTime.month
//    sz3=SysTime.day
//    if (sz2 < 10)
//    {
//    	szMonth = "0@sz2@"
//   	}
//   	else
//   	{
//   		szMonth = sz2
//   	}
//   	if (sz3 < 10)
//    {
//    	szDay = "0@sz3@"
//   	}
//   	else
//   	{
//   		szDay = sz3
//   	}
//    
//    InsBufLine(hbuf, ln+7, " * 1.��    ��: @sz1@@szMonth@@szDay@")
//
//    if( strlen(szMyName)>0 )
//    {
//       InsBufLine(hbuf, ln+8, " *   ��    ��: @szMyName@")
//    }
//    else
//    {
//       InsBufLine(hbuf, ln+8, " *   ��    ��: #")
//    }
//    InsBufLine(hbuf, ln+9, " *   �޸�����: �����ɺ���")    
    InsBufLine(hbuf, ln+9, "")    
    InsBufLine(hbuf, ln+10, "*****************************************************************************/")
    //�����˺��������º�����ע�ͺ���Ϻ�����
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+11, "VOS_UINT32  @szFunc@( # )")
        InsBufLine(hbuf, ln+12, "{");
        InsBufLine(hbuf, ln+13, "    #");
        InsBufLine(hbuf, ln+14, "}");
        SearchForward()		//��궨λ����ǰ�浥�����ֵ�#�ϣ���ѡ��#���������������#(�����Ĳ���λ��)
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    //��궨λ��"{"��
    sel = GetWndSel(hwnd)
    sel.ichFirst = 1
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 12
    sel.lnLast = ln + 12 
    szContent = Ask("�����뺯����������������")
    setWndSel(hwnd,sel)
    DelBufLine(hbuf,oldln + 4)

    //��ʾ����Ĺ�����������
    newln = CommentContent(hbuf,oldln+4," * ��������  : ",szContent,0) - 4//�˴���4����ΪCommentContent���ص�ֵ�Ǵ���ȥ��oldln+4֮�����������
    ln = ln + newln - oldln		//������������
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
            
        //��ʾ�����º����ķ���ֵ
        szRet = Ask("�����뷵��ֵ����")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+6, " * �� �� ֵ  : @szRet@")            
            PutBufLine(hbuf, ln+11, "@szRet@ @szFunc@(   )")
            SetbufIns(hbuf,ln+11,strlen(szRet)+strlen(szFunc) + 3	//��궨λ��������������"("��һ���ո�
        }
        szFuncDef = ""
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 3
        sel.ichLim = sel.ichFirst + 1
        //ѭ���������
        while (1)
        {
            szParam = ask("�����뺯��������")
            szParam = TrimString(szParam)
            szParamOriginal = szParam
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
            
            //��궨λ�����������һ��������
            sel.lnFirst = ln + 11
            sel.lnLast = ln + 11
            setWndSel(hwnd,sel)
            
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel

            //�����������
            szParamAsk = cat("�������������: ",szParamOriginal)
            szParamDescribe = Ask(szParamAsk)
            szTmp = cat(szTmp,"  ")
            szTmp = cat(szTmp,szParamDescribe)


            //�ں���ͷע���в������
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+4, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+4, "@szTmp@")
                oldsel.lnFirst = ln + 11
                oldsel.lnLast = ln + 11       
            }

            //�ڹ�����ڵ�λ�ò������
            SetBufSelText(hbuf,szParam)
            
            //����ͷע�͵Ķ���
            szIns = "               "
            //�������һ���ո�
            szFuncDef = ", "

            //��궨λ������"{"���"#"������ѡ��"#"
            oldsel.lnFirst = ln + 13
            oldsel.lnLast = ln + 13
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 14
}

/*****************************************************************************
 �� �� ��  : FuncHeadCommentEN
 ��������  : ����ͷӢ��˵��
 �������  : hbuf      
             ln        
             szFunc    
             szMyName  
             newFunc   
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FuncHeadCommentEN(hbuf, ln, szFunc, szMyName,newFunc)
{
    iIns = 0
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
                
            //���ļ�����ͷ�����һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName
            
            //ȡ������ֵ����
            szTemp = strmid(szLine,0,iBegin)
            szTemp = TrimString(szTemp)
            szRet =  GetFirstWord(szTemp)
            if(symbol.Type == "Method")
            {
                szTemp = strmid(szTemp,strlen(szRet),strlen(szTemp))
                szTemp = TrimString(szTemp)
                if(szTemp == "::")
                {
                    szRet = ""
                }
            }
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }
            
            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szRet = ""
        szLine = ""
    }
    InsBufLine(hbuf, ln, "/*****************************************************************************")
    InsBufLine(hbuf, ln+1, " * Function      : @szFunc@")
    InsBufLine(hbuf, ln+2, " * Description   : ")
    oldln  = ln 
    szIns = " * Input         : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ���������������
        i = 0
        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            
            //�����������Ŀո�ʵ���Ƕ������Ĳ�����˵��
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)
            ln = ln + 1
            szTmp = cat(szIns,szTmp)
            InsBufLine(hbuf, ln+2, "@szTmp@")
            iIns = 1
            szIns = "                "
            i = i + 1
        }    
        closebuf(hTmpBuf)
    }
    if(iIns == 0)
    {       
            ln = ln + 1
            InsBufLine(hbuf, ln+2, " * Input          : None")
    }
    InsBufLine(hbuf, ln+3, " * Output        : None")
    InsBufLine(hbuf, ln+4, " * Return        : @szRet@")
    /*InsBufLine(hbuf, ln+5, " Calls        : ")
    InsBufLine(hbuf, ln+6, " Called By    : ")*/
    InsbufLIne(hbuf, ln+5, " * Others        : ");
    
    SysTime = GetSysTime(1);
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day
    if (sz2 < 10)
    {
    	szMonth = "0@sz2@"
   	}
   	else
   	{
   		szMonth = sz2
   	}
   	if (sz3 < 10)
    {
    	szDay = "0@sz3@"
   	}
   	else
   	{
   		szDay = sz3
   	}

    InsBufLine(hbuf, ln + 6, " * Record")
    InsBufLine(hbuf, ln + 7, " * 1.Date        : @sz1@@szMonth@@szDay@")
    InsBufLine(hbuf, ln + 8, " *   Author      : @szMyName@")
    InsBufLine(hbuf, ln + 9, " *   Modification: Created function")
    InsBufLine(hbuf, ln + 10, "")    
    InsBufLine(hbuf, ln + 11, "*****************************************************************************/")
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+12, "VOS_UINT32  @szFunc@( # )")
        InsBufLine(hbuf, ln+13, "{");
        InsBufLine(hbuf, ln+14, "    #");
        InsBufLine(hbuf, ln+15, "}");
        SearchForward()
    }        
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 12
    sel.lnLast = ln + 12       
    szContent = Ask("Description")
    DelBufLine(hbuf,oldln + 2)
    setWndSel(hwnd,sel)
    newln = CommentContent(hbuf,oldln + 2," * Description   : ",szContent,0) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        //��ʾ���뺯������ֵ��
        szRet = Ask("Please input return value type")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+4, " * Return        : @szRet@")            
            PutBufLine(hbuf, ln+12, "@szRet@ @szFunc@( # )")
            SetbufIns(hbuf,ln+12,strlen(szRet)+strlen(szFunc) + 3
        }
        szFuncDef = ""
        isFirstParam = 1
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 3
        sel.ichLim = sel.ichFirst + 1

        //ѭ�������º����Ĳ���
        while (1)
        {
            szParam = ask("Please input parameter")
            szParam = TrimString(szParam)
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
            sel.lnFirst = ln + 12
            sel.lnLast = ln + 12
            setWndSel(hwnd,sel)
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+2, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+2, "@szTmp@")
                oldsel.lnFirst = ln + 12
                oldsel.lnLast = ln + 12        
            }
            SetBufSelText(hbuf,szParam)
            szIns = "                "
            szFuncDef = ", "
            oldsel.lnFirst = ln + 14
            oldsel.lnLast = ln + 14
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 15
}

/*****************************************************************************
 �� �� ��  : InsertHistory
 ��������  : �����޸���ʷ��¼
 �������  : hbuf      
             ln        �к�
             language  ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertHistory(hbuf,ln,language)
{
    iHistoryCount = 1
//    isLastLine = ln
//    i = 0
//    while(ln-i>0)
//    {
//        szCurLine = GetBufLine(hbuf, ln-i);
//        iBeg1 = strstr(szCurLine,"��    ��  ")
//        iBeg2 = strstr(szCurLine,"Date      ")
//        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
//        {
//            iHistoryCount = iHistoryCount + 1
//            i = i + 1
//            continue
//        }
//        iBeg1 = strstr(szCurLine,"�޸���ʷ")
//        iBeg2 = strstr(szCurLine,"History      ")
//        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
//        {
//            break
//        }
//        iBeg = strstr(szCurLine,"/**********************")
//        if( iBeg != 0xffffffff )
//        {
//            break
//        }
//       i = i + 1
//    }
    if(language == 0)
    {
        InsertHistoryContentCN(hbuf,ln,iHistoryCount)
    }
    else
    {
        InsertHistoryContentEN(hbuf,ln,iHistoryCount)
    }
}

/*****************************************************************************
 �� �� ��  : UpdateFunctionList
 ��������  : ���º����б�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro UpdateFunctionList()
{
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    GetFunctionList(hbuf,hnewbuf)
    ln = sel.lnFirst
    iHistoryCount = 1
    isLastLine = ln
    iTotalLn = GetBufLineCount (hbuf) 
    while(ln < iTotalLn)
    {
        szCurLine = GetBufLine(hbuf, ln);
        iLen = strlen(szCurLine)
        j = 0;
        while(j < iLen)
        {
            if(szCurLine[j] != " ")
                break
            j = j + 1
        }
        
        //���ļ�ͷ˵����ǰ�д���10���ո��Ϊ�����б��¼
        if(j > 10)
        {
            DelBufLine(hbuf, ln)   
        }
        else
        {
            break
        }
        iTotalLn = GetBufLineCount (hbuf) 
    }

    //���뺯���б�
    InsertFileList( hbuf,hnewbuf,ln )
    closebuf(hnewbuf)
 }

/*****************************************************************************
 �� �� ��  : InsertHistoryContentCN
 ��������  : ������ʷ�޸ļ�¼����˵��
 �������  : hbuf           
             ln             
             iHostoryCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro  InsertHistoryContentCN(hbuf,ln,iHostoryCount)
{
	//��ȡʱ��
    SysTime = GetSysTime(1);
    szYear=SysTime.Year
    szMonth=SysTime.month
    if (szMonth < 10)
    {
    	szMonth = "0@szMonth@"
   	}
    szDay=SysTime.day
  	if (szDay < 10)
    {
    	szDay = "0@szDay@"
   	}

    //��ȡ�û���
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }


   	//��ȡ�������λ�õ������ַ��������õ�"hi"�ַ���
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    szLine = GetBufLine (hbuf, sel.lnFirst)
    wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)

	//��ȡ"hi"�����ַ�
    strLeft = strmid (szLine, 0, wordinfo.ich)

	//�ж������ַ��Ƿ���" * �޸���־   :"
    ret =strstr(strLeft, " * �޸���־   :")
    if(ret != 0xffffffff)	//�޸���־�ĵ�һ�У�����"�޸���־"�ַ���
    {
    	szTmp = strLeft
    }
    else		//�޸���־�������У�ǰ�油�ո�
    {
    	szTmp = CreateBlankString(16)
    }

	//�����޸����ڣ��޸���
    szTmp = cat(szTmp,"@szYear@@szMonth@@szDay@ by @szMyName@, ")

   	szContent = Ask("�������޸ĵ�����")
   	CommentContent(hbuf,ln,szTmp,szContent,0)

//    SysTime = GetSysTime(1);
//    szTime = SysTime.Date
//    szMyName = getreg(MYNAME)
//
//    InsBufLine(hbuf, ln, "")
//    InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.��    ��   : @szTime@")
//
//    if( strlen(szMyName) > 0 )
//    {
//       InsBufLine(hbuf, ln + 2, "    ��    ��   : @szMyName@")
//    }
//    else
//    {
//       InsBufLine(hbuf, ln + 2, "    ��    ��   : #")
//    }
//       szContent = Ask("�������޸ĵ�����")
//       CommentContent(hbuf,ln + 3,"    �޸�����   : ",szContent,0)
}


/*****************************************************************************
 �� �� ��  : InsertHistoryContentEN
 ��������  : ������ʷ�޸ļ�¼Ӣ��˵��
 �������  : hbuf           ��ǰbuf
             ln             ��ǰ�к�
             iHostoryCount  �޸ļ�¼�ı��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro  InsertHistoryContentEN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day
    if (sz2 < 10)
    {
    	szMonth = "0@sz2@"
   	}
   	else
   	{
   		szMonth = sz2
   	}
   	if (sz3 < 10)
    {
    	szDay = "0@sz3@"
   	}
   	else
   	{
   		szDay = sz3
   	}
    szMyName = getreg(MYNAME)
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.Date         : @sz1@@szMonth@@szDay@")

    InsBufLine(hbuf, ln + 2, "    Author       : @szMyName@")
       szContent = Ask("Please input modification")
       CommentContent(hbuf,ln + 3,"    Modification : ",szContent,0)
}

/*****************************************************************************
 �� �� ��  : CreateFunctionDef
 ��������  : ����C����ͷ�ļ�
 �������  : hbuf      
             szName    
             language  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFunctionDef(hbuf, szName, language)
{
    ln = 0

    //��õ�ǰû�к�׺���ļ���
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("������ͷ�ļ���")
        szFileName = GetFileNameNoExt(sz)
        szExt = GetFileNameExt(szFileName)        
        szPreH = toupper (szFileName)
        szPreH = cat("__",szPreH)
        szExt = toupper(szExt)
        szPreH = cat(szPreH,"_@szExt@__")
    }
    szPreH = toupper (szFileName)
    sz = cat(szFileName,".h")
    szPreH = cat("__",szPreH)
    szPreH = cat(szPreH,"_H__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //�������ű�ȡ�ú�����
    SetCurrentBuf(hOutbuf)
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
				szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
			    InsBufLine(hOutbuf, ln, "{")
			    InsBufLine(hOutbuf, ln, "class @szClassName@")
			    ln = ln + 2
		    	while (ichild < cchild)
				{
					childsym = SymListItem(hsyml, ichild)
					childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
		        ln = ln + 2
	        }
            else if( symbol.Type == "Function" )
            {
                ln = CreateFuncPrototype(hbuf,ln,"extern",symbol)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
            
        }
        isym = isym + 1
    }
    InsertCPP(hOutbuf,0)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")
        //�����ļ�ͷ˵��
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")
        //�����ļ�ͷ˵��
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)        
    }
}


/*****************************************************************************
 �� �� ��  : GetLeftWord
 ��������  : ȡ����ߵĵ���
 �������  : szLine    
             ichRight ��ʼȡ��λ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��7��05��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetLeftWord(szLine,ichRight)
{
    if(ich == 0)
    {
        return ""
    }
    ich = ichRight
    while(ich > 0)
    {
        if( (szLine[ich] == " ") || (szLine[ich] == "\t")
            || ( szLine[ich] == ":") || (szLine[ich] == "."))

        {
            ich = ich - 1
            ichRight = ich
        }
        else
        {
            break
        }
    }    
    while(ich > 0)
    {
        if(szLine[ich] == " ")
        {
            ich = ich + 1
            break
        }
        ich = ich - 1
    }
    return strmid(szLine,ich,ichRight)
}
/*****************************************************************************
 �� �� ��  : CreateClassPrototype
 ��������  : ����Class�Ķ���
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��7��05��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateClassPrototype(hbuf,ln,symbol)
{
    isLastLine = 0
    fIsEnd = 1
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf, symbol.lnName)
    sline = symbol.lnFirst     
    szClassName = symbol.Symbol
    ret = strstr(szLine,szClassName)
    if(ret == 0xffffffff)
    {
        return ln
    }
    szPre = strmid(szLine,0,ret)
    szLine = strmid(szLine,symbol.ichName,strlen(szLine))
    szLine = cat(szPre,szLine)
    //ȥ��ע�͵ĸ���
    RetVal = SkipCommentFromString(szLine,fIsEnd)
    fIsEnd = RetVal.fIsEnd
    szNew = RetVal.szContent
    szLine = cat("    ",szLine)
    szNew = cat("    ",szNew)
    while((isLastLine == 0) && (sline < symbol.lnLim))
    {   
        i = 0
        j = 0
        iLen = strlen(szNew)
        while(i < iLen)
        {
            if(szNew[i]=="(")
            {
               j = j + 1;
            }
            else if(szNew[i]==")")
            {
                j = j - 1;
                if(j <= 0)
                {
                    //��������ͷ����
                    isLastLine = 1  
                    //ȥ����������ַ�
        	        szLine = strmid(szLine,0,i+1);
                    szLine = cat(szLine,";")
                    break
                }
            }
            i = i + 1
        }
        InsBufLine(hOutbuf, ln, "@szLine@")
        ln = ln + 1
        sline = sline + 1
        if(isLastLine != 1)
        {              
            //��������ͷ��û�н�����ȡһ��
            szLine = GetBufLine (hbuf, sline)
            //ȥ��ע�͵ĸ���
            RetVal = SkipCommentFromString(szLine,fIsEnd)
	        szNew = RetVal.szContent
	        fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}

/*****************************************************************************
 �� �� ��  : CreateFuncPrototype
 ��������  : ����C����ԭ�Ͷ���
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             szType    ԭ������
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��7��05��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFuncPrototype(hbuf,ln,szType,symbol)
{
    isLastLine = 0
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf,symbol.lnName)
    //ȥ��ע�͵ĸ���
    RetVal = SkipCommentFromString(szLine,fIsEnd)
    szNew = RetVal.szContent
    fIsEnd = RetVal.fIsEnd
    szLine = cat("@szType@ ",szLine)
    szNew = cat("@szType@ ",szNew)
    sline = symbol.lnFirst     
    while((isLastLine == 0) && (sline < symbol.lnLim))
    {   
        i = 0
        j = 0
        iLen = strlen(szNew)
        while(i < iLen)
        {
            if(szNew[i]=="(")
            {
               j = j + 1;
            }
            else if(szNew[i]==")")
            {
                j = j - 1;
                if(j <= 0)
                {
                    //��������ͷ����
                    isLastLine = 1  
                    //ȥ����������ַ�
        	        szLine = strmid(szLine,0,i+1);
                    szLine = cat(szLine,";")
                    break
                }
            }
            i = i + 1
        }
        InsBufLine(hOutbuf, ln, "@szLine@")
        ln = ln + 1
        sline = sline + 1
        if(isLastLine != 1)
        {              
            //��������ͷ��û�н�����ȡһ��
            szLine = GetBufLine (hbuf, sline)
            szLine = cat("         ",szLine)
            //ȥ��ע�͵ĸ���
            RetVal = SkipCommentFromString(szLine,fIsEnd)
	        szNew = RetVal.szContent
	        fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}


/*****************************************************************************
 �� �� ��  : CreateNewHeaderFile
 ��������  : ����һ���µ�ͷ�ļ����ļ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateNewHeaderFile()
{
    hbuf = GetCurrentBuf()
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szName = getreg(MYNAME)
    if(strlen( szName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    ln = 0
    //��õ�ǰû�к�׺���ļ���
    sz = ask("Please input header file name")
    szFileName = GetFileNameNoExt(sz)
    szExt = GetFileNameExt(sz)        
    szPreH = toupper (szFileName)
    szPreH = cat("__",szPreH)
    szExt = toupper(szExt)
    szPreH = cat(szPreH,"_@szExt@__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop

    SetCurrentBuf(hOutbuf)
    InsertCPP(hOutbuf,0)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")

        //�����ļ�ͷ˵��
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")

        //�����ļ�ͷ˵��
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)        
    }

    lnMax = GetBufLineCount(hOutbuf)
    if(lnMax > 9)
    {
        ln = lnMax - 9
    }
    else
    {
        return
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.lnFirst = ln
    sel.ichFirst = 0
    sel.ichLim = 0
    SetBufIns(hOutbuf,ln,0)
    szType = Ask ("Please prototype type : extern or static")
    //�������ű�ȡ�ú�����
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
				szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
			    InsBufLine(hOutbuf, ln, "{")
			    InsBufLine(hOutbuf, ln, "class @szClassName@")
			    ln = ln + 2
		    	while (ichild < cchild)
				{
					childsym = SymListItem(hsyml, ichild)
					childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
		        ln = ln + 2
	        }
            else if( symbol.Type == "Function" )
            {
                ln = CreateFuncPrototype(hbuf,ln,szType,symbol)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
        }
        isym = isym + 1
    }
    sel.lnLast = ln 
    SetWndSel(hwnd,sel)
}


/*   G E T   W O R D   L E F T   O F   I C H   */
/*-------------------------------------------------------------------------
    Given an index to a character (ich) and a string (sz),
    return a "wordinfo" record variable that describes the 
    text word just to the left of the ich.

    Output:
        wordinfo.szWord = the word string
        wordinfo.ich = the first ich of the word
        wordinfo.ichLim = the limit ich of the word
-------------------------------------------------------------------------*/
macro GetWordLeftOfIch(ich, sz)
{
    wordinfo = "" // create a "wordinfo" structure
    
    chTab = CharFromAscii(9)
    
    // scan backwords over white space, if any
    ich = ich - 1;
    if (ich >= 0)
        while (sz[ich] == " " || sz[ich] == chTab)
        {
            ich = ich - 1;
            if (ich < 0)
                break;
        }
    
    // scan backwords to start of word    
    ichLim = ich + 1;
    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    while (ich >= 0)
    {
        ch = toupper(sz[ich])
        asciiCh = AsciiFromChar(ch)
        
/*        if ((asciiCh < asciiA || asciiCh > asciiZ)
             && !IsNumber(ch)
             &&  (ch != "#") )
            break // stop at first non-identifier character
*/
        //ֻ��ȡ�ַ���# { / *��Ϊ����
        if ((asciiCh < asciiA || asciiCh > asciiZ) 
           && !IsNumber(ch)
           && ( ch != "#" && ch != "{" && ch != "/" && ch != "*"))
            break;

        ich = ich - 1;
    }
    
    ich = ich + 1
    wordinfo.szWord = strmid(sz, ich, ichLim)
    wordinfo.ich = ich
    wordinfo.ichLim = ichLim;
    
    return wordinfo
}


/*****************************************************************************
 �� �� ��  : ReplaceBufTab
 ��������  : �滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceBufTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    nBlank = Ask("һ��Tab�滻�����ո�")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)
    ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
}

/*****************************************************************************
 �� �� ��  : ReplaceTabInProj
 ��������  : �������������滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    nBlank = Ask("һ��Tab�滻�����ո�")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)

    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            iTotalLn = GetBufLineCount (hbuf)
            ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
        }
        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : ReplaceInBuf
 ��������  : �滻tabΪ�ո�,ֻ��2.1����Ч
 �������  : hbuf             
             chOld            
             chNew            
             nBeg             
             nEnd             
             fMatchCase       
             fRegExp          
             fWholeWordsOnly  
             fConfirm         
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceInBuf(hbuf,chOld,chNew,nBeg,nEnd,fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    sel.ichLim = 0
    sel.lnLast = 0
    sel.ichFirst = sel.ichLim
    sel.lnFirst = sel.lnLast
    SetWndSel(hwnd, sel)
    LoadSearchPattern(chOld, 0, 0, 0);
    while(1)
    {
        Search_Forward
        selNew = GetWndSel(hwnd)
        if(sel == selNew)
        {
            break
        }
        SetBufSelText(hbuf, chNew)
           selNew.ichLim = selNew.ichFirst 
        SetWndSel(hwnd, selNew)
        sel = selNew
    }
}


/*****************************************************************************
 �� �� ��  : ConfigureSystem
 ��������  : ����ϵͳ
 �������  : ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ConfigureSystem()
{
    szLanguage = ASK("Please select language: 0 Chinese ,1 English");
    if(szLanguage == "#")
    {
       SetReg ("LANGUAGE", "0")
    }
    else
    {
       SetReg ("LANGUAGE", szLanguage)
    }
    
    szName = ASK("Please input your name");
    if(szName == "#")
    {
       SetReg ("MYNAME", "")
    }
    else
    {
       SetReg ("MYNAME", szName)
    }
}

/*****************************************************************************
 �� �� ��  : GetLeftBlank
 ��������  : �õ��ַ�����ߵĿո��ַ���
 �������  : szLine  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetLeftBlank(szLine)
{
    nIdx = 0
    nEndIdx = strlen(szLine)
    while( nIdx < nEndIdx )
    {
        if( (szLine[nIdx] !=" ") && (szLine[nIdx] !="\t") )
        {
            break;
        }
        nIdx = nIdx + 1
    }
    return nIdx
}

/*****************************************************************************
 �� �� ��  : ExpandBraceLittle
 ��������  : С������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLittle()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast) 
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "(  )")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 2)    
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)    
        SetBufSelText (hbuf, "( ")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 2)    
        SetBufSelText (hbuf, " )")
    }
    
}

/*****************************************************************************
 �� �� ��  : ExpandBraceMid
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceMid()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast) 
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "[]")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 1)    
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)    
        SetBufSelText (hbuf, "[")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 1)    
        SetBufSelText (hbuf, "]")
    }
    
}

/*****************************************************************************
 �� �� ��  : ExpandBraceLarge
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��18��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLarge()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    nlineCount = 0
    retVal = ""
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    szRight = ""
    szMid = ""
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        //����û�п�ѡ��������ֱ�Ӳ���{}����
        if( nLeft == strlen(szLine) )
        {
            SetBufSelText (hbuf, "{")
        }
        else
        {    
            ln = ln + 1        
            InsBufLine(hbuf, ln, "@szLeft@{")     
            nlineCount = nlineCount + 1

        }
        InsBufLine(hbuf, ln + 1, "@szLeft@    ")
        InsBufLine(hbuf, ln + 2, "@szLeft@}")
        nlineCount = nlineCount + 2
        SetBufIns (hbuf, ln + 1, strlen(szLeft)+4)
    }
    else
    {
        //�����п�ѡ���������ÿ��ǽ���ѡ�����ֿ���
        
        //���ѡ�������Ƿ��������ԣ������̫����ע�͵�������ж�
        RetVal= CheckBlockBrace(hbuf)
        if(RetVal.iCount != 0)
        {
            msg("Invalidated brace number")
            stop
        }
        
        //ȡ��ѡ����ǰ������
        szOld = strmid(szLine,0,sel.ichFirst)
        if(sel.lnFirst != sel.lnLast)
        {
            //���ڶ��е����
            
            //��һ�е�ѡ�в���
            szMid = strmid(szLine,sel.ichFirst,strlen(szLine))
            szMid = TrimString(szMid)
            szLast = GetBufLine(hbuf,sel.lnLast)
            if( sel.ichLim > strlen(szLast) )
            {
                //���ѡ�������ȴ��ڸ��еĳ��ȣ����ȡ���еĳ���
                szLineselichLim = strlen(szLast)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            
            //�õ����һ��ѡ����Ϊ���ַ�
            szRight = strmid(szLast,szLineselichLim,strlen(szLast))
            szRight = TrimString(szRight)
        }
        else
        {
            //����ѡ��ֻ��һ�е����
             if(sel.ichLim >= strlen(szLine))
             {
                 sel.ichLim = strlen(szLine)
             }
             
             //���ѡ����������
             szMid = strmid(szLine,sel.ichFirst,sel.ichLim)
             szMid = TrimString(szMid)            
             if( sel.ichLim > strlen(szLine) )
             {
                 szLineselichLim = strlen(szLine)
             }
             else
             {
                 szLineselichLim = sel.ichLim
             }
             
             //ͬ���õ�ѡ�����������
             szRight = strmid(szLine,szLineselichLim,strlen(szLine))
             szRight = TrimString(szRight)
        }
        nIdx = sel.lnFirst
        while( nIdx < sel.lnLast)
        {
            szCurLine = GetBufLine(hbuf,nIdx+1)
            if( sel.ichLim > strlen(szCurLine) )
            {
                szLineselichLim = strlen(szCurLine)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            szCurLine = cat("    ",szCurLine)
            if(nIdx == sel.lnLast - 1)
            {
                //�������һ��Ӧ����ѡ�����ڵ����ݺ�����λ
                szCurLine = strmid(szCurLine,0,szLineselichLim + 4)
                PutBufLine(hbuf,nIdx+1,szCurLine)                    
            }
            else
            {
                //������������е����ݺ�����λ
                PutBufLine(hbuf,nIdx+1,szCurLine)
            }
            nIdx = nIdx + 1
        }
        if(strlen(szRight) != 0)
        {
            //���������һ��û�б�ѡ�������
            InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@@szRight@")        
        }
        InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@}")        
        nlineCount = nlineCount + 1
        if(nLeft < sel.ichFirst)
        {
            //���ѡ����ǰ�����ݲ��ǿո���Ҫ�����ò�������
            PutBufLine(hbuf,ln,szOld)
            InsBufLine(hbuf, ln+1, "@szLeft@{")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }
        else
        {
            //���ѡ����ǰû������ֱ��ɾ������
            DelBufLine(hbuf,ln)
            InsBufLine(hbuf, ln, "@szLeft@{")
        }
        if(strlen(szMid) > 0)
        {
            //�����һ��ѡ����������
            InsBufLine(hbuf, ln+1, "@szLeft@    @szMid@")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }        
    }
    retVal.szLeft = szLeft
    retVal.nLineCount = nlineCount
    //������������ߵĿհ�
    return retVal
}

/*
macro ScanStatement(szLine,iBeg)
{
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen -1)
    {
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "/")
        {
            return 0xffffffff
        }
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "*")
        {
           while(nIdx < iLen)
           {
               if(szLine[nIdx] == "*" && szLine[nIdx + 1] == "/")
               {
                   break
               }
               nIdx = nIdx + 1
               
           }
        }
        if( (szLine[nIdx] != " ") && (szLine[nIdx] != "\t" ))
        {
            return nIdx
        }
        nIdx = nIdx + 1
    }
    if( (szLine[iLen -1] == " ") || (szLine[iLen -1] == "\t" ))
    {
        return 0xffffffff
    }
    return nIdx
}
*/
/*
macro MoveCommentLeftBlank(szLine)
{
    nIdx  = 0
    iLen = strlen(szLine)
    while(nIdx < iLen - 1)
    { 
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "*")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "*"
                    return szLine
                }
                nIdx = nIdx + 1
            }
        
        }
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "/"
                    return szLine
                }
                nIdx = nIdx + 1
            }
        
        }
        nIdx = nIdx + 1
    }
    return szLine
}*/

/*****************************************************************************
 �� �� ��  : DelCompoundStatement
 ��������  : ɾ��һ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro DelCompoundStatement()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine(hbuf,ln )
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    Msg("@szLine@  will be deleted !")
    fIsEnd = 1
    while(1)
    {
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //���Ҹ������Ŀ�ʼ
        ret = strstr(szTmp,"{")
        if(ret != 0xffffffff)
        {
            szNewLine = strmid(szLine,ret+1,strlen(szLine))
            szNew = strmid(szTmp,ret+1,strlen(szTmp))
            szNew = TrimString(szNew)
            if(szNew != "")
            {
                InsBufLine(hbuf,ln + 1,"@szLeft@    @szNewLine@");
            }
            sel.lnFirst = ln
            sel.lnLast = ln
            sel.ichFirst = ret
            sel.ichLim = ret
            //���Ҷ�Ӧ�Ĵ�����
            
            //ʹ���Լ���д�Ĵ����ٶ�̫��
            retTmp = SearchCompoundEnd(hbuf,ln,ret)
            if(retTmp.iCount == 0)
            {
                
                DelBufLine(hbuf,retTmp.ln)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = retTmp.ln - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }
            
            //ʹ��Si�Ĵ�������Է�������V2.1ʱ��ע��Ƕ��ʱ��������
/*            SetWndSel(hwnd,sel)
            Block_Down
            selNew = GetWndSel(hwnd)
            if(selNew != sel)
            {
                
                DelBufLine(hbuf,selNew.lnFirst)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = selNew.lnFirst - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }*/
            break
        }
        szTmp = TrimString(szTmp)
        iLen = strlen(szTmp)
        if(iLen != 0)
        {
            if(szTmp[iLen-1] == ";")
            {
                break
            }
        }
        DelBufLine(hbuf,ln)   
        if( ln == GetBufLineCount(hbuf ))
        {
             break
        }
        szLine = GetBufLine(hbuf,ln)
    }
}

/*****************************************************************************
 �� �� ��  : CheckBlockBrace
 ��������  : ��ⶨ����еĴ�����������
 �������  : hbuf  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBlockBrace(hbuf)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    RetVal = ""
    szLine = GetBufLine( hbuf, ln )    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        RetVal.iCount = 0
        RetVal.ich = sel.ichFirst
        return RetVal
    }
    if(sel.lnFirst == sel.lnLast && sel.ichFirst != sel.ichLim)
    {
        RetTmp = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetTmp.szContent
        RetVal = CheckBrace(szTmp,sel.ichFirst,sel.ichLim,"{","}",0,1)
        return RetVal
    }
    if(sel.lnFirst != sel.lnLast)
    {
	    fIsEnd = 1
	    while(ln <= sel.lnLast)
	    {
	        if(ln == sel.lnFirst)
	        {
	            RetVal = CheckBrace(szLine,sel.ichFirst,strlen(szLine)-1,"{","}",nCount,fIsEnd)
	        }
	        else if(ln == sel.lnLast)
	        {
	            RetVal = CheckBrace(szLine,0,sel.ichLim,"{","}",nCount,fIsEnd)
	        }
	        else
	        {
	            RetVal = CheckBrace(szLine,0,strlen(szLine)-1,"{","}",nCount,fIsEnd)
	        }
	        fIsEnd = RetVal.fIsEnd
	        ln = ln + 1
	        nCount = RetVal.iCount
	        szLine = GetBufLine( hbuf, ln )    
	    }
    }
    return RetVal
}

/*****************************************************************************
 �� �� ��  : SearchCompoundEnd
 ��������  : ����һ���������Ľ�����
 �������  : hbuf    
             ln      ��ѯ��ʼ��
             ichBeg  ��ѯ��ʼ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchCompoundEnd(hbuf,ln,ichBeg)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    SearchVal = ""
//    szLine = GetBufLine( hbuf, ln )
    lnMax = GetBufLineCount(hbuf)
    fIsEnd = 1
    while(ln < lnMax)
    {
        szLine = GetBufLine( hbuf, ln )
        RetVal = CheckBrace(szLine,ichBeg,strlen(szLine)-1,"{","}",nCount,fIsEnd)
        fIsEnd = RetVal.fIsEnd
        ichBeg = 0
        nCount = RetVal.iCount
        
        //���nCount=0��˵��{}����Ե�
        if(nCount == 0)
        {
            break
        }
        ln = ln + 1
//        szLine = GetBufLine( hbuf, ln )    
    }
    SearchVal.iCount = RetVal.iCount
    SearchVal.ich = RetVal.ich
    SearchVal.ln = ln
    return SearchVal
}

/*****************************************************************************
 �� �� ��  : CheckBrace
 ��������  : ������ŵ�������
 �������  : szLine       �����ַ���
             ichBeg       �����ʼ
             ichEnd       ������
             chBeg        ��ʼ�ַ�(������)
             chEnd        �����ַ�(������)
             nCheckCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBrace(szLine,ichBeg,ichEnd,chBeg,chEnd,nCheckCount,isCommentEnd)
{
    retVal = ""
    retVal.ich = 0
    nIdx = ichBeg
    nLen = strlen(szLine)
    if(ichEnd >= nLen)
    {
        ichEnd = nLen - 1
    }
    fIsEnd = 1
    while(nIdx <= ichEnd)
    {
        //�����/*ע�����������ö�
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx <= ichEnd )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                nIdx = nIdx + 1 
            }
            if(nIdx > ichEnd)
            {
                break
            }
        }
        //�����//ע����ֹͣ����
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            break
        }
        if(szLine[nIdx] == chBeg)
        {
            nCheckCount = nCheckCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            nCheckCount = nCheckCount - 1
            if(nCheckCount == 0)
            {
                retVal.ich = nIdx
            }
        }
        nIdx = nIdx + 1
    }
    retVal.iCount = nCheckCount
    retVal.fIsEnd = fIsEnd
    return retVal
}

/*****************************************************************************
 �� �� ��  : InsertElse
 ��������  : ����else���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertElse()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@else")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    ")
        SetBufIns (hbuf, ln+2, strlen(szLeft)+4)
        return
    }
    SetBufIns (hbuf, ln, strlen(szLeft)+7)
}

/*****************************************************************************
 �� �� ��  : InsertCase
 ��������  : ����case���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCase()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@" # "case # :")
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "    " # "#")
    InsBufLine(hbuf, ln + 2, "@szLeft@" # "    " # "break;")
    SearchForward()    
}

/*****************************************************************************
 �� �� ��  : InsertSwitch
 ��������  : ����swich���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertSwitch()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@switch ( # )")    
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "{")
    nSwitch = ask("������case�ĸ���")
    InsertMultiCaseProc(hbuf,szLeft,nSwitch)
    SearchForward()    
}

/*****************************************************************************
 �� �� ��  : InsertMultiCaseProc
 ��������  : ������case
 �������  : hbuf     
             szLeft   
             nSwitch  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertMultiCaseProc(hbuf,szLeft,nSwitch)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst

    nIdx = 0
    if(nSwitch == 0)
    {
        hNewBuf = newbuf("clip")
        if(hNewBuf == hNil)
            return       
        SetCurrentBuf(hNewBuf)
        PasteBufLine (hNewBuf, 0)
        nLeftMax = 0
        lnMax = GetBufLineCount(hNewBuf )
        i = 0
        fIsEnd = 1
        while ( i < lnMax) 
        {
            szLine = GetBufLine(hNewBuf , i)
            //��ȥ��������ע�͵�����
            RetVal = SkipCommentFromString(szLine,fIsEnd)
            szLine = RetVal.szContent
            fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
            //�Ӽ�������ȡ��caseֵ
            szLine = GetSwitchVar(szLine)
            if(strlen(szLine) != 0 )
            {
                ln = ln + 3
                InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case @szLine@:")
                InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # "#")
                InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
              }
              i = i + 1
        }
        closebuf(hNewBuf)
       }
       else
       {
        while(nIdx < nSwitch)
        {
            ln = ln + 3
            InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case # :")
            InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # "#")
            InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
            nIdx = nIdx + 1
        }
      }
    InsBufLine(hbuf, ln + 2, "@szLeft@    " # "default:")
    InsBufLine(hbuf, ln + 3, "@szLeft@    " # "    " # "#")
    InsBufLine(hbuf, ln + 4, "@szLeft@" # "}")
    SetWndSel(hwnd, sel)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : GetSwitchVar
 ��������  : ��ö�١��궨��ȡ��caseֵ
 �������  : szLine  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetSwitchVar(szLine)
{
    if( (szLine == "{") || (szLine == "}") )
    {
        return ""
    }
    ret = strstr(szLine,"#define" )
    if(ret != 0xffffffff)
    {
        szLine = strmid(szLine,ret + 8,strlen(szLine))
    }
    szLine = TrimLeft(szLine)
    nIdx = 0
    nLen = strlen(szLine)
    while( nIdx < nLen)
    {
        if((szLine[nIdx] == " ") || (szLine[nIdx] == ",") || (szLine[nIdx] == "="))
        {
            szLine = strmid(szLine,0,nIdx)
            return szLine
        }
        nIdx = nIdx + 1
    }
    return szLine
}

/*
macro SkipControlCharFromString(szLine)
{
   nLen = strlen(szLine)
   nIdx = 0
   newStr = ""
   while(nIdx < nLen - 1)
   {
       if(szLine[nIdx] == "\t")
       {
           newStr = cat(newStr,"    ")
       }
       else if(szLine[nIdx] < " ")
       {
           newStr = cat(newStr," ")           
       }
       else
       {
           newStr = cat(newStr," ")                      
       }
   }
}
*/
/*****************************************************************************
 �� �� ��  : SkipCommentFromString
 ��������  : ȥ��ע�͵����ݣ���ע��������Ϊ�ո�
 �������  : szLine        �����е�����
             isCommentEnd  �Ƿ�ǰ�еĿ�ʼ�Ѿ���ע�ͽ�����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen )
    {
        //�����ǰ�п�ʼ���Ǳ�ע�ͣ���������ע�Ϳ�ʼ�ı��ǣ�ע�����ݸ�Ϊ�ո�
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx < nLen )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    szLine[nIdx+1] = " "
                    szLine[nIdx] = " " 
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                szLine[nIdx] = " "
                
                //����ǵ����ڶ��������һ��Ҳ�϶�����ע����
//                if(nIdx == nLen -2 )
//                {
//                    szLine[nIdx + 1] = " "
//                }
                nIdx = nIdx + 1 
            }    
            
            //����Ѿ�������β��ֹ����
            if(nIdx == nLen)
            {
                break
            }
        }
        
        //�����������//��ע�͵�˵�����涼Ϊע��
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine = strmid(szLine,0,nIdx)
            break
        }
        nIdx = nIdx + 1                
    }
    RetVal.szContent = szLine;
    RetVal.fIsEnd = fIsEnd
    return RetVal
}

/*****************************************************************************
 �� �� ��  : InsertDo
 ��������  : ����Do���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertDo()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+1, "@szLeft@    #")
    }
    PutBufLine(hbuf, sel.lnLast + val.nLineCount, "@szLeft@}while ( # );")    
//       SetBufIns (hbuf, sel.lnLast + val.nLineCount, strlen(szLeft)+8)
    InsBufLine(hbuf, ln, "@szLeft@do")    
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertWhile
 ��������  : ����While���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertWhile()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@while ( # )")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
    SetBufIns (hbuf, ln, strlen(szLeft)+7)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertFor
 ��������  : ����for���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFor()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln,"@szLeft@for ( # ; # ; # )")
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
    sel.lnFirst = ln
    sel.lnLast = ln 
    sel.ichFirst = 0
    sel.ichLim = 0
    SetWndSel(hwnd, sel)
    SearchForward()
    szVar = ask("������ѭ������")
    PutBufLine(hbuf,ln, "@szLeft@for ( @szVar@ = # ; @szVar@ # ; @szVar@++ )")
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertIf
 ��������  : ����If���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertIf()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@if ( # )")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
//       SetBufIns (hbuf, ln, strlen(szLeft)+4)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : MergeString
 ��������  : ���������е����ϲ���һ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro MergeString()
{
    hbuf = newbuf("clip")
    if(hbuf == hNil)
        return       
    SetCurrentBuf(hbuf)
    PasteBufLine (hbuf, 0)
    
    //�����������û�����ݣ��򷵻�
    lnMax = GetBufLineCount(hbuf )
    if( lnMax == 0 )
    {
        closebuf(hbuf)
        return ""
    }
    lnLast =  0
    if(lnMax > 1)
    {
        lnLast = lnMax - 1
         i = lnMax - 1
    }
    while ( i > 0) 
    {
        szLine = GetBufLine(hbuf , i-1)
        szLine = TrimLeft(szLine)
        nLen = strlen(szLine)
        if(szLine[nLen - 1] == "-")
        {
              szLine = strmid(szLine,0,nLen - 1)
        }
        nLen = strlen(szLine)
        if( (szLine[nLen - 1] != " ") && (AsciiFromChar (szLine[nLen - 1])  <= 160))
        {
              szLine = cat(szLine," ") 
        }
        SetBufIns (hbuf, lnLast, 0)
        SetBufSelText(hbuf,szLine)
        i = i - 1
    }
    szLine = GetBufLine(hbuf,lnLast)
    closebuf(hbuf)
    return szLine
}

/*****************************************************************************
 �� �� ��  : ClearPrombleNo
 ��������  : ������ⵥ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ClearPrombleNo()
{
   SetReg ("PNO", "")
}

/*****************************************************************************
 �� �� ��  : AddPromblemNo
 ��������  : ������ⵥ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AddPromblemNo()
{
    szQuestion = ASK("Please Input problem number ");
    if(szQuestion == "#")
    {
       szQuestion = ""
       SetReg ("PNO", "")
    }
    else
    {
       SetReg ("PNO", szQuestion)
    }
    return szQuestion
}

/*
this macro convet selected  C++ coment block to C comment block 
for example:
  line "  // aaaaa "
  convert to  /* aaaaa */
*/
/*macro ComentCPPtoC()
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnLast = GetWndSelLnLast( hwnd )

    lnCurrent = lnFirst
    fIsEnd = 1
    while ( lnCurrent <= lnLast )
    {
        fIsEnd = CmtCvtLine( lnCurrent,fIsEnd )
        lnCurrent = lnCurrent + 1;
    }
}*/

/*****************************************************************************
 �� �� ��  : ComentCPPtoC
 ��������  : ת��C++ע��ΪCע��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��7��02��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���,֧�ֿ�ע��

*****************************************************************************/
macro ComentCPPtoC()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
    ch_comment = CharFromAscii(47)   
    isCommentEnd = 1
    isCommentContinue = 0
    while ( lnCurrent <= lnLast )
    {

        ich = 0
        szLine = GetBufLine(hbuf,lnCurrent)
        ilen = strlen(szLine)
        while ( ich < ilen )
        {
            if( (szLine[ich] != " ") && (szLine[ich] != "\t") )
            {
                break
            }
            ich = ich + 1
        }
        /*����ǿ��У���������*/
        if(ich == ilen)
        {         
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }
        
        /*�������ֻ��һ���ַ�*/
        if(ich > ilen - 2)
        {
            if( isCommentContinue == 1 )
            {
                szOldLine = cat(szOldLine,"  */")
                PutBufLine(hbuf,lnCurrent-1,szOldLine)
                isCommentContinue = 0
            }
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }       
        if( isCommentEnd == 1 )
        {
            /*���������ע������*/
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                
                /* ȥ���м�Ƕ�׵�ע�� */
                nIdx = ich + 2
                while ( nIdx < ilen -1 )
                {
                    if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                         ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                    {
                        szLine[nIdx] = " "
                        szLine[nIdx+1] = " "
                    }
                    nIdx = nIdx + 1
                }
                
                if( isCommentContinue == 1 )
                {
                    /* �����������ע��*/
                    szLine[ich] = " "
                    szLine[ich+1] = " "
                }
                else
                {
                    /*�������������ע��������ע�͵Ŀ�ʼ*/
                    szLine[ich] = "/"
                    szLine[ich+1] = "*"
                }
                if ( lnCurrent == lnLast )
                {
                    /*��������һ��������β��ӽ���ע�ͷ�*/
                    szLine = cat(szLine,"  */")
                    isCommentContinue = 0
                }
                /*���¸���*/
                PutBufLine(hbuf,lnCurrent,szLine)
                isCommentContinue = 1
                szOldLine = szLine
                lnCurrent = lnCurrent + 1
                continue 
            }
            else
            {   
                /*������е���ʼ����//ע��*/
                if( isCommentContinue == 1 )
                {
                    szOldLine = cat(szOldLine,"  */")
                    PutBufLine(hbuf,lnCurrent-1,szOldLine)
                    isCommentContinue = 0
                }
            }        
        }
        while ( ich < ilen - 1 )
        {
            //�����/*ע�����������ö�
            if( (isCommentEnd == 0) || (szLine[ich] == "/" && szLine[ich+1] == "*"))
            {
                isCommentEnd = 0
                while(ich < ilen - 1 )
                {
                    if(szLine[ich] == "*" && szLine[ich+1] == "/")
                    {
                        ich = ich + 1 
                        isCommentEnd = 1
                        break
                    }
                    ich = ich + 1 
                }
                if(ich >= ilen - 1)
                {
                    break
                }
            }
            
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                /* �����//ע��*/
                isCommentContinue = 1
                nIdx = ich
                //ȥ���ڼ��/* �� */ע�ͷ��������ע��Ƕ�״���
                while ( nIdx < ilen -1 )
                {
                    if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                         ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                    {
                        szLine[nIdx] = " "
                        szLine[nIdx+1] = " "
                    }
                    nIdx = nIdx + 1
                }
                szLine[ich+1] = "*"
                if( lnCurrent == lnLast )
                {
                    szLine = cat(szLine,"  */")
                }
                PutBufLine(hbuf,lnCurrent,szLine)
                break
            }
            ich = ich + 1
        }
        szOldLine = szLine
        lnCurrent = lnCurrent + 1
    }
}


macro ComentLine()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
    lnOld = 0
    while ( lnCurrent <= lnLast )
    {
        szLine = GetBufLine(hbuf,lnCurrent)
        DelBufLine(hbuf,lnCurrent)
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if(iLen == 0)
        {
            continue
        }
        nIdx = 0
        //ȥ���ڼ��/* �� */ע�ͷ��������ע��Ƕ�״���
        while ( nIdx < ilen -1 )
        {
            if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                 ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
            {
                szLine[nIdx] = " "
                szLine[nIdx+1] = " "
            }
            nIdx = nIdx + 1
        }
        szLine = cat("/* ",szLine)
        lnOld = lnCurrent
        lnCurrent = CommentContent(hbuf,lnCurrent,szLeft,szLine,1)
        lnLast = lnCurrent - lnOld + lnLast
        lnCurrent = lnCurrent + 1
    }
}

/*****************************************************************************
 �� �� ��  : CmtCvtLine
 ��������  : ��//ת����/*ע��
 �������  : lnCurrent  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 
    ��    ��   : 
    �޸�����   : 

  2.��    ��   : 2008��7��02��
    ��    ��   : ��ǿ
    �޸�����   : �޸���ע��Ƕ��������������

*****************************************************************************/
macro CmtCvtLine(lnCurrent, isCommentEnd)
{
    hbuf = GetCurrentBuf()
    szLine = GetBufLine(hbuf,lnCurrent)
    ch_comment = CharFromAscii(47)   
    ich = 0
    ilen = strlen(szLine)
    
    fIsEnd = 1
    iIsComment = 0;
    
    while ( ich < ilen - 1 )
    {
        //�����/*ע�����������ö�
        if( (isCommentEnd == 0) || (szLine[ich] == "/" && szLine[ich+1] == "*"))
        {
            fIsEnd = 0
            while(ich < ilen - 1 )
            {
                if(szLine[ich] == "*" && szLine[ich+1] == "/")
                {
                    ich = ich + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                ich = ich + 1 
            }
            if(ich >= ilen - 1)
            {
                break
            }
        }
        if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
        {
            nIdx = ich
            while ( nIdx < ilen -1 )
            {
                if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                     ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                {
                    szLine[nIdx] = " "
                    szLine[nIdx+1] = " "
                }
                nIdx = nIdx + 1
            }
            szLine[ich+1] = "*"
            szLine = cat(szLine,"  */")
            DelBufLine(hbuf,lnCurrent)
            InsBufLine(hbuf,lnCurrent,szLine)
            return fIsEnd
        }
        ich = ich + 1
    }
    return fIsEnd
}

/*****************************************************************************
 �� �� ��  : GetFileNameExt
 ��������  : �õ��ļ���չ��
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameExt(sz)
{
    i = 1
    j = 0
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
         szExt = strmid(sz,j + 1,iLen)
         return szExt
      }
      i = i + 1
    }
    return ""
}

/*****************************************************************************
 �� �� ��  : GetFileNameNoExt
 ��������  : �õ�������û����չ��
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameNoExt(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    j = iLen 
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
      }
      if( sz[iLen-i] == "\\" )
      {
         szName = strmid(sz,iLen-i+1,j)
         return szName
      }
      i = i + 1
    }
    szName = strmid(sz,0,j)
    return szName
}

/*****************************************************************************
 �� �� ��  : GetFileName
 ��������  : �õ�����չ�����ļ���
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == "\\")
      {
        szName = strmid(sz,iLen-i+1,iLen)
        break
      }
      i = i + 1
    }
    return szName
}

/*****************************************************************************
 �� �� ��  : InsIfdef
 ��������  : ����#ifdef���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsIfdef()
{
    sz = Ask("Enter #ifdef condition:")
    if (sz != "")
        IfdefStr(sz);
}

/*****************************************************************************
 �� �� ��  : InsIfndef
 ��������  : ��ifndef���Բ������ڵ��ú�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsIfndef()
{
    sz = Ask("Enter #ifndef condition:")
    if (sz != "")
        IfndefStr(sz);
}

/*****************************************************************************
 �� �� ��  : InsertCPP
 ��������  : ��buf�в���C���Ͷ���
 �������  : hbuf  
             ln    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCPP(hbuf,ln)
{
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "#endif /* __cplusplus */")
    InsBufLine(hbuf, ln, "#endif")
    InsBufLine(hbuf, ln, "extern \"C\"{")
    InsBufLine(hbuf, ln, "#if __cplusplus")
    InsBufLine(hbuf, ln, "#ifdef __cplusplus")
    InsBufLine(hbuf, ln, "")
    
    iTotalLn = GetBufLineCount (hbuf)            
    InsBufLine(hbuf, iTotalLn, "")
    InsBufLine(hbuf, iTotalLn, "#endif /* __cplusplus */")
    InsBufLine(hbuf, iTotalLn, "#endif")
    InsBufLine(hbuf, iTotalLn, "}")
    InsBufLine(hbuf, iTotalLn, "#if __cplusplus")
    InsBufLine(hbuf, iTotalLn, "#ifdef __cplusplus")
    InsBufLine(hbuf, iTotalLn, "")
}

/*****************************************************************************
 �� �� ��  : ReviseCommentProc
 ��������  : ���ⵥ�޸������
 �������  : hbuf      
             ln        
             szCmd     
             szMyName  
             szLine1   
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReviseCommentProc(hbuf,ln,szCmd,szMyName,szLine1)
{
    if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@-@szMonth@-@szDay@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        if(strlen(szLeft) > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* add end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln + 0)
        InsBufLine(hbuf, ln, "@szLine1@/* delete end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        if (sz1 < 10)
        {
        	szMonth = "0@sz1@"
       	}
       	else
       	{
       		szMonth = sz1
       	}
       	if (sz3 < 10)
        {
        	szDay = "0@sz3@"
       	}
       	else
       	{
       		szDay = sz3
       	}

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* modify end by @szMyName@, @sz@-@szMonth@-@szDay@ */");
        return
    }
}

/*****************************************************************************
 �� �� ��  : InsertReviseAdd
 ��������  : ��������޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseAdd()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if (sz1 < 10)
    {
    	szMonth = "0@sz1@"
   	}
   	else
   	{
   		szMonth = sz1
   	}
   	if (sz3 < 10)
    {
    	szDay = "0@sz3@"
   	}
   	else
   	{
   		szDay = sz3
   	}
   	
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ */");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* add begin by @szMyName@, @sz@-@szMonth@-@szDay@ */";        
    }

    if(sel.lnLast < lnMax - 1)
    {
        InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* add end by @szMyName@, @sz@-@szMonth@-@szDay@ */");            
    }
    else
    {
        AppendBufLine(hbuf, "@szLeft@/* add end by @szMyName@, @sz@-@szMonth@-@szDay@ */");                        
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseDel
 ��������  : ����ɾ���޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseDel()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if (sz1 < 10)
    {
    	szMonth = "0@sz1@"
   	}
   	else
   	{
   		szMonth = sz1
   	}
   	if (sz3 < 10)
    {
    	szDay = "0@sz3@"
   	}
   	else
   	{
   		szDay = sz3
   	}
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@*/");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* delete begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");        
    }

    if(sel.lnLast < lnMax - 1)
    {
        InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* delete end by @szMyName@, @sz@-@szMonth@-@szDay@ */");            
    }
    else
    {
        AppendBufLine(hbuf, "@szLeft@/* delete end by @szMyName@, @sz@-@szMonth@-@szDay@ */");                        
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseMod
 ��������  : �����޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseMod()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if (sz1 < 10)
    {
    	szMonth = "0@sz1@"
   	}
   	else
   	{
   		szMonth = sz1
   	}
   	if (sz3 < 10)
    {
    	szDay = "0@sz3@"
   	}
   	else
   	{
   		szDay = sz3
   	}
   	//�õ������ѡ���ַ����Ŀհײ��֣�������szLeft��,Ŀ���Ǳ�֤����
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@, Mantis��:@szQuestion@ */");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* modify begin by @szMyName@, @sz@-@szMonth@-@szDay@ */");        
    }

    if(sel.lnLast < lnMax - 1)
    {
        InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* modify end by @szMyName@, @sz@-@szMonth@-@szDay@ */");            
    }
    else
    {
        AppendBufLine(hbuf, "@szLeft@/* modif end by @szMyName@, @sz@-@szMonth@-@szDay@ */");                        
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

// Wrap ifdef <sz> .. endif around the current selection
macro IfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifdef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : IfndefStr
 ��������  : ���룣ifndef����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro IfndefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifndef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


/*****************************************************************************
 �� �� ��  : InsertPredefIf
 ��������  : ���룣if���Ե���ڵ��ú�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertPredefIf()
{
    sz = Ask("Enter #if condition:")
    PredefIfStr(sz)
}

/*****************************************************************************
 �� �� ��  : PredefIfStr
 ��������  : ��ѡ����ǰ����룣if����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro PredefIfStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* #if @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#if  @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


/*****************************************************************************
 �� �� ��  : HeadIfdefStr
 ��������  : ��ѡ����ǰ�����#ifdef����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro HeadIfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    hbuf = GetCurrentBuf()
    InsBufLine(hbuf, lnFirst, "")
    InsBufLine(hbuf, lnFirst, "#define @sz@")
    InsBufLine(hbuf, lnFirst, "#ifndef @sz@")
    iTotalLn = GetBufLineCount (hbuf)                
    InsBufLine(hbuf, iTotalLn, "#endif /* @sz@ */")
    InsBufLine(hbuf, iTotalLn, "")
}

/*****************************************************************************
 �� �� ��  : GetSysTime
 ��������  : ȡ��ϵͳʱ�䣬ֻ��V2.1ʱ����
 �������  : a  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��24��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetSysTime(a)
{
    //��sidateȡ��ʱ��
    RunCmd ("sidate")
    SysTime=""
    SysTime.Year=getreg(Year)
    if(strlen(SysTime.Year)==0)
    {
        setreg(Year,"2008")
        setreg(Month,"05")
        setreg(Day,"02")
        SysTime.Year="2008"
        SysTime.month="05"
        SysTime.day="20"
        SysTime.Date="2008��05��20��"
    }
    else
    {
        SysTime.Month=getreg(Month)
        SysTime.Day=getreg(Day)
        SysTime.Date=getreg(Date)
   /*         SysTime.Date=cat(SysTime.Year,"��")
        SysTime.Date=cat(SysTime.Date,SysTime.Month)
        SysTime.Date=cat(SysTime.Date,"��")
        SysTime.Date=cat(SysTime.Date,SysTime.Day)
        SysTime.Date=cat(SysTime.Date,"��")*/
    }
    return SysTime
}

/*****************************************************************************
 �� �� ��  : HeaderFileCreate
 ��������  : ����ͷ�ļ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro HeaderFileCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }

   CreateFunctionDef(hbuf,szMyName,language)
}

/*****************************************************************************
 �� �� ��  : FunctionHeaderCreate
 ��������  : ���ɺ���ͷ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FunctionHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nVer = GetVersion()
    lnMax = GetBufLineCount(hbuf)
    if(ln != lnMax)
    {
        szNextLine = GetBufLine(hbuf,ln)
        if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2 ))
        {
            symbol = GetCurSymbol()
            if(strlen(symbol) != 0)
            {  
                if(language == 0)
                {
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                }
                else
                {                
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                }
                return
            }
        }
    }
    if(language == 0 )
    {
        szFuncName = Ask("�����뺯������:")
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else
    {
        szFuncName = Ask("Please input function name")
           FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    
    }
}

/*****************************************************************************
 �� �� ��  : GetVersion
 ��������  : �õ�Si�İ汾��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetVersion()
{
   Record = GetProgramInfo ()
   return Record.versionMajor
}

/*****************************************************************************
 �� �� ��  : GetProgramInfo
 ��������  : ��ó�����Ϣ��V2.1����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetProgramInfo ()
{   
    Record = ""
    Record.versionMajor     = 2
    Record.versionMinor    = 1
    return Record
}

/*****************************************************************************
 �� �� ��  : FileHeaderCreate
 ��������  : �����ļ�ͷ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��6��19��
    ��    ��   : ��ǿ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FileHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    ln = 0
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
       SetBufIns (hbuf, 0, 0)
    if(language == 0)
    {
        InsertFileHeaderCN( hbuf,ln, szMyName,"" )
    }
    else
    {
        InsertFileHeaderEN( hbuf,ln, szMyName,"" )
    }
}

