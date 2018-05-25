
/** @file doxygen_chinese_utils.em
  * @note HangZhou Hikvision Digital Technology Co., Ltd. All Right Reserved.
  * @brief    Doxygen宏 和 支持中文显示与操作的宏,字体颜色之类的注释说明未完成
  * 
  * @author   liuboyf1
  * @date     2012-10-26
  * @version  V1.0.0
  * 
  * @note ///Description here 
  * @note History:    
  * @note     <author>   <time>      <version >   <desc>
  * @note     liuboyf1   2012-10-26  V1.0.0       创建了配置文件并修改了注释
  * @warning  
  */

/**
  * -------Source Insight3 中文操作(左右键、删除和后退键）支持宏-------
  * 用原来作者提供的方法使用工程中有的问题，于是换了种方式试了一下，测试OK，
  * 现在只需按照下面的说明①--③应用即可，已经测试OK
  * 感谢丁兆杰（zhaojie.ding@gmail.com）及互联网上辛勤耕耘的朋友们！！！  
  *
  * ① Project→Open Project，打开Base项目，将所有宏函数复制到utils.em文件的最后
  * ② 重启SourceInsight；
  * ③ Options→Key Assignments，将下面宏依次与相应按键绑定：
          Marco: SuperBackspace绑定到BackSpace键；
          Marco: SuperCursorLeft绑定到<-键，
          Marco: SuperCursorRight绑定到->键，
          Marco: SuperShiftCursorLeft绑定到Shift+<-，
          Macro: SuperShiftCursorRight绑定到shift+->，
          Macro: SuperDelete绑定到del。
  * ④ Enjoy
  * ------------解决source insight 中文间距的方法：-----------------     
  * 默认情况下，往Source Insight里输入中文，字间距相当的大，解决办法如下:
  * 1.Options->Style Properties
  * 2.在左边Style Name下找到Comment Multi Line和Comment.在其右边对应的Font属性框下的
  * Font Name中选“Pick...” 设为宋体、常规、小四。确定，退回Style Properties界面，
  * Size设为10。最后设置Clolors框下Foreground，点“Pick...”选择一种自己喜欢的颜色就OK了。
  * 3.Done
  */

/** @brief    Save system's information
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro SaveSysInfo( )
{
    Name = Ask( "Please enter your name:" )
    Version = Ask( "Version:" )

    hSysBuf = NewBuf( "SystemInfo" )
    if( hSysBuf == hNil )
    {
        return 1
    }

    AppendBufLine( hSysBuf, Name )//line 0
    AppendBufLine( hSysBuf, Version )//line 1

    SaveBufAs( hSysBuf, "system.ini" )
}

/** @brief      添加起始注释，并添加作者和时间信息
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro AddModInfo()
{
    hSysBuf = OpenBuf( "system.ini" )
    if( hSysBuf == hNil )
    {
        return 1
    }

    MyName  = GetBufLine( hSysBuf, 0 )
    Version = GetBufLine( hSysBuf, 1 )

    SysTime = GetSysTime( 0 )

    year  = SysTime.Year
    month = SysTime.Month
    day   = SysTime.Day
    hour  = SysTime.Hour + 8
    minute= SysTime.Minute

    /*
    j = 0
    counter = 0
    head = 0
    tail = 0    
    while( 1 )
    {
        if( AsciiFromChar( SysTime[j] ) == 34 )
        {
            counter = counter + 1
        }

    if( counter == 1 && head == 0 )
    {
        head = j
    }
    if( counter == 2 && tail == 0 )
    {
        tail = j
        break;
    }

    j = j + 1       
    }

    date = StrMid( SysTime, head + 1, tail )
    */

    hwnd    = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnLast  = GetWndSelLnLast( hwnd )

    hbuf = GetCurrentBuf()

    //modified on 2003.12.10
    /*if( lnFirst != lnLast )*/
    {
        firstBuf = ""
        lastBuf  = ""
        spaceBuf = ""
        referencedBuf = GetBufLine( hbuf, lnFirst )

        i = 0
        while( referencedBuf[i] == " " || referencedBuf[i] == "\t" )
        {
            if( referencedBuf[i] == " " )
            {
                spaceBuf = cat( spaceBuf, " " )//space
            }
            else
            {
                spaceBuf = cat( spaceBuf, "\t" )//Tab
            }
            i = i + 1
        }

        firstBuf = cat( spaceBuf, "/*Start of @MyName@ on @year@-@month@-@day@ @hour@:@minute@ @Version@*/" )
        lastBuf  = cat( spaceBuf, "/*End of @MyName@ on @year@-@month@-@day@ @hour@:@minute@ @Version@*/" )
        InsBufLine( hbuf, lnFirst, firstBuf )
        InsBufLine( hbuf, lnLast + 2, lastBuf )
    }
    /*
    else
    {
       curText = GetBufLine( hbuf, lnFirst )
    */
    
    //newText = cat( curText, "/*Modifed by @MyName@ on @date@ @Version@*/" )
    
    /*
    DelBufLine( hbuf, lnFirst )
    InsBufLine( hbuf, lnFirst, newText )
    }
    */

    CloseBuf( hSysBuf )
}

