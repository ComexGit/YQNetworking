//
//  APIClient.m
//  EZPlaySDKDemo
//
//  Created by yuqian on 2018/9/25.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import "APIClient.h"
#import "AFNetworking.h"


@interface APIClient()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation APIClient

+ (APIClient *)sharedInstance {

    static dispatch_once_t once;
    static APIClient * __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } );
    return __singleton__;
}

// 发送请求，返回JSON格式的响应数据
+ (void)requestURL:(NSString *)urlString
        httpMethod:(HttpMethod)method
            params:(NSDictionary *)params
          response:(APIClientRequestResponse)response {
    
    APIClient *client = [APIClient sharedInstance];
    if (!client.manager) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        manager.requestSerializer     = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer    = [AFJSONResponseSerializer serializer];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.responseSerializer = responseSerializer;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",@"application/x-www-form-urlencodem", nil];
        
        
        client.manager = manager;
    }
    
    __weak typeof(self)weakSelf = self;
    switch (method) {
        case PATH_GET: {
            urlString = [APIClient pathGet:urlString params:params];
            //                //LOG(@"PATH_GET http_url:%@",urlString);
            [client.manager GET:urlString
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * __unused task, id JSON) {
                            __strong typeof(weakSelf)strongSelf = weakSelf;
                            if (strongSelf) {
                                [strongSelf handleSuccessRequest:JSON cb:response];
                            }
                        }
                        failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                            if (response) {
                                response(ApiRequestErr, nil);
                            }
                        }];
            break;
        }
        case QUERY_GET: {
            urlString = [APIClient queryGet:urlString params:params];
            //LOG(@"QUERY_GET http_url:%@",urlString);
            [client.manager GET:urlString
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * __unused task, id JSON) {
                            __strong typeof(weakSelf)strongSelf = weakSelf;
                            if (strongSelf) {
                                [strongSelf handleSuccessRequest:JSON cb:response];
                            }
                        }
                        failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                            if (response) {
                                response(ApiRequestErr, nil);
                            }
                        }];
            break;
        }
        case GET: {
            //                //LOG(@"GET http_url:%@",urlString);
            [client.manager GET:urlString
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * __unused task, id JSON) {
                            __strong typeof(weakSelf)strongSelf = weakSelf;
                            if (strongSelf) {
                                [strongSelf handleSuccessRequest:JSON cb:response];
                            }
                        }
                        failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                            if (response) {
                                response(ApiRequestErr, nil);
                                //LOG(@"GET http_url:%@",urlString);
                            }
                        }];
            break;
        }
        case POST: {
            //                //LOG(@"POST http_url:%@",urlString);
            [client.manager POST:urlString
                      parameters:params
                        progress:nil
                         success:^(NSURLSessionDataTask * __unused task, id JSON) {
                             __strong typeof(weakSelf)strongSelf = weakSelf;
                             if (strongSelf) {
                                 [strongSelf handleSuccessRequest:JSON cb:response];
                             }
                         }
                         failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                             //                          //LOG(@"%@",error);
                             if (response) {
                                 response(ApiRequestErr, nil);
                             }
                         }];
            break;
        }
        case DELETE: {
            //LOG(@"DELETE http_url:%@",urlString);
            [client.manager DELETE:urlString
                        parameters:nil
                           success:^(NSURLSessionDataTask * __unused task, id JSON) {
                               __strong typeof(weakSelf)strongSelf = weakSelf;
                               if (strongSelf) {
                                   [strongSelf handleSuccessRequest:JSON cb:response];
                               }
                           }
                           failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                               if (response) {
                                   response(ApiRequestErr, nil);
                               }
                           }];
            break;
        }
        case PUT: {
            //LOG(@"PUT http_url:%@",urlString);
            [client.manager PUT:urlString
                     parameters:params
                        success:^(NSURLSessionDataTask * __unused task, id JSON) {
                            __strong typeof(weakSelf)strongSelf = weakSelf;
                            if (strongSelf) {
                                [strongSelf handleSuccessRequest:JSON cb:response];
                            }
                        }
                        failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                            if (response) {
                                response(ApiRequestErr, nil);
                            }
                        }];
            break;
        }
    }
}

// 网络状态监听，应用当前是否有网络
+ (void)networkReachableWithBlock:(void(^)(ApiRequestNetworkStatus reachableStatus))block {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        ApiRequestNetworkStatus netStatus;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                netStatus = ApiRequestNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                netStatus = ApiRequestNetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: 
                netStatus = ApiRequestNetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                netStatus = ApiRequestNetworkStatusReachableViaWiFi;
                break;
            default:
                netStatus = ApiRequestNetworkStatusUnknown;
                break;
        }
        if (block) {
            block(netStatus);
        }
    }];
}

+ (void) endNetworkReachableMonitor {
    //结束监听
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

// 统一处理响应数据
+ (void)handleSuccessRequest:(id)JSON cb:(void(^)(ApiRequestStatusCode requestStatusCode, id JSON))cb {
    APIClient *client = [APIClient sharedInstance];
    if (client.delegate && [client.delegate respondsToSelector:@selector(handleSuccessRequest:completion:)]) {
        [client.delegate handleSuccessRequest:JSON
                                   completion:^(id aJSON) {
                                       if (cb) {
                                           cb(ApiRequestOK, aJSON);
                                       }
                                   }];
    } else {
        if (cb) {
            cb(ApiRequestOK, JSON);
        }
    }
}

// 取消掉所有网络请求
+ (void)cancelAllRequest {
    APIClient *client = [APIClient sharedInstance];
    if (client.manager) {
        if (client.manager.operationQueue) {
            [client.manager.operationQueue cancelAllOperations];
        }
    }
}

// 填充参数到url上,处理@"user/account/check/{phone}",{phone}这种情况
+ (NSString *)pathGet:(NSString *)uri
               params:(NSDictionary *)params {
    if (nil == uri|| nil == params || params.count <= 0) {
        return  uri;
    }
    for (NSString *key in params) {
        NSString *key2 = [NSString stringWithFormat:@"{%@}",key];
        if ([uri rangeOfString:key2].location != NSNotFound) {
            uri = [uri stringByReplacingOccurrencesOfString:key2 withString:params[key]];
        }
    }
    return [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// 填充query参数到url上,处理"?a=1&b=2"这种情况
+ (NSString *)queryGet:(NSString *)uri
                params:(NSDictionary *)params {
    if (nil == uri || nil == params || params.count <= 0) {
        return  uri;
    }
    NSMutableString *tmpUri = [NSMutableString stringWithString:uri];
    int i = 0;
    for (NSString *key in params) {
        if (i == 0) {
            [tmpUri appendFormat:@"?%@=%@",key, params[key]];
        } else {
            [tmpUri appendFormat:@"&%@=%@",key, params[key]];
        }
        i++;
    }
    return [tmpUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
}
@end
