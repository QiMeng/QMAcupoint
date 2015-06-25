//
//  Service.m
//  QMAcupoint
//
//  Created by QiMENG on 15/6/24.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "Service.h"

@implementation Service

+ (instancetype)sharedClient {
    static Service *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Service alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
        
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
    });
    
    return _sharedClient;
}
+ (NSString *)FMDBPath {
    
    return  [[NSBundle mainBundle] pathForResource:@"com.qmj.QMAcupoint" ofType:@"db"];
    
//    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *app_Identifer = [infoDictionary objectForKey:@"CFBundleIdentifier"];
//    
//    NSLog(@"%@",docsdir);
//    
//    return [NSString stringWithFormat:@"%@/%@.db",docsdir,app_Identifer];
    
    
}
+ (FMDatabase *)db {
    
    FMDatabase *_db = [FMDatabase databaseWithPath:[Service FMDBPath]];
    if ([_db open]) {
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS xuewei (href text PRIMARY KEY,title text,parent text, lid integer)"];
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (href text PRIMARY KEY,jpg text,gif text,info text,title text,parent text )"];
    }
    
    return _db;
}

+ (id)medicaPage:(int)aPage
       withBlock:(void (^)(NSArray *array, NSError *error))block{
    
    return [[Service sharedClient] GET:@""
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   block([self parseList:responseObject],nil);
                                   
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
                                   [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                                   
                               }];
    
}