/** @brief    添加C语言风格单行注释
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro AddCommentInfo()
{
    hwnd    = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnLast  = GetWndSelLnLast( hwnd )

    hbuf = GetCurrentBuf()

    curFirstText = GetBufLine( hbuf, lnFirst )

    i = 0
    tmpFirstText = ""
    while( curFirstText[i] == " " || curFirstText[i] == "\t" )
    {
        if( curFirstText[i] == " " )
        {
            tmpFirstText = cat( tmpFirstText, " " )
        }
        else
        {
            tmpFirstText = cat( tmpFirstText, "\t" )
        }
            i = i + 1
    }

    len = strlen( curFirstText )

    newFirstText = strmid( curFirstText, i, len )

    if( lnFirst == lnLast )
    {
        /*
        GetWndSelIchFirst (hwnd)
        GetWndSelIchLim (hwnd)
        */
        //modified on 2003.12.10
        tmpFirstText = cat( tmpFirstText, "/*" )
        newFirstText = cat( tmpFirstText, newFirstText )
        newFirstText = cat( newFirstText, "*/" )

        DelBufLine( hbuf, lnFirst )
        InsBufLine( hbuf, lnFirst, newFirstText )
    }
    else
    {
        tmpFirstText = cat( tmpFirstText, "/*" )
        newFirstText = cat( tmpFirstText, newFirstText )

        curLastText  = GetBufLine( hbuf, lnLast )
        newLastText  = cat( curLastText, "*/" )

        DelBufLine( hbuf, lnFirst )
        InsBufLine( hbuf, lnFirst, newFirstText )
        DelBufLine( hbuf, lnLast )
        InsBufLine( hbuf, lnLast, newLastText )
    }
}

/** @brief    添加 #if 0 #endif注释
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro AddIf0Identifier()
{
    hwnd    = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnLast  = GetWndSelLnLast( hwnd )

    hbuf = GetCurrentBuf()

    curFirstText = GetBufLine( hbuf, lnFirst )

    if( strlen( curFirstText) <= 0 )
    {
        return 1
    }   

    i = 0
    tmpFirstText = ""
    while( curFirstText[i] == " " || curFirstText[i] == "\t" )
    {
        if( curFirstText[i] == " " )
        {
            tmpFirstText = cat( tmpFirstText, " " )
        }
        else
        {
            tmpFirstText = cat( tmpFirstText, "\t" )
        }
        i = i + 1
    }

    if( lnFirst <= 1 )
    {
        return 1
    }

    newText = cat( tmpFirstText, "#if 0" )
    InsBufLine( hbuf, lnFirst, newText )
    newText = cat( tmpFirstText, "#endif" )
    InsBufLine( hbuf, lnLast + 2, newText )
}

/** @brief    添加函数头注释
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro AddFuncHeader()
{
    hSysBuf = OpenBuf( "system.ini" )
    if( hSysBuf == hNil )
    {
        return 1
    }

    szMyName  = GetBufLine( hSysBuf, 0 )
    szVersion = GetBufLine( hSysBuf, 1 )

    SysTime = GetSysTime( 0 )
    date    = StrMid( SysTime, 6, 19 )

    // Get a handle to the current file buffer and the name
    // and location of the current symbol where the cursor is.
    hbuf = GetCurrentBuf()

    if( hbuf == hNil )
    {
        return 1
    }

    ln = GetBufLnCur( hbuf )

    /* if owner variable exists, insert Owner: name */
    lnStartPos = ln + 2;
    if (strlen(szMyName) > 0)
    {
        //InsBufLine( hbuf, ln + 1, "/**\@fn    " )
        InsBufLine( hbuf, ln + 1, "/** \@brief    " )
        InsBufLine( hbuf, ln + 2, "  * \@param[in]  " )
        InsBufLine( hbuf, ln + 3, "  * \@param[out]  " )
        InsBufLine( hbuf, ln + 4, "  * \@return  " )
        InsBufLine( hbuf, ln + 5, "  */" )
        ln = ln + 5
    }
    else
    {
        ln = ln + 2
    }

    // put the insertion point inside the header comment
    SetBufIns( hbuf, lnStartPos, 20 )

    CloseBuf( hSysBuf )
}

