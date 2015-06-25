//
//  Model.h
//  QMAcupoint
//
//  Created by QiMENG on 15/6/24.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * href;
@property (nonatomic, copy) NSString * parent;

@property (nonatomic, copy) NSString * info;
@property (nonatomic, copy) NSString * jpg;
@property (nonatomic, copy) NSString * gif;


@property (nonatomic, assign) int count;
@property (nonatomic, retain) NSArray * subArray;

@end