+ (NSArray *)parseList:(id)response {
    
    NSMutableArray * mainArray = [NSMutableArray array];
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            
            NSArray *list = [doc nodesForXPath:@"//div[@class='cdiv']" error:NULL];
            
            for (GDataXMLElement * elements in list) {
                
                NSArray *span = [elements elementsForName:@"p"];
                if (span.count > 0) {
                    
                    NSArray *groups = [elements elementsForName:@"ul"];
                    
                    int i = 0;
                    for (GDataXMLElement * item in groups) {
                        
                        GDataXMLElement *firstName = (GDataXMLElement *) [span objectAtIndex:i++];
                        
                        NSArray *groups = [item elementsForName:@"li"];
                        for (GDataXMLElement * aItem in groups) {
                            
                            NSArray *agroups = [aItem elementsForName:@"a"];
                            for (GDataXMLElement *element  in agroups) {
                                
                                Model * m = [Model new];
                                
                                m.href = [[element attributeForName:@"href"] stringValue];
                                m.title = element.stringValue;
                                m.parent = firstName.stringValue;
                                
                                [mainArray addObject:m];
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    [Service insertArray:mainArray];
    
    return mainArray;
    
}

+ (void)insertArray:(NSArray *)aArray {
    
    FMDatabase * db = [Service db];
    
    [db beginTransaction];
    
    int i = 1;
    for (Model * m in aArray) {
        
        [db executeUpdate:@"REPLACE INTO xuewei (href,title,parent,lid) VALUES (?,?,?,?)",m.href,m.title,m.parent,[NSNumber numberWithInt:i++]];
    }
    [db commit];
    [db close];
}

+ (void)info {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM xuewei"];
    
    while ([rs next]) {
        
        Model * m = [Model new];
        
        m.href = [rs stringForColumn:@"href"];
        m.title = [rs stringForColumn:@"title"];
        m.parent = [rs stringForColumn:@"parent"];
        
        [array addObject:m];
        
        
        
    }
    
    __block int j = 0 ;
    
    for (int i=0; i< array.count; i++) {
        
        Model * m = array[i];
        
        [Service info:m withBlock:^(Model * infoModel, NSError *error) {

            [db executeUpdate:@"REPLACE INTO info (href, info,jpg,gif,title,parent) VALUES (?,?,?,?,?,?)",infoModel.href,infoModel.info,infoModel.jpg,infoModel.gif,infoModel.title,infoModel.parent];
            
            [SVProgressHUD showProgress:j/(1.0 * array.count) maskType:SVProgressHUDMaskTypeBlack];
            
            j++;
            
            if (j == array.count) {
                [SVProgressHUD showSuccessWithStatus:@"完成" maskType:SVProgressHUDMaskTypeBlack];
                [db close];
            }

        }];
        
    }
}

+ (id)info:(Model *)aModel withBlock:(void (^)(id infoModel, NSError *error))block {
    
    return [[Service sharedClient] GET:aModel.href
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   block([self parseInfoModel:aModel withData:responseObject],nil);
                                   
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                               }];
    
}

+ (Model *)parseInfoModel:(Model *)aModel withData:(id)response {
    
    aModel.info = @"";
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            
            NSArray * trArray = [doc nodesForXPath:@"//div[@class='cdiv']" error:NULL];
            
            NSString * infostr = @"";
            
            NSArray * tr = [trArray[0] elementsForName:@"p"];
            
            for (GDataXMLElement * item1 in tr) {
                
                infostr = [NSString stringWithFormat:@"%@\n%@",infostr,item1.stringValue];

            }
            
            aModel.info = infostr;

            NSArray * imgs = [trArray[1] elementsForName:@"img"];
            
            {
                GDataXMLElement *firstName = (GDataXMLElement *) [imgs objectAtIndex:0];
                aModel.jpg = [[firstName attributeForName:@"src"] stringValue];
            }
            
            {
                GDataXMLElement *firstName = (GDataXMLElement *) [imgs objectAtIndex:0];
                aModel.gif = [[firstName attributeForName:@"src"] stringValue];
            }
            
            
            
        }
    }
    
    return aModel;
}

#pragma mark - 获取分组
+ (NSArray *)readGroup {
    
    NSMutableArray * array = [NSMutableArray array];
    
    @autoreleasepool {
        FMDatabase * db = [Service db];
        
        FMResultSet *rs = [db executeQuery:@"select parent,count(*) as count from xuewei group by parent order by lid"];
        
        while ([rs next]) {
            
            Model * m = [Model new];
            m.parent = [rs stringForColumn:@"parent"];
            m.count = [rs intForColumn:@"count"];
            
            m.subArray = [self readPointsFromGroup:m];
            
            [array addObject:m];
            
        }
    }

    return array;
}
+ (NSArray *)readPointsFromGroup:(Model *)aModel {
    
    NSMutableArray * array = [NSMutableArray array];
    
    @autoreleasepool {
        FMDatabase * db = [Service db];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from xuewei where parent = '%@' order by lid",aModel.parent]];
        
        while ([rs next]) {
            
            Model * m = [Model new];
            m.parent = [rs stringForColumn:@"parent"];
            m.title = [rs stringForColumn:@"title"];
            m.href = [rs stringForColumn:@"href"];
            
            [array addObject:m];
            
        }
    }
    return array;
    
}


#pragma mark - 获取所有穴位 字典
+ (NSDictionary *)readAllPointDic {
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    
    @autoreleasepool {
        FMDatabase * db = [Service db];
        
        FMResultSet *rs = [db executeQuery:@"select * from xuewei order by lid"];
        
        while ([rs next]) {
            
            Model * m = [Model new];
            m.parent = [rs stringForColumn:@"parent"];
            m.title = [rs stringForColumn:@"title"];
            m.href = [rs stringForColumn:@"href"];
            
            [dic setObject:m forKey:m.href];
            
        }
    }
    return dic;
}
#pragma mark - 获取所有穴位 数组
+ (NSArray *)readAllPointArray {
    
    NSMutableArray * array = [NSMutableArray array];
    
    @autoreleasepool {
        FMDatabase * db = [Service db];
        
        FMResultSet *rs = [db executeQuery:@"select * from xuewei order by lid"];
        
        while ([rs next]) {
            
            Model * m = [Model new];
            m.parent = [rs stringForColumn:@"parent"];
            m.title = [rs stringForColumn:@"title"];
            m.href = [rs stringForColumn:@"href"];
            
            [array addObject:m];
            
        }
    }
    return array;
}
#pragma mark - 获取详细信息
+ (id) readInfoPointModel:(Model *)aModel {
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from info where href = '%@'",aModel.href]];
    
    Model * m = [Model new];
    while ([rs next]) {
        m.parent = [rs stringForColumn:@"parent"];
        m.title = [rs stringForColumn:@"title"];
        m.href = [rs stringForColumn:@"href"];
        m.jpg = [rs stringForColumn:@"jpg"];
        m.gif = [rs stringForColumn:@"gif"];
        m.info = [rs stringForColumn:@"info"];
    }
    return m;
}

+ (NSArray *)search:(NSString *)aSearch {
    
    NSMutableArray * array = [NSMutableArray array];
    
    Model * group = [Model new];
    [array addObject:group];
    

    @autoreleasepool {
        FMDatabase * db = [Service db];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM xuewei WHERE title LIKE  '%%%@%%'",aSearch]];
        
        NSMutableArray * subs = [NSMutableArray array];
        while ([rs next]) {
            
            Model * m = [Model new];
            m.parent = [rs stringForColumn:@"parent"];
            m.title = [rs stringForColumn:@"title"];
            m.href = [rs stringForColumn:@"href"];
            
            [subs addObject:m];
        }
        
        group.subArray = subs;
    }
    
    group.parent = [NSString stringWithFormat:@"'%@'的搜索",aSearch];
    group.count = group.subArray.count;
    
    return array;
}


@end
