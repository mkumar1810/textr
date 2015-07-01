//
//  ttrRESTProxy.m
//  TexTr
//
//  Created by Mohan Kumar on 24/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrRESTProxy.h"

@interface ttrRESTProxy()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSString *_responseType;
    NSMutableData *_webData;
    NSMutableDictionary *_inputParms;
    GENERICCALLBACK _proxyReturnMethod;
}

@end

@implementation ttrRESTProxy

- (void) initDatawithAPIType:(NSString*) p_apiType andInputParams:(NSDictionary*) p_prmDict  andReturnMethod:(GENERICCALLBACK) p_returnMethod
{
    _responseType = p_apiType;
    _proxyReturnMethod = p_returnMethod;
    _inputParms = [[NSMutableDictionary alloc] init];
    if (p_prmDict)
    {
        [_inputParms addEntriesFromDictionary:p_prmDict];
    }
    [self generateData];
}

- (void) generateData
{
    NSURL *l_url;
    NSMutableURLRequest *l_theRequest;
    NSURLConnection *l_theConnection;
    NSString * l_messagebody,* l_requesttype, * l_msglength;
    NSError * l_error;
    NSData * l_passdata;
    if ([_responseType isEqualToString:@"USERSIGNUP"]==YES)
    {
        l_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users",MAIN_API_HOST_URL]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"POST";
        l_passdata = [NSJSONSerialization dataWithJSONObject:_inputParms options:kNilOptions error:&l_error];
        l_messagebody = [[NSString alloc] initWithData:l_passdata encoding:NSUTF8StringEncoding];
        [l_theRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    else if ([_responseType isEqualToString:@"USERPROFILE"])
    {
        l_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/files/profile.jpg",MAIN_API_HOST_URL]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"POST";
        l_passdata = [NSJSONSerialization dataWithJSONObject:_inputParms options:kNilOptions error:&l_error];
        l_messagebody = [[NSString alloc] initWithData:l_passdata encoding:NSUTF8StringEncoding];
        [l_theRequest addValue: @"plain/text" forHTTPHeaderField:@"Content-Type"];
    }
    else if ([_responseType isEqualToString:@"UESRLOGIN"])
    {
        l_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login?username=%@&password=%@",MAIN_API_HOST_URL,[_inputParms valueForKey:@"username"],[_inputParms valueForKey:@"password"]]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"GET";
    }
    else if ([_responseType isEqualToString:@"CREATEGROUP"]==YES)
    {
        l_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/classes/groups",MAIN_API_HOST_URL]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"POST";
        l_passdata = [NSJSONSerialization dataWithJSONObject:_inputParms options:kNilOptions error:&l_error];
        l_messagebody = [[NSString alloc] initWithData:l_passdata encoding:NSUTF8StringEncoding];
        [l_theRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    else if ([_responseType isEqualToString:@"GROUPIMAGE"])
    {
        l_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/files/grpimage.jpg",MAIN_API_HOST_URL]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"POST";
        l_passdata = [NSJSONSerialization dataWithJSONObject:_inputParms options:kNilOptions error:&l_error];
        l_messagebody = [[NSString alloc] initWithData:l_passdata encoding:NSUTF8StringEncoding];
        [l_theRequest addValue: @"plain/text" forHTTPHeaderField:@"Content-Type"];
    }
    else if ([_responseType isEqualToString:@"GETSTREAMS"])
    {
        l_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/functions/getstreams",MAIN_API_HOST_URL]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"POST";
        l_passdata = [NSJSONSerialization dataWithJSONObject:_inputParms options:kNilOptions error:&l_error];
        l_messagebody = [[NSString alloc] initWithData:l_passdata encoding:NSUTF8StringEncoding];
        [l_theRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    else if ([_responseType isEqualToString:@"GETMYSTATUSFEED"])
    {
        l_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/functions/getmystatusfeed",MAIN_API_HOST_URL]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"POST";
        l_passdata = [NSJSONSerialization dataWithJSONObject:_inputParms options:kNilOptions error:&l_error];
        l_messagebody = [[NSString alloc] initWithData:l_passdata encoding:NSUTF8StringEncoding];
        [l_theRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    else if ([_responseType isEqualToString:@"GETFILE"])
    {
        l_url = [NSURL URLWithString:[_inputParms valueForKey:@"filename"]];
        l_theRequest = [NSMutableURLRequest requestWithURL:l_url];
        l_requesttype = @"GET";
    }
    [l_theRequest setHTTPMethod:l_requesttype];
    [l_theRequest addValue:PARSE_APPLICATION_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [l_theRequest addValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    if ([l_requesttype isEqualToString:@"POST"])
    {
        if (l_error!=nil)
        {
            [self returnErrorMessage:[l_error description]];
            return;
        }
        l_msglength = [NSString stringWithFormat:@"%ld", (unsigned long)[l_messagebody length]];
        [l_theRequest addValue:l_msglength forHTTPHeaderField:@"Content-Length"];
        [l_theRequest setHTTPBody:[l_messagebody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    l_theConnection = [[NSURLConnection alloc] initWithRequest:l_theRequest delegate:self];
    
    if(l_theConnection)
        _webData = [[NSMutableData data] init];
    else
        [self returnErrorMessage:@"Error in Connection"];
}

- (void) returnErrorMessage:(NSString*) p_errMsg
{
    _proxyReturnMethod(@{@"error":@"-1", @"errmsg":p_errMsg});
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_webData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    _proxyReturnMethod(@{@"error":@"0", @"resultdata":_webData});
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self returnErrorMessage:[error description]];
}

@end