/** @brief    添加文件头注释
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro AddFileHeader()
{
    hSysBuf = OpenBuf( "system.ini" )
    if( hSysBuf == hNil )
    {
        return 1
    }

    szMyName  = GetBufLine( hSysBuf, 0 )
    Version = GetBufLine( hSysBuf, 1 )

    SysTime = GetSysTime( 0 )
    //modified on 2003.12.10
    //date    = StrMid( SysTime, 6, 19 )
    year  = SysTime.Year
    month = SysTime.Month
    day   = SysTime.Day

    hbuf = GetCurrentBuf()

    //InsBufLine( hbuf, 0, "/*=========================================================================*" )
    InsBufLine( hbuf, 0, "      " )

    /* if owner variable exists, insert Owner: name */
    /*
    InsBufLine( hbuf, 1, "FileName:" )
    InsBufLine( hbuf, 2, "Created by:@szMyName@" )
    InsBufLine( hbuf, 3, "Created date:@date@" )
    InsBufLine( hbuf, 4, "Content:" )
    InsBufLine( hbuf, 5, "Modified records:" )
    InsBufLine( hbuf, 6, "1. YYYY.MM.DD:Mr Bill Gates add ......" )
    InsBufLine( hbuf, 7, "    Mr. Bill Gates add ......" )
    */


    InsBufLine( hbuf, 1, "/** \@file " )
    InsBufLine( hbuf, 2, "  * \@note HangZhou Hikvision Digital Technology Co., Ltd. All Right Reserved." )
    InsBufLine( hbuf, 3, "  * \@brief    " )
    InsBufLine( hbuf, 4, "  * " )
    InsBufLine( hbuf, 5, "  * \@author   @szMyName@" )
    InsBufLine( hbuf, 6, "  * \@date     @year@-@month@-@day@" )
    InsBufLine( hbuf, 7, "  * \@version  @Version@" )
    InsBufLine( hbuf, 8, "  * ")
    InsBufLine( hbuf, 9, "  * \@note ///Description here " )
    InsBufLine( hbuf, 10, "  * \@note History:    " )
    InsBufLine( hbuf, 11, "  * \@note     <author>   <time>    <version >   <desc>" )
    InsBufLine( hbuf, 12, "  * \@note  " )
    InsBufLine( hbuf, 13, "  * \@warning  " )
    InsBufLine( hbuf, 14, "  */" )

    SetBufIns( hbuf, 1, 19 )

    CloseBuf( hSysBuf )
}

/** @brief    添加结构体头注释
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro AddStructHeader()
{
    hSysBuf = OpenBuf( "system.ini" )
    if( hSysBuf == hNil )
    {
        return 1
    }

    szMyName  = GetBufLine( hSysBuf, 0 )
    szVersion = GetBufLine( hSysBuf, 1 )

    SysTime = GetSysTime( 0 )
    date    = StrMid( SysTime, 6, 19 )

    // Get a handle to the current file buffer and the name
    // and location of the current symbol where the cursor is.
    hbuf = GetCurrentBuf()

    if( hbuf == hNil )
    {
        return 1
    }

    ln = GetBufLnCur( hbuf )

    /* if owner variable exists, insert Owner: name */
    lnStartPos = ln + 2;
    if (strlen(szMyName) > 0)
    {

        //InsBufLine( hbuf, ln + 1, "/**\@struct          " )
        InsBufLine( hbuf, ln + 1, "/** \@brief    " )
        //InsBufLine( hbuf, ln + 3, " * \@see  " )
        InsBufLine( hbuf, ln + 2, "  */" )

        ln = ln + 2
    }
    else
    {
        ln = ln + 2
    }

    // put the insertion point inside the header comment
    SetBufIns( hbuf, lnStartPos, 20 )

    CloseBuf( hSysBuf )
}

