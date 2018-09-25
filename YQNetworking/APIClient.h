//
//  APIClient.h
//  EZPlaySDKDemo
//
//  Created by yuqian on 2018/9/25.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 请求响应的状态
 */
typedef NS_ENUM(NSInteger, ApiRequestStatusCode) {
    ApiRequestErr          = -1,    // 请求出错
    ApiRequestOK           = 0,     // 请求成功
};

/**
 网络状态
 */
typedef NS_ENUM(NSInteger, ApiRequestNetworkStatus) {
    ApiRequestNetworkStatusUnknown          = -1,
    ApiRequestNetworkStatusNotReachable     = 0,
    ApiRequestNetworkStatusReachableViaWWAN = 1,
    ApiRequestNetworkStatusReachableViaWiFi = 2,
};

/**
请求的方法类型
*/
typedef NS_ENUM(NSInteger, HttpMethod) {
    GET         ,
    POST        ,
    DELETE      ,
    PUT         ,
    PATH_GET    , // GET请求,填充参数到url上,处理@"user/account/check/{phone}",{phone}这种情况
    QUERY_GET   , // GET请求,填充query参数到url上,处理"?a=1&b=2"这种情况
};

/**
 请求响应Block

 @param requestStatusCode 请求响应的状态
 @param JSON json
 */
typedef void (^APIClientRequestResponse)(ApiRequestStatusCode requestStatusCode, _Nullable id JSON);

@protocol APIClientDelegate <NSObject>

@required

/**
 拦截成功请求响应数据进行处理

 @param JSON response json
 @param cb call back
 */
- (void)handleSuccessRequest:(id)JSON completion:(void(^)(id aJSON))cb;

@end

@interface APIClient : NSObject

/**
 为处理拦截的响应数据而设置的委托
 */
@property (nonatomic, weak) id<APIClientDelegate> delegate;

/**
 声明单例

 @return APIClient 单例对象
 */
+ (APIClient *)sharedInstance;

/**
 网络状态监听

 @param block 当前网络状态
 */
+ (void)networkReachableWithBlock:(void(^)(ApiRequestNetworkStatus reachableStatus))block;


/**
 结束网络状态监听
 */
+ (void) endNetworkReachableMonitor;

/**
 发送请求，返回JSON格式的响应数据

 @param urlString url string
 @param method http method
 @param params parameters
 @param response response
 */
+ (void)requestURL:(NSString *)urlString
        httpMethod:(HttpMethod)method
            params:(NSDictionary *)params
          response:(APIClientRequestResponse)response;

/**
 取消掉所有网络请求
 */
+ (void)cancelAllRequest;

@end


NS_ASSUME_NONNULL_END
