//*****************************************************************************
// file		: template.c
// It's a template file, it shows how to write the comments and functions.
// 
// Copyright (c) 2006-2020  co. Ltd. All rights reserved
// 
// Change Logs:
// Date				Author		Note	
// 2017/03/21    	kuan		First draft version
// 
//*****************************************************************************

//*****************************************************************************
//
//! \addtogroup module
//! @{
//
//*****************************************************************************


/** 演示创建枚举 */

/** describe color information */
enum color
{
    E_RED,               /**< red color               */
    E_BLUE,              /**< blue color              */
    E_YELLOW,            /**< yellow color            */
};

/** define color_t */
typedef enum color color_t;






























/** describe color information */
enum color
{
    E_RED,               /**< red color               */
    E_BLUE,              /**< blue color              */
    E_YELLOW,            /**< yellow color            */
};

/** define color_t */
typedef struct color color_t;
















/** 演示创建枚举演示 */


/** describe color information */
enum color
{
    E_RED,     /**< red color */
    E_BLUE,    /**< blue color */
    E_Yellow,  /**< yellow color */
};

/** describe color_t */
typedef enum color color_t;



/** 演示创建枚举 */



/** describe color information */
//enum color
//{
//    E_RED,               /**< red color               */
//    E_BLUE,              /**< blue color              */
//    E_YELLOW,            /**< yellow color            */
//};

/** define color_t */
//typedef struct color color_t;



/** 演示创建结构体DEMO */



/** describe student information */
struct student
{
    char *name;     /**< student's name */
    int age;        /**< student's age */
};

/** describe student_t */
typedef struct student student_t;



/** 演示创建结构体 */

/** describe student information */
struct student
{
    char *name;     /**< student's name */
    int age;        /**< student's age */
};

/** describe student_t */
typedef struct student student_t;



/** 演示 函数自动补全注释，详细说明需要手动添加 */



/** \brief main
  *
  * \param argc
  *
  * \param argv[]
  *
  * \return None
  */
   static  int      main   (    int     argc,
char*    argv[]    )          
{
    //add your code



    system("pause");
    return 0;
}

/** \brief main
  *
  * \param argc
  *
  * \param argv[]
  *
  * \param test
  *
  * \return None
  */
  
     static  int      main   (    int     argc,
   char*    argv[]  ,int test  )          
   {
       //add your code
   
   
   
       system("pause");
       return 0;
   }
  

  
/** \brief main
  *
  * \param argc
  *
  * \param argv[]
  *
  * \return None
  */
   static  void      main   (    int     argc,

   
char*    *argv[]    )          { 

    //add your code



    system("pause");
    return 0;
}


/** \brief main
  *
  * \param None
  *
  * \return None
  */
   static  void      main   (    void    )          
{
    //add your code



    system("pause");
    return 0;
}


/** \brief main
  *
  * \param buf
  *
  * \return None
  */
   static  void      main   ( char *buf  )          
{
    //add your code



    system("pause");
    return 0;
}

    



             

/** @brief 
  *
  * @param  
  *
  * @param 
  *
  * @return 
  */



/** \brief main
  *
  * \param None
  *
  * \return None
  */
  
   static  void      main   (        )          
{
    //add your code



    system("pause");
    return 0;
}




/** \brief main
  *
  * \param None
  *
  * \return None
  */
main   (        )          
{
    //add your code



    system("pause");
    return 0;
}












/** 演示 函数头注释 */




/** @brief main
  *
  * @param None
  *
  * @return None
  */
void main(void)
{



}


/** 演示 宏/变量/结构体/枚举右注释 */

/** test txd buf len */
#define TEST_TXD_BUF_LEN					100
/** error no */
static int error_no;
/** student info */
struct student
{
    char *name;    /**< student name */
    int age;       /**< student age */
};
/** color info */
enum color
{
    E_RED,         /**< red color */
    E_BLUE,        /**< blue color */
    E_Yellow,      /**< yellow color */
};













/** describe student information */
struct student
{
    char *name;     /**< student's name */
    int age;        /**< student's age */
};

/** describe student_t */
typedef struct student student_t;





/** describe stduent information */
struct stduent
{
    char *name;          /**< name          */
    int age;             /**< student age             */
};

/** describe stduent_t */
typedef struct stduent stduent_t;


/** describe color information */
enum color
{
    E_RED,     /**< red color */
    E_BLUE,    /**< blue color */
    E_Yellow,  /**< yellow color */
};

/** describe color_t */
typedef enum color color_t;


/** describe color information */
enum color
{
    E_RED,               /**< red color               */
    E_BLUE,              /**< blue color              */
};

/** define color_t */
typedef struct color color_t;



//*****************************************************************************
//
// Close the Doxygen group.
//! @}
//
//*****************************************************************************