/** @brief    添加枚举类型头注释
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro AddEnumHeader()
{
    hSysBuf = OpenBuf( "system.ini" )
    if( hSysBuf == hNil )
    {
        return 1
    }

    szMyName  = GetBufLine( hSysBuf, 0 )
    szVersion = GetBufLine( hSysBuf, 1 )

    SysTime = GetSysTime( 0 )
    date    = StrMid( SysTime, 6, 19 )

    // Get a handle to the current file buffer and the name
    // and location of the current symbol where the cursor is.
    hbuf = GetCurrentBuf()

    if( hbuf == hNil )
    {
        return 1
    }

    ln = GetBufLnCur( hbuf )

    /* if owner variable exists, insert Owner: name */
    lnStartPos = ln + 2;
    if (strlen(szMyName) > 0)
    {

        //InsBufLine( hbuf, ln + 1, "/**\@enum    " )
        InsBufLine( hbuf, ln + 1, "/** \@brief    " )
        //InsBufLine( hbuf, ln + 2, " * \@see  " )
        InsBufLine( hbuf, ln + 2, "   */" )

        ln = ln + 2
    }
    else
    {
        ln = ln + 2
    }

    // put the insertion point inside the header comment
    SetBufIns( hbuf, lnStartPos, 20 )

    CloseBuf( hSysBuf )
}

