//
//  Service.h
//  QMAcupoint
//
//  Created by QiMENG on 15/6/24.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "QMAcupoint-Bridging-Header.h"
#import "Model.h"
@interface Service : AFHTTPSessionManager

+ (FMDatabase *)db;

+ (instancetype)sharedClient;

+ (id)medicaPage:(int)aPage
       withBlock:(void (^)(NSArray *array, NSError *error))block;

+ (void)info;


+ (NSArray *)readGroup;
+ (NSArray *)readPointFromGroup:(Model *)aModel;
+ (NSDictionary *)readAllPointDic;
+ (NSArray *)readAllPointArray;
+ (id) readInfoPointModel:(Model *)aModel;

@end
