//
//  VJNYHTTPResultCode.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#ifndef vjourney_VJNYHTTPResultCode_h
#define vjourney_VJNYHTTPResultCode_h

typedef enum {
    Success,
    FailedWithGeneralError,
    FailedWithSQLError,
    FailedWithParamError
} VJNYHTTPResultCode;

#endif
