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
��˵���������޸��������֣������ڽ����ļ��޸�ʱ��ʵʱ���£�

//*****************************************************************************
//
//! \addtogroup module
//! @{
//
//*****************************************************************************
��˵��������group���֣��������������ģ������޸ģ�
/** module errno */
static int error_no;
(˵�������ڱ������֣�һ��ǰ�涼����static�������Ҫ��ȡ��صı�����Ϣ����ʹ�ú������з�װ)

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
��˵��������ǰδ��static,������������Ƕ��⿪���ģ�

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

    for (i = 0; i <��MAX_ERRNO; i++)
    {
        // ...
    }
}
��˵��������ǰ��static, ����������������⿪�������ڸ�C�����ļ��ڲ����ã�

//*****************************************************************************
//
// Close the Doxygen group.
//! @}
//
//*****************************************************************************