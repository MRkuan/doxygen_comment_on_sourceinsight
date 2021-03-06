//*****************************************************************************
// file		: template.h
// It's a template file, it shows how to write the comments and functions.
//
// Copyright (c) 2006-2012  co. Ltd. All rights reserved
// 
// Change Logs:
// Date				Author        Note	
// 2017/03/21			      filenote
// 
//*****************************************************************************
（说明：以上修改履历部分，请大家在进行文件修改时候实时更新）
#ifndef __TEMPLATE_H__
#define __TEMPLATE_H__
（说明：以上宏定义部分，请大家在文件名进行修改）
//*****************************************************************************
//
//! \addtogroup module
//! @{
//
//*****************************************************************************
（说明：以上group部分，请根据所开发的模块进行修改）
//*****************************************************************************
//
// If building with a C++ compiler, make all of the definitions in this header
// have a C binding.
//
//*****************************************************************************
#ifdef __cplusplus
extern "C"
{
#endif

/** describe student information */
typedef struct teacher
{
    char *name;     /**< teacher's name */
    int age;        /**< teacher's age */
}tTeacher;
(说明：结构体放到这里，表明这个部分会被其他部分调用到，否则请放到C代码里面定义)

//*****************************************************************************
//
// Prototypes for the APIs.
//
//*****************************************************************************
int module_GetErrNo(void);
（说明：这里只放置对外开发的函数部分）

//*****************************************************************************
//
// Mark the end of the C bindings section for C++ compilers.
//
//*****************************************************************************
#ifdef __cplusplus
}
#endif

//*****************************************************************************
//
// Close the Doxygen group.
//! @}
//
//*****************************************************************************

#endif //  __TEMPLATE_H__