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
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Identifer = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    
    NSLog(@"%@",docsdir);
    return [NSString stringWithFormat:@"%@/%@.db",docsdir,app_Identifer];
    
    
}
+ (FMDatabase *)db {
    
    FMDatabase *_db = [FMDatabase databaseWithPath:[Service FMDBPath]];
    if ([_db open]) {
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS xuewei (href text PRIMARY KEY,title text,parent text)"];
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (href text PRIMARY KEY,jpg text,gif text,info text,title text,parent text , lid integer)"];
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
    
    for (Model * m in aArray) {
        
        [db executeUpdate:@"REPLACE INTO xuewei (href,title,parent) VALUES (?,?,?)",m.href,m.title,m.parent];
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

            [db executeUpdate:@"REPLACE INTO info (href, info,jpg,gif,title,parent,lid) VALUES (?,?,?,?,?,?,?)",infoModel.href,infoModel.info,infoModel.jpg,infoModel.gif,infoModel.title,infoModel.parent,[NSNumber numberWithInt:j]];
            
            [SVProgressHUD showProgress:j/(1.0 * array.count)];
            
            j++;
            
            if (j == array.count) {
                [SVProgressHUD showSuccessWithStatus:@"完成"];
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

+ (NSArray *)readGroup {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"select parent,count(*) as count from info group by parent order by lid"];
    
    while ([rs next]) {
        
        Model * m = [Model new];
        m.parent = [rs stringForColumn:@"parent"];
        m.count = [rs intForColumn:@"count"];
        [array addObject:m];
    }
    
    return array;
}



@end