/** @brief    支持处理中文的SuperBackSpace键
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro SuperBackspace()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        stop;   // empty buffer
    }
    // get current cursor postion
    ipos = GetWndSelIchFirst(hwnd);
    // get current line number
    ln = GetBufLnCur(hbuf);
    if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) 
    {
        // sth. was selected, del selection
        SetBufSelText(hbuf, " ");  // stupid & buggy sourceinsight 
        // del the " "
        SuperBackspace(1);
        stop;
    }
    // copy current line
    text = GetBufLine(hbuf, ln);
    // get string length
    len = strlen(text);
    // if the cursor is at the start of line, combine with prev line
    if (ipos == 0 || len == 0)
    {
        if (ln <= 0)
        {
            stop;   // top of file
        }
        ln = ln - 1;    // do not use "ln--" for compatibility with older versions
        prevline = GetBufLine(hbuf, ln);
        prevlen = strlen(prevline);
        // combine two lines
        text = cat(prevline, text);
        // del two lines
        DelBufLine(hbuf, ln);
        DelBufLine(hbuf, ln);
        // insert the combined one
        InsBufLine(hbuf, ln, text);
        // set the cursor position
        SetBufIns(hbuf, ln, prevlen);
        stop;
    }
    num = 1; // del one char
    if (ipos >= 1)
    {
        // process Chinese character
        i = ipos;
        count = 0;
        while (AsciiFromChar(text[i - 1]) >= 160)
        {
            i = i - 1;
            count = count + 1;
            if (i == 0)
            {
                break;
            }
        }
        if (count > 0)
        {
            // I think it might be a two-byte character
            num = 2;
            // This idiot does not support mod and bitwise operators
            if ((count / 2 * 2 != count) && (ipos < len))
            {
                ipos = ipos + 1;    // adjust cursor position
            }
        }
    }
    // keeping safe
    if (ipos - num < 0)
    {
        num = ipos;
    }
    // del char(s)
    text = cat(strmid(text, 0, ipos - num), strmid(text, ipos, len));
    DelBufLine(hbuf, ln);
    InsBufLine(hbuf, ln, text);
    SetBufIns(hbuf, ln, ipos - num);
    stop;
}

/** @brief    支持处理中文的SuperDelete键
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro SuperDelete()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        stop;   // empty buffer
    }
    // get current cursor postion
    ipos = GetWndSelIchFirst(hwnd);
    // get current line number
    ln = GetBufLnCur(hbuf);
    if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd)))
    {
        // sth. was selected, del selection
        SetBufSelText(hbuf, " "); // stupid & buggy sourceinsight 
        // del the " "
        SuperDelete(1);
        stop;
    }
    // copy current line
    text = GetBufLine(hbuf, ln);
    // get string length
    len = strlen(text);

    if (ipos == len || len == 0)
    {
        totalLn = GetBufLineCount (hbuf);
        lastText = GetBufLine(hBuf, totalLn-1);
        lastLen = strlen(lastText);
        if (ipos == lastLen)// end of file
        {
            stop;
        }
        ln = ln + 1;    // do not use "ln--" for compatibility with older versions
        nextline = GetBufLine(hbuf, ln);
        nextlen = strlen(nextline);
        // combine two lines
        text = cat(text, nextline);
        // del two lines
        DelBufLine(hbuf, ln-1);
        DelBufLine(hbuf, ln-1);
        // insert the combined one
        InsBufLine(hbuf, ln-1, text);
        // set the cursor position
        SetBufIns(hbuf, ln-1, len);
        stop;
    }
    num = 1; // del one char
    if (ipos > 0)
    {
        // process Chinese character
        i = ipos;
        count = 0;
        while (AsciiFromChar(text[i-1]) >= 160)
        {
            i = i - 1;
            count = count + 1;
            if (i == 0)
            {
                break;
            }
        }
        if (count > 0)
        {
            // I think it might be a two-byte character
            num = 2;
            // This idiot does not support mod and bitwise operators
            if (((count / 2 * 2 != count) || count == 0) && (ipos < len-1))
            {
                ipos = ipos + 1;    // adjust cursor position
            }
        }
        // keeping safe
        if (ipos - num < 0)
        {
            num = ipos;
        }
    }
    else
    {
        i = ipos;
        count = 0;
        while(AsciiFromChar(text) >= 160)
        {
            i = i + 1;
            count = count + 1;
            if(i == len-1)
            {
                break;
            }
        }
        if(count > 0)
        {
            num = 2;
        }
    }

    text = cat(strmid(text, 0, ipos), strmid(text, ipos+num, len));
    DelBufLine(hbuf, ln);
    InsBufLine(hbuf, ln, text);
    SetBufIns(hbuf, ln, ipos);
    stop;
}

/** @brief    支持处理中文的SuperCursorLeft键
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro IsComplexCharacter()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        return 0;
    }
    //当前位置
    pos = GetWndSelIchFirst(hwnd);
    //当前行数
    ln = GetBufLnCur(hbuf);
    //得到当前行
    text = GetBufLine(hbuf, ln);
    //得到当前行长度
    len = strlen(text);
    //从头计算汉字字符的个数
    if(pos > 0)
    {
        i=pos;
        count=0;
        while(AsciiFromChar(text[i-1]) >= 160)
        { 
            i = i - 1;
            count = count+1;
            if(i == 0)
            {
                break;
            }
        }
        if((count/2)*2==count|| count==0)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    return 0;
}
macro moveleft()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        stop;   // empty buffer
    }

    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    if(GetBufSelText(hbuf) != "" || (ipos == 0 && ln == 0))   // 第0行或者是选中文字,则不移动
    {
        SetBufIns(hbuf, ln, ipos);
        stop;
    }
    if(ipos == 0)
    {
        preLine = GetBufLine(hbuf, ln-1);
        SetBufIns(hBuf, ln-1, strlen(preLine)-1);
    }
    else
    {
        SetBufIns(hBuf, ln, ipos-1);
    }
}
macro SuperCursorLeft()
{
    moveleft();
    if(IsComplexCharacter())
    {
        moveleft();
    }
}

/** @brief    支持处理中文的SuperCursorRight键
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro moveRight()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        stop;   // empty buffer
    }
    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    totalLn = GetBufLineCount(hbuf);
    text = GetBufLine(hbuf, ln); 
    if(GetBufSelText(hbuf) != "")   //选中文字
    {
        ipos = GetWndSelIchLim(hwnd);
        ln = GetWndSelLnLast(hwnd);
        SetBufIns(hbuf, ln, ipos);
        stop;
    }
    if(ipos == strlen(text)-1 && ln == totalLn-1) // 末行
    {
        stop;
    }
    if(ipos == strlen(text))
    {
        SetBufIns(hBuf, ln+1, 0);
    }
    else
    {
        SetBufIns(hBuf, ln, ipos+1);
    }
}
macro SuperCursorRight()
{
    moveRight();
    if(IsComplexCharacter()) // defined in SuperCursorLeft.em
    {
        moveRight();
    }
}

/** @brief    支持处理中文的SuperShiftCursorRight键 : shift + ->
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro IsShiftRightComplexCharacter()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        return 0;
    }
    selRec = GetWndSel(hwnd);
    pos = selRec.ichLim;
    ln = selRec.lnLast;
    text = GetBufLine(hbuf, ln);
    len = strlen(text);
    if(len == 0 || len < pos)
    {
        return 1;
    }
    //Msg("@len@;@pos@;");
    if(pos > 0)
    {
        i=pos;
        count=0; 
        while(AsciiFromChar(text[i-1]) >= 160)
        { 
            i = i - 1;
            count = count+1;   
            if(i == 0)
            {
                break;
            }
        }
        if((count/2)*2==count|| count==0)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    return 0;
}

macro shiftMoveRight()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        stop;
    }

    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    totalLn = GetBufLineCount(hbuf);
    text = GetBufLine(hbuf, ln); 
    selRec = GetWndSel(hwnd);   
    curLen = GetBufLineLength(hbuf, selRec.lnLast);
    if(selRec.ichLim == curLen+1 || curLen == 0)
    { 
        if(selRec.lnLast == totalLn -1)
        {
            stop;
        }
        selRec.lnLast = selRec.lnLast + 1; 
        selRec.ichLim = 1;
        SetWndSel(hwnd, selRec);
        if(IsShiftRightComplexCharacter())
        {
            shiftMoveRight();
        }
        stop;
    }
    selRec.ichLim = selRec.ichLim+1;
    SetWndSel(hwnd, selRec);
}
macro SuperShiftCursorRight()
{       
    if(IsComplexCharacter())
    {
        SuperCursorRight();
    }
    shiftMoveRight();
    if(IsShiftRightComplexCharacter())
    {
        shiftMoveRight();
    }
}

/** @brief    支持处理中文的SuperShiftCursorLeft键 : shift + <-
  * @param[in]  
  * @param[out]  
  * @return  
  */
