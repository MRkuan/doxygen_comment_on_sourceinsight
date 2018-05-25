//*****************************************************************************
// file		: template.c
// It's a template file, it shows how to write the comments and functions.
// 
// Copyright (c) 2011-2014 HSAE co. Ltd. All rights reserved
// 
// Change Logs:
// Date				Author		Note	
// 2017/03/21    	Cheney		First draft version
// 
//*****************************************************************************
（说明：以上修改履历部分，请大家在进行文件修改时候实时更新）

//*****************************************************************************
//
//! \addtogroup module
//! @{
//
//*****************************************************************************
（说明：以上group部分，请根据所开发的模块进行修改）
/** module errno */
static int error_no;
(说明：关于变量部分，一般前面都加上static，如果需要获取相关的变量信息，请使用函数进行封装)

/** whether support xxx function */
#define SUPPORT_XXX

/** max error number value */
#define MAX_ERRNO       5

/** describe student information */
typedef struct student
{
    char *name;     /**< student's name */
    int age;        /**< student's age */
}tStudent;

/**
  * \brief get module error number
  * 
  * \param None
  *   
  * \return error number
  */
int module_GetErrNo(void)
{
    return error_no;
}
（说明：函数前未加static,表明这个函数是对外开发的）

/**
  * \brief module report error.
  *
  * \param errno is the error type to be reported
  *   
  * \return None
  */
static void module_ReportErr(int errno)
{
    int i;

    if (errno < MAX_ERRNO)
    {
        // ...
    }

    for (i = 0; i <　MAX_ERRNO; i++)
    {
        // ...
    }
}
（说明：函数前加static, 表明这个函数不对外开发，仅在该C代码文件内部调用）

//*****************************************************************************
//
// Close the Doxygen group.
//! @}
//
//*****************************************************************************