macro IsShiftLeftComplexCharacter()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        return 0;
    }
    selRec = GetWndSel(hwnd);
    pos = selRec.ichFirst;
    ln = selRec.lnFirst;
    text = GetBufLine(hbuf, ln);
    len = strlen(text);
    if(len == 0 || len < pos)
    {
        return 1;
    }
    //Msg("@len@;@pos@;");
    if(pos > 0)
    {
        i=pos;
        count=0; 
        while(AsciiFromChar(text[i-1]) >= 160)
        { 
            i = i - 1;
            count = count+1;   
            if(i == 0)
            {
                break;
            }
        }
        if((count/2)*2==count|| count==0)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    return 0;
}

macro shiftMoveLeft()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
    {
        stop;
    }

    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    totalLn = GetBufLineCount(hbuf);
    text = GetBufLine(hbuf, ln); 
    selRec = GetWndSel(hwnd);   
    //curLen = GetBufLineLength(hbuf, selRec.lnFirst);
    //Msg("@curLen@;@selRec@");
    if(selRec.ichFirst == 0)
    { 
        if(selRec.lnFirst == 0)
        {
            stop;
        }
        selRec.lnFirst = selRec.lnFirst - 1;
        selRec.ichFirst = GetBufLineLength(hbuf, selRec.lnFirst)-1;
        SetWndSel(hwnd, selRec);
        if(IsShiftLeftComplexCharacter())
        {
            shiftMoveLeft();
        }
        stop;
    }
    selRec.ichFirst = selRec.ichFirst-1;
    SetWndSel(hwnd, selRec);
}
macro SuperShiftCursorLeft()
{
    if(IsComplexCharacter())
    {
        SuperCursorLeft();
    }
    shiftMoveLeft();
    if(IsShiftLeftComplexCharacter())
    {
        shiftMoveLeft();
    }
}
